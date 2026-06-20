#!/usr/bin/env bash
# Pure markdown rendering from env vars. No network.

_vt_line() {
  case "${VT_STATE:-unknown}" in
    found)
      local total det
      total=$(( ${VT_MALICIOUS:-0} + ${VT_SUSPICIOUS:-0} + ${VT_HARMLESS:-0} + ${VT_UNDETECTED:-0} ))
      det=$(( ${VT_MALICIOUS:-0} + ${VT_SUSPICIOUS:-0} ))
      printf '%s/%s motori segnalano una minaccia' "$det" "$total" ;;
    pending)  printf 'inviato a VirusTotal, analisi in corso' ;;
    notfound) printf 'non ancora presente su VirusTotal (invio manuale consigliato)' ;;
    *)        printf 'verifica VirusTotal non disponibile in questa esecuzione' ;;
  esac
}

render_scan_md() {
  cat <<MD
# Analisi di sicurezza automatica — ${TAG}

> File generato automaticamente dalla pipeline CI a ogni release.
> Il triage curato e definitivo resta in [SECURITY.md](../SECURITY.md).

- **App:** \`${PKG}\` — release \`${TAG}\`
- **Data analisi:** ${SCAN_DATE}
- **SHA-256 APK:** \`${SHA256}\`
- **Strumenti:** MobSF (statica) + VirusTotal

## MobSF (analisi statica)

- **Punteggio di sicurezza:** ${MOBSF_SCORE}
- **Segnalazioni HIGH:** ${MOBSF_HIGH}
- **Segnalazioni WARNING:** ${MOBSF_WARNING}
- **Segnalazioni INFO:** ${MOBSF_INFO}

Report completi allegati alla [release ${TAG}](https://github.com/alessiosavi/brain-break/releases/tag/${TAG}) (\`mobsf-report-${TAG}.pdf\`, \`mobsf-report-${TAG}.json\`).
Immagine MobSF: \`${MOBSF_IMAGE_DIGEST}\`.

## VirusTotal

- **Esito:** $(_vt_line)
- **Report:** ${VT_GUI_URL}

---
*Nessuna segnalazione HIGH di MobSF e nessun rilevamento VirusTotal indicano un APK pulito. Le segnalazioni WARNING/INFO sono in genere falsi positivi di libreria; vedi SECURITY.md per il triage.*
MD
}

render_issue_md() {
  cat <<MD
## ⚠ Riscontri di sicurezza in ${TAG}

L'analisi automatica ha prodotto riscontri da verificare:

- **MobSF HIGH:** ${MOBSF_HIGH}
- **VirusTotal rilevamenti (malicious+suspicious):** $(( ${VT_MALICIOUS:-0} + ${VT_SUSPICIOUS:-0} ))
- **SHA-256:** \`${SHA256}\`
- **Report VirusTotal:** ${VT_GUI_URL}

Report MobSF allegati alla [release ${TAG}](https://github.com/alessiosavi/brain-break/releases/tag/${TAG}).
Esegui il triage e aggiorna [SECURITY.md](https://github.com/alessiosavi/brain-break/blob/main/SECURITY.md) di conseguenza.

*Issue aperta automaticamente dalla pipeline di sicurezza.*
MD
}
