# CI security scanning

Two GitHub Actions workflows scan the published APK.

## `security-scan.yml` (automatic, on every published release)
- Downloads the release's `*.apk`, runs **MobSF static** (Docker + REST) and a **VirusTotal**
  by-hash check, attaches `mobsf-report-<tag>.{pdf,json}` + scorecard to the release,
  appends a VirusTotal link to the notes, commits `security/latest-scan.md` +
  `security/history/<tag>.md`, and opens an issue if MobSF reports HIGH findings or
  VirusTotal reports detections.
- **Required secret:** `VT_API_KEY` — a free key from https://www.virustotal.com
  (Settings → API key). Add via repo *Settings → Secrets and variables → Actions*.
  Free tier: 4 req/min, 500/day; the ~55 MB APK usually exceeds VT's 32 MB upload
  cap, so the workflow relies on the by-hash lookup (and best-effort submission).

## `dynamic-scan.yml` (manual, experimental)
- `workflow_dispatch` with a `tag` input. Boots an Android-9 (API 28) x86_64 emulator
  and runs MobSF dynamic analysis; uploads the report as a workflow artifact.
- Experimental and fragile; never gates a release. Note: MobSF's Java/Kotlin hooks
  see little of a Flutter app's Dart/BoringSSL stack — the static scan remains the
  primary signal.

## Re-running
Trigger `security-scan.yml` manually (Actions → Security scan (release) → Run workflow)
with a tag to re-scan an existing release.
