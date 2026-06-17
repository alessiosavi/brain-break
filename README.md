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
accorgertene, e torni il giorno dopo per continuare la tua striscia.

Niente palinsesti, niente attesa. Solo tu, un minuto al giorno, e le notizie
che contano.

## Come funziona

- 🗓️ **Un round al giorno**, dieci domande sui fatti di ieri.
- ⏱️ **Un minuto di tempo**, una risposta alla volta.
- 🔥 **Striscia giornaliera**: torna ogni giorno per non perderla.
- 🏆 **Classifica** per sfidare gli altri giocatori.

## Scarica e installa (Android)

1. Scarica [`brain-break-armeabi-v7a.apk`](./brain-break-armeabi-v7a.apk).
2. Sul telefono apri il file e, se richiesto, consenti **«Installa app
   sconosciute»** per il browser o il gestore file.
3. Apri l'app, registrati e inizia a giocare.

> Questa build è compilata per `armeabi-v7a` (Android a 32 bit) e gira sulla
> grande maggioranza dei telefoni, anche un po' datati.

## È sicuro?

Trasparenza totale — ecco cosa chiede l'app e come verificarlo tu stesso.

**Permessi richiesti** (nessun accesso a posizione, contatti, fotocamera,
microfono, SMS o file personali):

- `INTERNET` — per comunicare con il server.
- `POST_NOTIFICATIONS` + `VIBRATE` — per avvisarti quando puoi rigiocare.
- `USE_BIOMETRIC` / `USE_CREDENTIALS` — per l'accesso sicuro (passkey).

**Verifica l'integrità del file** (SHA-256):

```
047129bbe25132a32321fd269b0873c0d04ca92a0ca4af9fb3610e5607891872  brain-break-armeabi-v7a.apk
```

Controllalo con `shasum -a 256 <file>` (macOS), `sha256sum <file>` (Linux) o
`certutil -hashfile <file> SHA256` (Windows): deve corrispondere esattamente.

L'app è firmata con il certificato di rilascio **AppVibing** e, al momento
dell'installazione, viene analizzata automaticamente da **Google Play Protect**.
