# Progetto_scuola_casino
Creato da: Daniele Mottura, Rikardo Babaj, Fabrizio Forcinito

## Analisi Requisiti
Il progetto richiede la creazione di un servizio, web o di una applicazione la quale usi un database, per il progetto il nostro gruppo a deciso di creare un sito web per le scommesse.
Esso dovrà fornire agli utenti una piattaforma web per scommettere e per il gioco d'azzardo, sarà possibile la creazione di un account simulato per provare la piattaforma utilizzando soldi virtuali non scambiabili. Inoltre sarà possibile ricaricare soldi tramite l'utilizzo di crypto valute.
Il sito web comunicherà con il server tramite API, fornita da quest'ultimo.

### Tecnologie Utilizzate
- MySQL
- Python
- Flask
- HTML
- CSS
- Jinjia

### Schema Database
Utente(<u>ID_Giocatore</u>, Nome, Cognome, Email, Password, Profile_Picture, FK_Fidalty, Fk_Balance, FK_Prefered_Game)\n
Bonus(<u>ID_Bonus</u>, Punti, Tipo_Bonus)\n
Account_Balance(<u>ID_Balance</u>, Crypto_Address, Current_Balance, Account_Type, FK_Movimento)\n
Movimenti(<u>ID_Movimenti</u>, Data, Tipo_Movimento, Importo)\n
Giochi(<u>ID_Giochi</u>, Nome, Categoria)\n
