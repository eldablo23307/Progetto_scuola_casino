# Progetto_scuola_casino

Creato da: Daniele Mottura, Rikardo Babaj, Fabrizio Forcinito

## Analisi Requisiti
Il progetto richiede la creazione di un servizio, web o di una applicazione la quale usi un database, per il progetto il nostro gruppo a deciso di creare un sito web per le scommesse.
Esso dovrà fornire agli utenti una piattaforma web per scommettere e per il gioco d'azzardo, sarà possibile la creazione di un account simulato per provare la piattaforma utilizzando soldi virtuali non scambiabili. Inoltre sarà possibile ricaricare soldi tramite l'utilizzo di crypto valute.
Il sito web comunicherà con il server tramite API, fornita da quest'ultimo.
## Descrizione

**Brawls Bets** è un progetto scolastico che simula una piattaforma di scommesse e gioco d'azzardo con denaro virtuale. L'applicazione è composta da:

- un **frontend Flutter/Dart** multipiattaforma;
- un **backend Flask/Python** che espone API HTTP;
- un **database MySQL** chiamato `Casino`.

Gli utenti possono registrarsi, effettuare il login e accedere alla schermata principale dell'app. In fase di registrazione è possibile scegliere tra:

- **account simulato**, con saldo iniziale virtuale di `5000` e indirizzo wallet generato automaticamente se non viene fornito;
- **account non simulato**, con saldo iniziale `0` e indirizzo wallet inserito dall'utente.

> Il progetto è una simulazione didattica: i fondi non sono reali e non sono scambiabili.

## Tecnologie utilizzate

### Frontend

- Flutter
- Dart
- Material Design
- Pacchetto `http` per comunicare con il backend

### Backend

- Python
- Flask
- Flutter
- Dart

### Schema Database
- Utente(<u>ID_Giocatore</u>, Nome, Cognome, Email, Password, Profile_Picture, FK_Fidalty, Fk_Balance, FK_Prefered_Game)
- Bonus(<u>ID_Bonus</u>, Punti, Tipo_Bonus)
- Account_Balance(<u>ID_Balance</u>, Crypto_Address, Current_Balance, Account_Type, FK_Movimento)
- Movimenti(<u>ID_Movimenti</u>, Data, Tipo_Movimento, Importo)
- Giochi(<u>ID_Giochi</u>, Nome, Categoria)

## Frontend
Il frontend è realizzato tramite flutter per permettere all'utente da utilizzare qualsiasi piattaforma che vuole per accedere al sito
## Backend
- Flask-CORS
- mysql-connector-python

### Database

- MySQL

## Struttura del progetto

```text
.
├── Backend/
│   ├── main.py              # Server Flask e definizione delle API
│   ├── Database_Handler.py  # Connessione MySQL e operazioni su utenti/giochi
│   └── Casino_Handler.py    # File predisposto per logiche future del casinò
├── frontend/
│   ├── lib/main.dart        # Interfaccia Flutter, login, registrazione e main page
│   └── pubspec.yaml         # Configurazione e dipendenze Flutter
├── Database_script.sql      # Script SQL per creare database e tabelle
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

Effettua il login di un utente.

Body JSON richiesto:

```json
{
  "email": "utente@example.com",
  "password": "password"
}
```

Risposte:

- `200` con testo `Logged Succesfully` se le credenziali sono accettate;
- `500` se il login fallisce;
- `501` per metodi non supportati.

#### `POST /register`

Registra un nuovo utente e crea il relativo record in `Account_Balance`.

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

- `200` con testo `Register Succesfully` se la registrazione va a buon fine;
- `500` se la registrazione fallisce;
- `501` per metodi non supportati.

#### `GET /get_slot`

Restituisce l'elenco dei giochi presenti nella tabella `Giochi` nel formato `(Nome, Categoria)`.

## Frontend

Il frontend si trova nella cartella `frontend/` ed è una applicazione Flutter chiamata **Brawls Bets**.

### Schermate e rotte

Le rotte principali definite in `frontend/lib/main.dart` sono:

- `/`: schermata di login;
- `/Register`: schermata di registrazione;
- `/MainApp`: schermata principale dopo login o registrazione riusciti.

### Funzionalità implementate

- Login con campi `Email` e `Password`.
- Registrazione con campi `Email`, `Password`, `Name`, `Surname`.
- Checkbox `Simulated Account` per scegliere il tipo di account.
- Campo `Wallet Address` visibile solo quando l'account non è simulato.
- Invio dei dati al backend in formato JSON.
- Navigazione automatica alla schermata principale quando il backend risponde con codice `200`.

### Endpoint usati dal frontend

Il frontend invia le richieste a:

- `http://127.0.0.1:5000/login`
- `http://127.0.0.1:5000/register`

Se si esegue l'app da un dispositivo fisico, da un emulatore o da un container, potrebbe essere necessario sostituire `127.0.0.1` con l'indirizzo IP della macchina che esegue il backend.

## Installazione ed esecuzione

### 1. Preparare il database

Accedere a MySQL ed eseguire lo script:

```bash
mysql -u root < Database_script.sql
```

Lo script crea il database `Casino` e tutte le tabelle richieste.

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

## Stato attuale del progetto

Funzionalità già presenti nel codice:

- database relazionale MySQL con utenti, giochi, bonus, movimenti e bilanci account;
- API Flask per login, registrazione e recupero dei giochi;
- supporto CORS nel backend;
- interfaccia Flutter con login, registrazione e schermata principale;
- creazione automatica del bilancio account durante la registrazione.

Funzionalità predisposte o migliorabili:

- popolamento iniziale della tabella `Giochi`;
- visualizzazione dei giochi nella schermata principale;
- gestione più dettagliata degli errori nel frontend;
- protezione delle password e validazione degli input;
- configurazione esterna per credenziali database e URL del backend;
- implementazione della logica di gioco in `Casino_Handler.py`.
