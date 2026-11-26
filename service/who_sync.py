"""Fetch release-pinned WHO entities from a curated list of entity IDs."""
import argparse
import base64
import json
import os
import re
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen

HOST = 'https://id.who.int'
TOKEN = 'https://icdaccessmanagement.who.int/connect/token'


def request_json(url, headers, data=None):
    with urlopen(Request(url, data=data, headers=headers), timeout=25) as response:
        return json.load(response)


def sync(release, references, output):
    if not re.fullmatch(r'\d{4}-\d{2}', release):
        raise ValueError('Use a WHO release in YYYY-MM format')
    if not references or any(
        row.get('kind') not in ('tm2', 'biomedicine')
        or not re.fullmatch(r'\d+', str(row.get('id', ''))) for row in references
    ):
        raise ValueError('Each reference needs kind and a WHO numeric entity id')
    creds = base64.b64encode(
        f"{os.environ['WHO_CLIENT_ID']}:{os.environ['WHO_CLIENT_SECRET']}".encode()
    ).decode()
    token = request_json(TOKEN, {
        'Authorization': f'Basic {creds}',
        'Content-Type': 'application/x-www-form-urlencoded',
    }, urlencode({'grant_type': 'client_credentials', 'scope': 'icdapi_access'}).encode())
    headers = {
        'Authorization': f"Bearer {token['access_token']}", 'API-Version': 'v2',
        'Accept': 'application/json', 'Accept-Language': 'en',
    }
    entries = []
    for row in references:
        url = f"{HOST}/icd/release/11/{release}/mms/{row['id']}"
        entity = request_json(url, headers)
        entries.append(dict(kind=row['kind'], uri=url, code=entity['code'],
                            title=entity['title']['@value']))
    output = Path(output)
    temp = output.with_suffix('.tmp')
    temp.write_text(json.dumps(dict(release=release, entries=entries), indent=2) + '\n')
    temp.replace(output)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('release')
    parser.add_argument('references', type=Path)
    parser.add_argument('--output', default='who_snapshot.json')
    args = parser.parse_args()
    sync(args.release, json.loads(args.references.read_text()), args.output)
