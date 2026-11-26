"""Import normalized demonstration mappings and publish FHIR R4 terminology."""
import csv
from datetime import datetime, timezone
from pathlib import Path

ROOT = 'https://aucte.example/fhir'
VERSION = 'demo-2.0'
FIELDS = {
    'namaste': ('namasteCode', 'namasteTerm'),
    'tm2': ('tm2Code', 'tm2Title'),
    'biomedicine': ('biomedicineCode', 'biomedicineTitle'),
    'who-ayurveda': ('whoTerm', 'whoTerm'),
}
LABELS = {
    'namaste': 'NAMASTE sample',
    'tm2': 'ICD-11 TM2 sample',
    'biomedicine': 'ICD-11 Biomedicine sample',
    'who-ayurveda': 'WHO Ayurveda terminology sample',
}


def system(kind):
    return f'{ROOT}/CodeSystem/demo-{kind}'


def now():
    return datetime.now(timezone.utc).isoformat()


def load_csv(path):
    with Path(path).open(encoding='utf-8-sig', newline='') as file:
        rows = list(csv.DictReader(file))
    codes = set()
    for row in rows:
        code = row.get('namasteCode', '')
        if (code in codes or row.get('system') not in ('Ayurveda', 'Siddha', 'Unani')
                or any(not row.get(field, '').strip() for field in (
                    'id', 'namasteCode', 'namasteTerm', 'tm2Code', 'tm2Title',
                    'biomedicineCode', 'biomedicineTitle'))
                or any(not row[FIELDS[kind][0]].startswith(prefix) for kind, prefix in (
                    ('namaste', 'DEMO-NAM-'), ('tm2', 'DEMO-TM2-'),
                    ('biomedicine', 'DEMO-BIO-')))):
            raise ValueError(f'Invalid or duplicate demonstration row {code}')
        codes.add(code)
    if not rows:
        raise ValueError('CSV contains no mappings')
    return rows


def coding(row, kind):
    code_field, display_field = FIELDS[kind]
    code = row.get(code_field, '')
    if not code:
        return None
    if kind == 'who-ayurveda':
        code = row['namasteCode'].replace('DEMO-NAM-', 'DEMO-WHO-', 1)
    return dict(system=system(kind), version=VERSION, code=code, display=row[display_field])


def matches(rows, query):
    query = query.strip().casefold()
    return [row for row in rows if any(query in row.get(key, '').casefold() for key in (
        'namasteCode', 'namasteTerm', 'system', 'tm2Code', 'tm2Title',
        'biomedicineCode', 'biomedicineTitle', 'whoTerm', 'description'))]


def concepts(rows, kind):
    found = {}
    for row in rows:
        item = coding(row, kind)
        if item:
            found.setdefault(item['code'], item)
    return list(found.values())


def code_system(rows, kind):
    items = concepts(rows, kind)
    return dict(resourceType='CodeSystem', id=f'demo-{kind}', url=system(kind),
                version=VERSION, name='Demo' + kind.title().replace('-', ''),
                title=LABELS[kind], status='draft', experimental=True, content='complete',
                caseSensitive=True, count=len(items),
                concept=[{k: item[k] for k in ('code', 'display')} for item in items])


def concept_map(rows, kind):
    return dict(resourceType='ConceptMap', id=f'namaste-to-{kind}',
                url=f'{ROOT}/ConceptMap/namaste-to-{kind}', version=VERSION,
                status='draft', experimental=True, title=f'NAMASTE to {LABELS[kind]}',
                description='Synthetic relationships for demonstration.',
                group=[dict(source=system('namaste'), sourceVersion=VERSION,
                            target=system(kind), targetVersion=VERSION,
                            element=[dict(code=row['namasteCode'], display=row['namasteTerm'],
                                          target=[dict(code=item['code'], display=item['display'],
                                                       equivalence='relatedto')])
                                     for row in rows if (item := coding(row, kind))])])


def translate(rows, code, source, target):
    pair = (source, target)
    if pair not in [('namaste', k) for k in FIELDS if k != 'namaste'] + [('tm2', 'namaste')]:
        raise ValueError('Unsupported translation direction')
    mapped = []
    map_kind = source if target == 'namaste' else target
    for row in rows:
        origin, result = coding(row, source), coding(row, target)
        if origin and origin['code'] == code and result and result not in mapped:
            mapped.append(result)
    return dict(resourceType='Parameters', parameter=[
        dict(name='result', valueBoolean=bool(mapped)),
        *[dict(name='match', part=[
            dict(name='equivalence', valueCode='relatedto'),
            dict(name='concept', valueCoding=item),
            dict(name='source', valueUri=f'{ROOT}/ConceptMap/namaste-to-{map_kind}'),
        ]) for item in mapped],
    ])
