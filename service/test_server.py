import json
import os
from pathlib import Path
import sqlite3
import tempfile
import threading
import unittest
from http.server import ThreadingHTTPServer
from unittest.mock import patch
from urllib.error import HTTPError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from server import Handler
from terminology import VERSION, coding, load_csv, system


class DemoWorkflow(unittest.TestCase):
    def test_search_translate_upload_and_receipt(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(
            os.environ, {'AUCTE_DEMO_TOKEN': 'test-only', 'AUCTE_INTROSPECTION_URL': ''}
        ):
            with ThreadingHTTPServer(('127.0.0.1', 0), Handler) as server:
                server.rows = load_csv(Path(__file__).with_name('namaste_demo.csv'))
                server.db_path = Path(directory) / 'test.sqlite'
                server.snapshot = Path(directory) / 'who.json'
                with sqlite3.connect(server.db_path) as db:
                    db.execute('CREATE TABLE encounters (id TEXT PRIMARY KEY, actor TEXT, '
                               'received_at TEXT, terminology_version TEXT, consent_refs TEXT, payload TEXT)')
                worker = threading.Thread(target=server.serve_forever, daemon=True)
                worker.start()
                try:
                    self.check_workflow(server.server_port, server.rows[0])
                finally:
                    server.shutdown()
                    worker.join()

    def check_workflow(self, port, row):
        def request(path, payload=None, authenticated=True):
            req = Request(f'http://127.0.0.1:{port}{path}',
                          data=None if payload is None else json.dumps(payload).encode())
            if authenticated:
                req.add_header('Authorization', 'Bearer test-only')
            try:
                with urlopen(req, timeout=4) as response:
                    return response.status, json.load(response)
            except HTTPError as error:
                with error:
                    return error.code, json.load(error)

        self.assertEqual(request('/api/codings', authenticated=False)[0], 401)
        status, expansion = request('/fhir/ValueSet/$expand?filter=Jvara')
        self.assertEqual(status, 200)
        self.assertGreater(expansion['expansion']['total'], 0)
        query = urlencode(dict(code=row['tm2Code'], system=system('tm2'),
                               targetsystem=system('namaste')))
        status, translation = request('/fhir/ConceptMap/$translate?' + query)
        self.assertEqual(status, 200)
        self.assertTrue(translation['parameter'][0]['valueBoolean'])
        self.assertEqual(translation['parameter'][1]['part'][1]['valueCoding']['code'],
                         row['namasteCode'])

        patient = dict(reference='Patient/AUC-PAT-1001')
        encounter = dict(reference='Encounter/sample')
        resources = [
            dict(resourceType='Patient', id='AUC-PAT-1001'),
            dict(resourceType='Encounter', id='sample', subject=patient),
            dict(resourceType='Condition', id='sample', subject=patient, encounter=encounter,
                 category=[dict(coding=[dict(code='problem-list-item')])],
                 code=dict(coding=[coding(row, k) for k in ('namaste', 'tm2', 'biomedicine')])),
        ]
        bundle = dict(resourceType='Bundle', type='collection', id='example', entry=[])

        def add(resource):
            bundle['entry'].append(dict(
                fullUrl=f"https://aucte.example/fhir/{resource['resourceType']}/{resource['id']}",
                resource=resource,
            ))

        for resource in resources:
            add(resource)
        self.assertEqual(request('/api/encounters', bundle)[0], 400)
        add(dict(resourceType='Consent', id='sample', status='active',
                 patient=patient, meta=dict(versionId='1.0')))
        self.assertEqual(request('/api/encounters', bundle)[0], 201)
        self.assertEqual(request('/api/encounters', bundle)[0], 200)
        status, receipt = request('/api/encounters/example')
        self.assertEqual(status, 200)
        values = {p['name']: p.get('valueString') for p in receipt['parameter']}
        self.assertEqual(values['terminologyVersion'], VERSION)
        self.assertEqual(values['consentVersion'], 'Consent/sample/_history/1.0')
        resources[2]['code']['coding'][1]['code'] = 'invalid'
        self.assertEqual(request('/api/encounters', bundle)[0], 400)


if __name__ == '__main__':
    unittest.main()
