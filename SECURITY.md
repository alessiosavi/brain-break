# Sicurezza — Brain Break

Questa pagina riporta in modo trasparente l'analisi di sicurezza dell'APK di
Brain Break, così puoi installarlo con fiducia.

- **App analizzata:** `brain-break-0.0.1-universal.apk` (`com.alessiosavi.brainbreak`)
- **Strumento:** [MobSF](https://github.com/MobSF/Mobile-Security-Framework-MobSF) — analisi **statica** e **dinamica**
- **Firma:** certificato di rilascio dedicato (`CN=Brain Break, O=Alessio Savi`; impronta SHA-256 del certificato `cda84e991788cb1428c9977df608cc5e0424274fcb32f1874c4a65bb6cc14629`)

## Esito in breve

**Nessuna vulnerabilità reale dell'applicazione.** MobSF ha prodotto 5
segnalazioni: **4 sono falsi positivi** (codice di librerie standard di Google/
AndroidX, non dell'app) e **1 è una nota di hardening minore** (rischio basso),
non una vulnerabilità.

L'app è robusta per costruzione: **solo connessioni cifrate** (HTTPS, traffico
in chiaro disabilitato), **permessi minimi** (nessun accesso a posizione,
contatti, fotocamera, microfono, SMS, file), **nessun componente IPC esposto**
sensibile, autenticazione lato server con JWT Supabase e **nessuna crittografia
custom**.

| # | Segnalazione MobSF | Origine | Rischio reale | Esito |
|---|--------------------|---------|---------------|-------|
| 1 | `minSdk=24`: installabile su Android 7.0 (non più aggiornato) | Default del framework Flutter | **Basso** | Nota di hardening, accettata |
| 2 | Service `…gms.auth.api.signin.RevocationBoundService` esportato | Google Play Services (libreria) | Nessuno | **Falso positivo** |
| 3 | Receiver `androidx.profileinstaller.ProfileInstallReceiver` esportato | AndroidX (libreria) | Nessuno | **Falso positivo** |
| 4 | "Insecure Random Number Generator" | Codice Google/protobuf (timing dei retry) | Nessuno | **Falso positivo** |
| 5 | "Hardcoded sensitive information" | Nomi di campi in `flutter_local_notifications` | Nessuno | **Falso positivo** |

## Dettaglio

### 1. `minSdk=24` — nota di hardening (rischio basso) ✅ accettata
Il valore è il **default del framework Flutter** (non una scelta per indebolire
l'app). Significa solo che l'app può essere installata anche su Android 7.0, un
sistema che Google non aggiorna più. Non introduce alcuna vulnerabilità
nell'app: le connessioni sono solo cifrate (no traffico in chiaro, no
MITM/downgrade), i permessi sono minimi, l'unico componente esportato è
l'Activity di avvio di Flutter e l'autenticazione è lato server.
**In sintesi:** una nota minore, non una vulnerabilità — l'app è blindata; resta
solo installabile su telefoni molto vecchi che Google non patcha più.
*Azione opzionale:* alzare `minSdk` a 26+ se le statistiche mostrano pochissimi
utenti su Android 7.x.

### 2. `RevocationBoundService` esportato — falso positivo ✅
È un componente della **libreria ufficiale Google Play Services** (sign-in),
non codice dell'app. È protetto da un permesso a livello *signature* di proprietà
di Google: **solo il software firmato Google può interagirvi**, nessun'altra app.
L'app non usa nemmeno Google Sign-In (l'accesso è via Supabase). È l'artefatto
tipico che fa scattare l'euristica di MobSF.

### 3. `ProfileInstallReceiver` esportato — falso positivo ✅
Componente standard di **AndroidX** (`profileinstaller`) che velocizza l'avvio
dell'app. È protetto dal permesso `android.permission.DUMP` (livello
*signature|privileged*): **solo il sistema Android può inviargli messaggi**, mai
un'altra app. Non espone dati.

### 4. "Insecure Random Number Generator" — falso positivo ✅
La randomicità "debole" rilevata è **solo dentro librerie Google/protobuf** (per
cose innocue come il timing dei retry). La randomicità sensibile alla sicurezza
usa correttamente `SecureRandom`. Login e dati non sono indeboliti.

### 5. "Hardcoded sensitive information" — falso positivo ✅
Il testo segnalato sono **nomi di campi interni** (es. `key`, `callback_handle`)
dentro la libreria open-source `flutter_local_notifications`, **non** password o
segreti reali.

## Analisi dinamica (eseguita) ✅

L'analisi **dinamica** è stata eseguita con il dynamic analyzer di MobSF su un
**emulatore Android 9 (API 28, `arm64-v8a`, immagine Google APIs)** con
**Frida 17.8.2**, `/system` scrivibile e CA di MobSF installata.
*Nota tecnica:* MobSF supporta la dynamic analysis fino ad **Android 11 (API 30)**;
si è scelto **Android 9** perché su Android 10+ `libart.so` è dentro l'**APEX ART**
e l'iniezione/spawn di Frida fallisce (`unable to load libart.so`) — su Android 9
la libreria è in `/system/lib64` e l'instrumentazione funziona in modo affidabile.

**Esito: nessuna vulnerabilità a runtime — conferma il risultato statico.**

- **Nessun componente esportato attaccabile.** L'activity tester ha avviato le 5
  Activity dell'app (la `MainActivity` di Flutter più Activity delle librerie
  `url_launcher`/Credentials/Google Play Services); il test sulle Activity
  **esportate non ha trovato nulla** (lista vuota) → nessuna superficie IPC
  esposta, in linea con l'analisi statica.
- **Traffico solo cifrato** (`has_cleartext = false`): nessun HTTP in chiaro. I
  domini contattati a runtime sono **solo infrastruttura di sistema Google/Android**
  (`*.gstatic.com`, `connectivitycheck.gstatic.com`, `android.googleapis.com/checkin`
  — i controlli di connettività del sistema operativo), **non** endpoint dell'app.
- **Nessun segreto in chiaro nello storage.** La sandbox dell'app conteneva solo
  file di default della WebView (`WebViewChromiumPrefs.xml`, `Web Data`) e cache
  benigna del motore Flutter; **nessun token/password in chiaro** nei `shared_prefs`.
  La sessione Supabase è gestita da `flutter_secure_storage` (cifrata tramite
  Android Keystore), non in chiaro su disco.
- **0 tracker** rilevati (su 432 firme note). Nessuna stringa base64 sospetta,
  nessuna scrittura in clipboard.
- **Una sola nota di hardening: assenza di certificate pinning**
  (`tls_misconfigured = true`). L'app si affida allo store di CA **di sistema**
  (comportamento standard dell'SDK Supabase); con una CA di sistema iniettata da
  MobSF il traffico risulta intercettabile, ma ciò richiede un dispositivo **già
  compromesso (root)**. Il pinning è una difesa **aggiuntiva e opzionale**, non un
  requisito — non è una vulnerabilità.

**Limiti onesti di questo test.** Gli hook di MobSF (API monitor / Droidmon)
intercettano le API **Java/Kotlin**, ma la logica di un'app **Flutter** gira in
**Dart** (`libapp.so`) e la rete passa per lo stack **BoringSSL di Dart**, non per
le API Java: per questo il monitoraggio runtime di MobSF cattura poco del codice
dell'app (API monitor vuoto) e **non vede il traffico applicativo verso Supabase**
— è un **limite noto** dell'analisi dinamica sulle app Flutter, non un segnale di
problemi. Inoltre l'esecuzione è stata **non interattiva** (nessun login reale),
quindi i flussi autenticati non sono stati esercitati a fondo. Per questi aspetti
la fonte primaria resta l'analisi statica, che risulta conforme (HTTPS
obbligatorio, permessi minimi, JWT lato server).

## Verifica dell'integrità

Ogni release pubblica lo **SHA-256** dell'APK nelle
[Release](https://github.com/alessiosavi/brain-break/releases). Confrontalo con
`shasum -a 256 <file>` / `sha256sum <file>` / `certutil -hashfile <file> SHA256`.
Al primo avvio, **Google Play Protect** analizza comunque l'app sul dispositivo.

## Scansioni automatiche (CI)

Oltre a questo triage curato a mano, ogni release viene analizzata
**automaticamente** da una pipeline CI (MobSF statico + VirusTotal). I report
sono allegati alla relativa
[release](https://github.com/alessiosavi/brain-break/releases) e un riepilogo
leggibile è in [`security/latest-scan.md`](./security/latest-scan.md) (storico in
[`security/history/`](./security/history/)). Questa pagina resta la fonte di
verità con il triage di ogni segnalazione.
