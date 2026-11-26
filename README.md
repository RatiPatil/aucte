# AUCTE · SIH 25026

AUCTE is an Android Flutter prototype for searching AYUSH terminology and exporting a double-coded clinical encounter. The bundled vocabulary, mappings, patients, and practitioner are synthetic. Use sample records for the presentation.

## Run the Android app

Install Flutter stable (Dart 3.11.3 or newer), Android Studio with its SDK, and a JDK supported by Android Gradle Plugin 8.11.1. Connect an Android phone or start an emulator.

```sh
flutter pub get
flutter run
```

Complete onboarding and choose **Continue with sample data** on the sign-in screen. Search, mapping, encounter entry, and FHIR preview work offline. The existing Firebase sign-in is independent of the demonstration account.

## Run the terminology service

Run from the repository root with Python 3.10 or newer.

```sh
export AUCTE_DEMO_TOKEN="$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')"
python3 service/server.py
```

In a second terminal set the same value for `AUCTE_DEMO_TOKEN`, then run:

```sh
adb reverse tcp:8080 tcp:8080
flutter run --dart-define=AUCTE_API_URL=http://127.0.0.1:8080 \
  --dart-define=AUCTE_DEMO_TOKEN="$AUCTE_DEMO_TOKEN"
```

The debug build permits local HTTP. Use this configuration with synthetic data only. Dart defines are embedded in the build, so use a disposable demo token.

## Five-minute presentation

1. **CSV import.** Start the service. The normalized `service/namaste_demo.csv` contains Ayurveda, Siddha, and Unani sample records. Show its generated NAMASTE CodeSystem and the TM2, Biomedicine, and WHO Ayurveda ConceptMaps.
2. **Search and mapping.** Open terminology search and enter `Jvara` or `DEMO-TM2-AYU-101`. Open the result and show the NAMASTE, TM2, and Biomedicine labels. The WHO Ayurveda label is a sample search term. Use the API to demonstrate the reverse TM2-to-NAMASTE translation.
3. **Encounter and Problem List.** Start an encounter for a preloaded patient. Select the sample diagnosis, grant consent, and save. Open **FHIR JSON** and show the `problem-list-item` Condition, its synthetic traditional and biomedical codings, the linked Encounter, and the versioned Consent.
4. **Upload and audit.** Tap the cloud upload icon in FHIR preview. The service checks the sample mappings, references and active consent before saving the Bundle and an audit receipt. Reuploading the same Bundle returns the existing receipt. Fetch the receipt using the Bundle ID in the preview.
5. **WHO updates.** Show the release-pinned sync command below. It uses real WHO endpoints when credentials and curated entity IDs are available. The installed demo runs with the synthetic CSV without those prerequisites.

## API reference

All routes except `/health` require `Authorization: Bearer <token>`. Base FHIR canonical prefix is `https://aucte.example/fhir`.

| Route | Purpose |
| --- | --- |
| `GET /fhir/CodeSystem/demo-namaste` | NAMASTE sample vocabulary, versioned |
| `GET /fhir/CodeSystem/demo-who-ayurveda` | Sample Ayurveda vocabulary |
| `GET /fhir/ConceptMap/namaste-to-{tm2,biomedicine,who-ayurveda}` | Inspect sample mappings |
| `GET /fhir/ValueSet/$expand?filter=Jvara&count=10` | Autocomplete across demo systems, optional `kind`, `offset` |
| `GET /fhir/CodeSystem/$lookup?system=…&code=…` | Look up a code, including Biomedicine |
| `GET /fhir/ConceptMap/$translate?system=…&targetsystem=…&code=…` | NAMASTE to TM2, Biomedicine, or Ayurveda, and TM2 to NAMASTE |
| `POST /api/encounters` | Upload a FHIR collection Bundle with sample patient, encounter, conditions and consent |
| `GET /api/encounters/{id}` | Read the uploader's receipt with time and terminology/consent versions |
| `GET /api/who?kind=tm2&q=…` | Search the cached WHO release snapshot |
| `GET /api/codings?q=Jvara` | Read joined sample terminology records for the mobile app |

Reverse translation example:

```sh
curl --get 'http://localhost:8080/fhir/ConceptMap/$translate' \
  -H "Authorization: Bearer $AUCTE_DEMO_TOKEN" \
  --data-urlencode 'system=https://aucte.example/fhir/CodeSystem/demo-tm2' \
  --data-urlencode 'targetsystem=https://aucte.example/fhir/CodeSystem/demo-namaste' \
  --data-urlencode 'code=DEMO-TM2-AYU-101'
```

## Authorized integration

For WHO ICD API sync, set `WHO_CLIENT_ID` and `WHO_CLIENT_SECRET`. Prepare a JSON array of objects with `kind` (`tm2` or `biomedicine`) and the corresponding numeric WHO linearization entity `id` from a reviewed release. Run `python3 service/who_sync.py YYYY-MM references.json` to refresh the cached snapshot. The snapshot endpoint keeps the official entities separate from synthetic translations. An official NAMASTE export needs field normalization, reviewed ConceptMaps, and ICD-11 coding-rule validation before clinical integration.

The optional introspection adapter expects an HTTPS OAuth 2.0 gateway that attests ABHA linkage. Set `AUCTE_INTROSPECTION_URL`, `AUCTE_OAUTH_CLIENT_ID`, `AUCTE_OAUTH_CLIENT_SECRET`, and `AUCTE_OAUTH_AUDIENCE`. The gateway must return active, audience-matched, ABHA-linked claims with a subject and the relevant `terminology.read`, `encounters.write`, or `encounters.read` scope. Live ABDM registration, ABHA identity and consent exchange, ISO 22600 policy enforcement, SNOMED CT/LOINC validation, and profile-level India EHR conformance require an authorized integration and separate verification.
