# Sicurezza — Brain Break

Questa pagina riporta in modo trasparente l'analisi di sicurezza dell'APK di
Brain Break, così puoi installarlo con fiducia.

- **App analizzata:** `brain-break-0.0.1-arm64-v8a.apk`
- **Strumento:** [MobSF](https://github.com/MobSF/Mobile-Security-Framework-MobSF) — analisi **statica**
- **Firma:** certificato di rilascio AppVibing (`CN=alessiosavi, O=AppVibing`)

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

## Analisi dinamica (non inclusa)

Questo report copre l'analisi **statica**. L'analisi **dinamica** di MobSF non è
stata eseguita perché richiede un emulatore/dispositivo Android collegato a
MobSF; senza di esso MobSF restituisce:

> *MobSF cannot find the android device identifier … set `ANALYZER_IDENTIFIER`
> in `~/.MobSF/config.py` or via `MOBSF_ANALYZER_IDENTIFIER`.*

Per eseguirla servono: un emulatore Android avviato (es. AVD/Genymotion con
MobSFy), l'ID dispositivo (`adb devices`) impostato in
`MOBSF_ANALYZER_IDENTIFIER`, quindi l'avvio della dynamic analysis dalla UI di
MobSF. Verificherebbe a runtime cose come il traffico TLS, l'archiviazione su
disco e le chiamate sensibili — aspetti che, staticamente, risultano già
conformi (HTTPS obbligatorio, nessun permesso invasivo, JWT lato server).

## Verifica dell'integrità

Ogni release pubblica lo **SHA-256** dell'APK nelle
[Release](https://github.com/alessiosavi/brain-break/releases). Confrontalo con
`shasum -a 256 <file>` / `sha256sum <file>` / `certutil -hashfile <file> SHA256`.
Al primo avvio, **Google Play Protect** analizza comunque l'app sul dispositivo.
