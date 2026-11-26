"""AUCTE demonstration FHIR terminology and encounter service."""
import argparse
import base64
import hmac
import json
import os
import re
import sqlite3
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlencode, urlsplit
from urllib.request import Request, urlopen

from terminology import (FIELDS, ROOT, VERSION, code_system, coding, concept_map,
                         concepts, load_csv, matches, now, system, translate)


def validate_bundle(bundle, rows):
    if bundle['resourceType'] != 'Bundle' or bundle['type'] != 'collection':
        raise ValueError('Expected a FHIR collection Bundle')
    bundle_id = bundle['id']
    if not re.fullmatch(r'[A-Za-z0-9.-]{1,64}', bundle_id):
        raise ValueError('Invalid bundle ID')
    resources = {}
    for entry in bundle['entry']:
        resource = entry['resource']
        ref = f"{resource['resourceType']}/{resource['id']}"
        if ref in resources or not entry['fullUrl'].endswith('/' + ref):
            raise ValueError('Invalid or duplicate resource URL')
        resources[ref] = resource
    conditions = [r for r in resources.values() if r['resourceType'] == 'Condition']
    if not conditions:
        raise ValueError('At least one problem-list Condition is required')
    mappings = {r['namasteCode']: r for r in rows}
    consent_ids = set()
    for condition in conditions:
        patient = condition['subject']['reference']
        encounter = condition['encounter']['reference']
        if (not patient.startswith('Patient/AUC-PAT-') or patient not in resources
                or not encounter.startswith('Encounter/')
                or resources.get(encounter, {}).get('subject', {}).get('reference') != patient):
            raise ValueError('Expected a synthetic patient and a matching encounter')
        if not any(c.get('code') == 'problem-list-item'
                   for category in condition['category'] for c in category['coding']):
            raise ValueError('Expected a problem-list Condition')
        consent = next((r for r in resources.values() if r['resourceType'] == 'Consent'
                        and r['status'] == 'active'
                        and r['patient']['reference'] == patient
                        and r.get('meta', {}).get('versionId')), None)
        if not consent:
            raise ValueError('Versioned active consent is required for each patient')
        consent_ids.add(f"Consent/{consent['id']}/_history/{consent['meta']['versionId']}")
        codings = condition['code']['coding']
        primary = [c for c in codings if c['system'] == system('namaste')]
        if len(primary) != 1 or primary[0]['code'] not in mappings:
            raise ValueError('Expected one supported synthetic NAMASTE code')
        row = mappings[primary[0]['code']]
        for kind in ('namaste', 'tm2', 'biomedicine'):
            expected = coding(row, kind)
            found = [c for c in codings if c['system'] == expected['system']]
            if len(found) != 1 or any(found[0].get(k) != expected[k] for k in ('code', 'version')):
                raise ValueError(f'Invalid or mismatched {kind} coding')
    return bundle_id, sorted(consent_ids)


def authenticate(header, scope):
    scheme, _, token = header.partition(' ')
    if scheme.lower() != 'bearer' or not token:
        return None
    demo_token = os.getenv('AUCTE_DEMO_TOKEN')
    endpoint = os.getenv('AUCTE_INTROSPECTION_URL')
    if demo_token and not endpoint and hmac.compare_digest(token.encode(), demo_token.encode()):
        return 'demo-practitioner'
    if not endpoint or urlsplit(endpoint).scheme != 'https':
        return None
    # A trusted integration gateway attests ABHA linkage. Firebase login is separate.
    client = os.environ['AUCTE_OAUTH_CLIENT_ID']
    secret = os.environ['AUCTE_OAUTH_CLIENT_SECRET']
    basic = base64.b64encode(f'{client}:{secret}'.encode()).decode()
    request = Request(endpoint, headers={'Authorization': f'Basic {basic}',
                                         'Content-Type': 'application/x-www-form-urlencoded'},
                      data=urlencode({'token': token}).encode())
    with urlopen(request, timeout=8) as response:
        claims = json.load(response)
    audiences = claims.get('aud', [])
    if isinstance(audiences, str):
        audiences = [audiences]
    if (claims.get('active') is True and claims.get('abha_linked') is True
            and os.environ['AUCTE_OAUTH_AUDIENCE'] in audiences
            and scope in claims.get('scope', '').split()):
        return claims.get('sub')
    return None


class Handler(BaseHTTPRequestHandler):
    def log_request(self, code='-', size='-'):
        pass

    def send_json(self, status, payload):
        body = json.dumps(payload, ensure_ascii=False).encode()
        self.send_response(status)
        self.send_header('Content-Type', 'application/fhir+json; charset=utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Cache-Control', 'no-store')
        if status == 401:
            self.send_header('WWW-Authenticate', 'Bearer')
        self.end_headers()
        self.wfile.write(body)

    def error(self, status, message):
        code = {400: 'invalid', 401: 'login', 404: 'not-found', 409: 'conflict',
                413: 'too-long', 503: 'transient'}[status]
        self.send_json(status, dict(resourceType='OperationOutcome',
                                    issue=[dict(severity='error', code=code, diagnostics=message)]))

    def authorize(self, scope):
        try:
            actor = authenticate(self.headers.get('Authorization', ''), scope)
        except (OSError, KeyError, ValueError, TypeError):
            self.error(503, 'Token verification is unavailable')
            return None
        if not actor:
            self.error(401, 'A valid bearer token with the required scope is needed')
        return actor

    def do_GET(self):
        path = urlsplit(self.path)
        if path.path == '/health':
            return self.send_json(200, dict(status='ok', version=VERSION, mode='synthetic'))
        if path.path.startswith('/api/encounters/'):
            actor = self.authorize('encounters.read')
            if not actor:
                return
            bundle_id = path.path.removeprefix('/api/encounters/')
            with sqlite3.connect(self.server.db_path) as db:
                record = db.execute(
                    'SELECT received_at, terminology_version, consent_refs FROM encounters '
                    'WHERE id = ? AND actor = ?', (bundle_id, actor)
                ).fetchone()
            if not record:
                return self.error(404, 'Encounter receipt does not exist')
            return self.send_json(200, dict(resourceType='Parameters', parameter=[
                dict(name='bundleId', valueString=bundle_id),
                dict(name='receivedAt', valueInstant=record[0]),
                dict(name='terminologyVersion', valueString=record[1]),
                *[dict(name='consentVersion', valueString=ref) for ref in json.loads(record[2])],
            ]))
        if not self.authorize('terminology.read'):
            return
        args = {k: v[0] for k, v in parse_qs(path.query).items()}
        rows = self.server.rows
        try:
            if path.path == '/fhir/ValueSet/$expand':
                query = args.get('filter', '')
                kinds = [args['kind']] if 'kind' in args else list(FIELDS)
                offset, count = int(args.get('offset', 0)), int(args.get('count', 25))
                if offset < 0 or not 1 <= count <= 100:
                    raise ValueError('Invalid pagination')
                selected = matches(rows, query)
                found = [item for kind in kinds for item in concepts(selected, kind)]
                value_id = 'demo-' + (kinds[0] if len(kinds) == 1 else 'all')
                result = dict(resourceType='ValueSet', id=value_id, status='draft',
                              url=f'{ROOT}/ValueSet/{value_id}', version=VERSION,
                              expansion=dict(timestamp=now(), total=len(found), offset=offset,
                                             contains=found[offset:offset + count]))
            elif path.path == '/fhir/CodeSystem/$lookup':
                kind = next(k for k in FIELDS if system(k) == args['system'])
                item = next((item for item in concepts(rows, kind)
                             if item['code'] == args['code']), None)
                if not item:
                    return self.error(404, 'Code does not exist')
                result = dict(resourceType='Parameters', parameter=[
                    dict(name='name', valueString=kind),
                    dict(name='version', valueString=item['version']),
                    dict(name='display', valueString=item['display']),
                ])
            elif path.path == '/fhir/ConceptMap/$translate':
                source = next((k for k in FIELDS if system(k) == args['system']), None)
                target = next((k for k in FIELDS if system(k) == args['targetsystem']), None)
                result = translate(rows, args['code'], source, target)
            elif path.path.startswith('/fhir/CodeSystem/demo-'):
                result = code_system(rows, path.path.removeprefix('/fhir/CodeSystem/demo-'))
            elif path.path.startswith('/fhir/ConceptMap/namaste-to-'):
                kind = path.path.removeprefix('/fhir/ConceptMap/namaste-to-')
                if kind == 'namaste' or kind not in FIELDS:
                    return self.error(404, 'ConceptMap does not exist')
                result = concept_map(rows, kind)
            elif path.path == '/api/codings':
                result = [dict(row, mappingConfidence=0, isDemo=True)
                          for row in matches(rows, args.get('q', ''))]
            elif path.path == '/api/who':
                snapshot = json.loads(self.server.snapshot.read_text()) if self.server.snapshot.exists() else {}
                query = args.get('q', '').casefold()
                result = dict(release=snapshot.get('release'), entries=[
                    entry for entry in snapshot.get('entries', [])
                    if entry['kind'] == args.get('kind', entry['kind'])
                    and (query in entry['code'].casefold() or query in entry['title'].casefold())])
            else:
                return self.error(404, 'Endpoint does not exist')
        except (KeyError, ValueError, StopIteration) as exc:
            return self.error(400, f'Invalid terminology request: {exc}')
        self.send_json(200, result)

    def do_POST(self):
        if self.path != '/api/encounters':
            return self.error(404, 'Endpoint does not exist')
        actor = self.authorize('encounters.write')
        if not actor:
            return
        try:
            length = int(self.headers.get('Content-Length', 0))
            if length > 1_000_000:
                return self.error(413, 'Bundle exceeds the demo upload limit')
            if length <= 0:
                raise ValueError('Bundle body is required')
            bundle = json.loads(self.rfile.read(length))
            bundle_id, consent_ids = validate_bundle(bundle, self.server.rows)
        except (ValueError, KeyError, TypeError, AttributeError) as exc:
            return self.error(400, f'Invalid bundle: {exc}')
        payload = json.dumps(bundle, sort_keys=True)
        with sqlite3.connect(self.server.db_path) as db:
            db.execute('BEGIN IMMEDIATE')
            previous = db.execute('SELECT actor, payload FROM encounters WHERE id = ?',
                                  (bundle_id,)).fetchone()
            if previous and previous != (actor, payload):
                return self.error(409, 'Bundle ID is already in use')
            if not previous:
                db.execute('INSERT INTO encounters VALUES (?, ?, ?, ?, ?, ?)',
                           (bundle_id, actor, now(), VERSION, json.dumps(consent_ids), payload))
        self.send_json(200 if previous else 201, dict(resourceType='Parameters', parameter=[
            dict(name='bundleId', valueString=bundle_id),
            dict(name='terminologyVersion', valueString=VERSION),
            dict(name='duplicate', valueBoolean=bool(previous)),
        ]))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--bind', default='127.0.0.1')
    parser.add_argument('--port', default=8080, type=int)
    parser.add_argument('--csv', type=Path, default=Path(__file__).with_name('namaste_demo.csv'))
    parser.add_argument('--db', default='aucte-demo.sqlite')
    parser.add_argument('--who-snapshot', type=Path, default=Path('who_snapshot.json'))
    args = parser.parse_args()
    if not (os.getenv('AUCTE_DEMO_TOKEN') or os.getenv('AUCTE_INTROSPECTION_URL')):
        parser.error('Configure AUCTE_DEMO_TOKEN or AUCTE_INTROSPECTION_URL')
    rows = load_csv(args.csv)
    with sqlite3.connect(args.db) as db:
        db.execute('''CREATE TABLE IF NOT EXISTS encounters (
                   id TEXT PRIMARY KEY, actor TEXT NOT NULL, received_at TEXT NOT NULL,
                   terminology_version TEXT NOT NULL, consent_refs TEXT NOT NULL,
                   payload TEXT NOT NULL)''')
    with ThreadingHTTPServer((args.bind, args.port), Handler) as server:
        server.rows, server.db_path, server.snapshot = rows, args.db, args.who_snapshot
        print(f'AUCTE demo API listening on {args.bind}:{server.server_port}', flush=True)
        server.serve_forever()


if __name__ == '__main__':
    main()
