# Progetto_scuola_casino

Creato da: Daniele Mottura, Rikardo Babaj, Fabrizio Forcinito

## Analisi Requisiti
Il progetto richiede la creazione di un servizio, web o di una applicazione la quale usi un database. Per il progetto il nostro gruppo ha deciso di creare un sito web per le scommesse.
Esso dovrà fornire agli utenti una piattaforma web per scommettere e per il gioco d'azzardo, con la possibilità di creare un account simulato per provare la piattaforma utilizzando soldi virtuali non scambiabili. Inoltre sarà possibile ricaricare soldi tramite l'utilizzo di crypto valute.
Il sito web comunica con il server tramite API fornite dal backend.

## Descrizione

**Brawls Bets** è un progetto scolastico che simula una piattaforma di scommesse e gioco d'azzardo con denaro virtuale. L'applicazione è composta da:

- un **frontend Flutter/Dart** multipiattaforma con interfaccia Material Design;
- un **backend Flask/Python** che espone API HTTP per autenticazione, dati utente e giocate;
- un **motore casinò Python** che calcola gli esiti dei giochi;
- un **database MySQL** chiamato `Casino`.

Gli utenti possono registrarsi, effettuare il login, visualizzare il proprio bilancio e accedere alla dashboard dei giochi. In fase di registrazione è possibile scegliere tra:

- **account simulato**, con saldo iniziale virtuale di `5000` e indirizzo wallet generato automaticamente se non viene fornito;
- **account non simulato**, con saldo iniziale `0` e indirizzo wallet inserito dall'utente.

Dopo l'accesso l'utente può giocare a Roulette, Ice Fishing e tre slot machine tematiche. Ogni giocata invia al backend l'ID giocatore, la puntata e, quando necessario, la scelta dell'utente. Il backend controlla il saldo, calcola il risultato, aggiorna il bilancio nel database e restituisce il nuovo stato al frontend.

> Il progetto è una simulazione didattica: i fondi non sono reali e non sono scambiabili.

## Tecnologie utilizzate

### Frontend

- Flutter
- Dart
- Material Design
- Pacchetto `http` per comunicare con il backend
- Animazioni Flutter per dashboard, carte gioco e schermate di giocata

### Backend

- Python
- Flask
- Flask-CORS
- mysql-connector-python
- Dataclass Python per rappresentare i risultati dei giochi

### Schema Database

- Utente(<u>ID_Giocatore</u>, Nome, Cognome, Email, Password, Profile_Picture, FK_Fidalty, Fk_Balance, FK_Prefered_Game)
- Bonus(<u>ID_Bonus</u>, Punti, Tipo_Bonus)
- Account_Balance(<u>ID_Balance</u>, Crypto_Address, Current_Balance, Account_Type, FK_Movimento)
- Movimenti(<u>ID_Movimenti</u>, Data, Tipo_Movimento, Importo)
- Giochi(<u>ID_Giochi</u>, Nome, Categoria)

## Frontend
Il frontend è realizzato tramite Flutter per permettere all'utente di accedere alla piattaforma da più dispositivi e piattaforme. L'interfaccia include login, registrazione, dashboard utente, bilancio aggiornato, griglia dei giochi disponibili e pagine dedicate alla giocata con animazioni e risultati.

## Backend
Il backend è realizzato con Flask, espone API JSON e usa CORS per permettere le richieste dal frontend. Le operazioni principali sono login, registrazione, recupero dati utente, lista giochi e gestione delle giocate con aggiornamento atomico del bilancio.

### Database

- MySQL

## Struttura del progetto

```text
.
├── Backend/
│   ├── main.py              # Server Flask e definizione delle API
│   ├── Database_Handler.py  # Connessione MySQL, utenti, bilancio e giocate
│   └── Casino_Handler.py    # Motore dei giochi: roulette, ice fishing e slot
├── frontend/
│   ├── lib/main.dart        # Interfaccia Flutter, sessione utente, dashboard e giochi
│   ├── test/widget_test.dart # Test Flutter della schermata login e dei giochi
│   └── pubspec.yaml         # Configurazione e dipendenze Flutter
├── Database_script.sql      # Script SQL per creare database, tabelle e giochi iniziali
├── DiagrammaER.er           # Diagramma ER del database
└── README.md
```

## Schema database

Lo script `Database_script.sql` crea il database `Casino` e le seguenti tabelle:

- `Giochi(ID_Gioco, Nome, Categoria)`
- `Movimenti(ID_Movimento, Data, Tipo_Movimento, Importo)`
- `Bonus(ID_Bonus, Punti, Tipo_Bonus)`
- `Account_Balance(ID_Balance, Crypto_address, Current_Balance, Account_Type, FK_Movimenti)`
- `Utente(ID_Giocatore, Nome, Cognome, Email, Password, Profile_Picture, FK_fidalty, FK_Balance, FK_Prefered_Game)`

Relazioni principali:

- ogni `Utente` è collegato a un record di `Account_Balance` tramite `FK_Balance`;
- un `Utente` può avere un bonus tramite `FK_fidalty`;
- un `Utente` può avere un gioco preferito tramite `FK_Prefered_Game`;
- `Account_Balance` può essere collegato a un movimento tramite `FK_Movimenti`.

Lo script inserisce anche i giochi iniziali disponibili nella dashboard:

- `Roulette`, categoria `Tavolo`;
- `Ice Fishing`, categoria `Arcade`;
- `Slot Frutta`, categoria `Slot`;
- `Slot Cristalli`, categoria `Slot`;
- `Slot Fulmini`, categoria `Slot`.

## Backend

Il backend si trova nella cartella `Backend/` ed espone un server Flask in ascolto su `0.0.0.0`. La connessione al database è configurata in `Database_Handler.py` con questi parametri:

```python
host="127.0.0.1"
user="root"
password=""
database="Casino"
```

### API disponibili

#### `POST /login`

Effettua il login di un utente e restituisce i dati di sessione necessari al frontend.

Body JSON richiesto:

```json
{
  "email": "utente@example.com",
  "password": "password"
}
```

Risposte:

- `200` con JSON contenente `id_giocatore`, `nome` e `bilancio` se le credenziali sono accettate;
- `500` se il login fallisce;
- `501` per metodi non supportati.

Esempio risposta `200`:

```json
{
  "id_giocatore": 1,
  "nome": "Mario",
  "bilancio": 5000
}
```

#### `POST /register`

Registra un nuovo utente, crea il relativo record in `Account_Balance` e restituisce i dati di sessione.

Body JSON richiesto:

```json
{
  "name": "Mario",
  "surname": "Rossi",
  "email": "mario.rossi@example.com",
  "password": "password",
  "account_type": true,
  "address": "wallet-address"
}
```

Note sul campo `account_type`:

- `true`: account simulato con saldo iniziale `5000`; se `address` è vuoto viene generato un indirizzo numerico casuale;
- `false`: account con saldo iniziale `0` e indirizzo wallet passato dal frontend.

Risposte:

- `200` con JSON contenente `id_giocatore`, `nome` e `bilancio` se la registrazione va a buon fine;
- `500` se la registrazione fallisce;
- `501` per metodi non supportati.

#### `GET /MainApp?id_giocatore=<id>`

Recupera i dati aggiornati dell'utente dopo login, registrazione o ritorno alla dashboard.

Parametri query:

- `id_giocatore`: ID numerico del giocatore.

Risposte:

- `200` con JSON contenente `id_giocatore`, `nome` e `bilancio`;
- `400` se manca `id_giocatore`;
- `404` se il giocatore non esiste.

#### `GET /get_slot`

Restituisce l'elenco dei giochi presenti nella tabella `Giochi` nel formato JSON con campi `Nome` e `Categoria`.

#### `POST /games/roulette/play`

Esegue una giocata alla Roulette.

Body JSON richiesto:

```json
{
  "id_giocatore": 1,
  "bet": 50,
  "choice": "red"
}
```

La roulette estrae un numero da `0` a `36`, assegna il colore e supporta più tipi di puntata:

- colori: `red`, `black`, `green`;
- pari/dispari: `even`, `odd`;
- numeri singoli: da `number_0` a `number_36`;
- gruppi di numeri: `low` (`1-18`), `high` (`19-36`), `dozen_1`, `dozen_2`, `dozen_3`, `column_1`, `column_2`, `column_3`.

Le vincite sono calcolate con moltiplicatori differenti: `2x` per colori rosso/nero, pari/dispari e metà tavolo, `3x` per dozzine/colonne, `14x` per verde e `36x` per numero singolo.

#### `POST /games/ice-fishing/play`

Esegue una giocata a Ice Fishing, gioco ispirato a una ruota con moltiplicatori e bonus.

Body JSON richiesto:

```json
{
  "id_giocatore": 1,
  "bet": 50,
  "choice": "2x"
}
```

Scelte valide:

- `1x`;
- `2x`;
- `5x`;
- `10x`;
- `coin_flip`;
- `pachinko`;
- `ice_bonus`.

La ruota usa pesi diversi per i segmenti e può attivare bonus con moltiplicatori aggiuntivi.

#### `POST /games/slots/<theme>/play`

Esegue una giocata su una slot machine. Il tema viene passato nel percorso dell'endpoint.

Temi disponibili:

- `fruit`, per `Slot Frutta`;
- `crystal`, per `Slot Cristalli`;
- `thunder`, per `Slot Fulmini`.

Body JSON richiesto:

```json
{
  "id_giocatore": 1,
  "bet": 50
}
```

Le slot estraggono tre simboli casuali. Le vincite dipendono da coppie, tris e jackpot, con moltiplicatori differenti in base al tema.

#### Risposta delle API di gioco

Le API di gioco restituiscono un JSON con l'esito della giocata e il saldo aggiornato.

Esempio:

```json
{
  "game": "Roulette",
  "bet": 50,
  "payout": 100,
  "profit": 50,
  "balance": 5050,
  "result": {
    "number": 18,
    "color": "red",
    "choice": "red",
    "choiceLabel": "Rosso",
    "betType": "colore",
    "multiplier": 2
  },
  "message": "La pallina si ferma su 18 red. Giocata: Rosso."
}
```

Errori comuni:

- `400` se mancano `id_giocatore` o `bet`, se la puntata non è valida, se il saldo è insufficiente o se la scelta del gioco non è valida;
- `404` se il giocatore non esiste.

## Frontend

Il frontend si trova nella cartella `frontend/` ed è una applicazione Flutter chiamata **Brawls Bets**.

### Schermate e rotte

Le rotte principali definite in `frontend/lib/main.dart` sono:

- `/`: schermata di login;
- `/Register`: schermata di registrazione;
- `/MainApp`: schermata principale dopo login o registrazione riusciti.

Oltre alle rotte principali, l'apertura di un gioco avviene tramite una pagina Flutter dedicata (`GamePlayPage`) raggiunta dalla dashboard con `Navigator.push`.

### Funzionalità implementate

- Login con campi `Email` e `Password`.
- Registrazione con campi `Email`, `Password`, `Name`, `Surname`.
- Checkbox `Simulated Account` per scegliere il tipo di account.
- Campo `Wallet Address` visibile solo quando l'account non è simulato.
- Invio dei dati al backend in formato JSON.
- Salvataggio dei dati di sessione nel frontend tramite `UserSession`.
- Recupero dei dati aggiornati dell'utente tramite endpoint `/MainApp`.
- Dashboard con nome utente, ID giocatore e bilancio in crediti.
- Griglia responsive dei giochi disponibili.
- Carte gioco con immagini, colori, icone e descrizioni.
- Pagine di giocata dedicate per Roulette, Ice Fishing e slot.
- Campo puntata con validazione lato frontend.
- Selettore della scelta quando il gioco lo richiede.
- Chiamata al backend per eseguire la giocata.
- Aggiornamento del bilancio dopo ogni giocata riuscita.
- Visualizzazione di payout, profitto, messaggio e dettagli del risultato.
- Animazioni grafiche per roulette, ruota Ice Fishing, slot e particelle.
- Logout con ritorno alla schermata di login.

### Giochi disponibili nel frontend

- **Roulette**: scelta tra colori, numeri singoli `0-36`, pari/dispari e gruppi di numeri come metà tavolo, dozzine e colonne.
- **Ice Fishing**: ruota con segmenti numerici e bonus `Coin Flip`, `Pachinko`, `Ice Bonus`.
- **Slot Frutta**: slot con simboli frutta e jackpot.
- **Slot Cristalli**: slot con gemme e moltiplicatori più alti.
- **Slot Fulmini**: slot ad alta volatilità con moltiplicatori maggiori.

### Endpoint usati dal frontend

Il frontend invia le richieste a:

- `http://127.0.0.1:5000/login`
- `http://127.0.0.1:5000/register`
- `http://127.0.0.1:5000/MainApp?id_giocatore=<id>`
- `http://127.0.0.1:5000/games/roulette/play`
- `http://127.0.0.1:5000/games/ice-fishing/play`
- `http://127.0.0.1:5000/games/slots/fruit/play`
- `http://127.0.0.1:5000/games/slots/crystal/play`
- `http://127.0.0.1:5000/games/slots/thunder/play`

Se si esegue l'app da un dispositivo fisico, da un emulatore o da un container, potrebbe essere necessario sostituire `127.0.0.1` con l'indirizzo IP della macchina che esegue il backend.

## Installazione ed esecuzione

### 1. Preparare il database

Accedere a MySQL ed eseguire lo script:

```bash
mysql -u root < Database_script.sql
```

Lo script crea il database `Casino`, tutte le tabelle richieste e popola la tabella `Giochi` con i giochi iniziali.

### 2. Avviare il backend

Installare le dipendenze Python:

```bash
python -m pip install flask flask-cors mysql-connector-python
```

Avviare il server Flask:

```bash
cd Backend
python main.py
```

Il backend sarà disponibile sulla porta predefinita di Flask, cioè `5000`.

### 3. Avviare il frontend

Installare le dipendenze Flutter:

```bash
cd frontend
flutter pub get
```

Eseguire l'app:

```bash
flutter run
```

Per l'esecuzione web:

```bash
flutter run -d chrome
```

### 4. Eseguire i test Flutter

Dalla cartella `frontend/` è possibile eseguire:

```bash
flutter test
```

I test verificano la presenza della schermata di login e dei giochi principali nella dashboard.

## Stato attuale del progetto

Funzionalità già presenti nel codice:

- database relazionale MySQL con utenti, giochi, bonus, movimenti e bilanci account;
- popolamento iniziale della tabella `Giochi`;
- API Flask per login, registrazione, recupero dati utente e recupero dei giochi;
- API Flask per eseguire giocate su Roulette, Ice Fishing e slot;
- supporto CORS nel backend;
- motore casinò separato dal database in `Casino_Handler.py`;
- validazione backend di puntata, saldo, giocatore e scelta del gioco;
- aggiornamento del bilancio dopo ogni giocata;
- interfaccia Flutter con login, registrazione e schermata principale;
- dashboard Flutter con bilancio aggiornato, ID giocatore e griglia dei giochi;
- pagine Flutter dedicate alle giocate con animazioni e riepilogo risultato;
- creazione automatica del bilancio account durante la registrazione;
- test Flutter per login e lista giochi.

Funzionalità predisposte o migliorabili:

- gestione e visualizzazione dello storico dei movimenti;
- gestione più dettagliata degli errori nel frontend;
- protezione delle password tramite hashing;
- validazione più completa degli input lato frontend e backend;
- configurazione esterna per credenziali database e URL del backend;
- ricarica del saldo tramite crypto valute simulate;
- uso effettivo di bonus/fidelity e gioco preferito;
- ampliamento dei test backend e frontend.
