# Brain Break 🧠

> Perché non mi piace guardare la TV per informarmi.

## L'idea

Non mi piace guardare la televisione per sapere cosa succede nel mondo. I
telegiornali sono lunghi, ripetitivi e pieni di rumore: per arrivare alla
notizia che ti interessa devi aspettare, e alla fine ti ricordi poco o niente.

Da qui nasce **Brain Break**.

Brain Break trasforma le notizie in un gioco. Ogni giorno trovi un round di
dieci domande sui fatti del giorno **prima** — cronaca, politica, sport,
cultura, tecnologia, mondo. Rispondi in un minuto, una domanda alla volta, e
mentre giochi ti accorgi di tutto quello che è successo ieri.

Invece di startene seduto davanti al telegiornale, ti prendi una pausa — un
*brain break*, appunto — e ti informi divertendoti. Impari senza nemmeno
accorgertene, e torni il giorno dopo per non interrompere la serie.

Niente palinsesti, niente attesa. Solo tu, un minuto al giorno, e le notizie
che contano.

## Come funziona

- 🗓️ **Un round al giorno**, dieci domande sui fatti di ieri.
- ⏱️ **Un minuto di tempo**, una risposta alla volta.
- 🔥 **Serie giornaliera**: torna ogni giorno per non interromperla.
- 🏆 **Classifica** per sfidare gli altri giocatori.

## Scarica e installa (Android)

L'app si scarica dalla pagina delle
**[Release](https://github.com/alessiosavi/brain-break/releases/latest)**:

1. Apri l'ultima release e scarica `brain-break-<versione>-universal.apk` (APK
   universale: funziona su tutti i telefoni Android, vecchi e nuovi).
2. Sul telefono apri il file e, se richiesto, consenti **«Installa app
   sconosciute»** per il browser o il gestore file.
3. Apri l'app, registrati e inizia a giocare.

## È sicuro?

Trasparenza totale: l'analisi di sicurezza completa (scansione statica MobSF,
con triage di ogni segnalazione) è in **[SECURITY.md](./SECURITY.md)**. In sintesi:

**Permessi richiesti** — nessun accesso a posizione, contatti, fotocamera,
microfono, SMS o file personali:

- `INTERNET` — per comunicare con il server.
- `POST_NOTIFICATIONS` + `VIBRATE` — per avvisarti quando puoi rigiocare.
- `USE_BIOMETRIC` / `USE_CREDENTIALS` — per l'accesso sicuro (passkey).

**Verifica l'integrità del file** — ogni release pubblica lo **SHA-256**
dell'APK: confrontalo con `shasum -a 256 <file>` (macOS), `sha256sum <file>`
(Linux) o `certutil -hashfile <file> SHA256` (Windows).

L'app è firmata con un certificato di rilascio dedicato (**CN=Brain Break,
O=Alessio Savi**) e, al momento dell'installazione, viene analizzata
automaticamente da **Google Play Protect**.
