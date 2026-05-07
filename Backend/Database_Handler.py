import random

import mysql.connector


class Database():
    def __init__(self) -> None:
        self.db = mysql.connector.connect(host="127.0.0.1", user="root", password="", database="Casino")
        self.cursor = self.db.cursor(dictionary=True)

    def login(self, email: str, password: str):
        self.cursor.execute(
            """
            SELECT
                Utente.ID_Giocatore AS id_giocatore,
                Utente.Nome AS nome,
                Account_Balance.Current_Balance AS bilancio
            FROM Utente
            INNER JOIN Account_Balance ON Utente.FK_Balance = Account_Balance.ID_Balance
            WHERE Utente.Email = %s AND Utente.Password = %s
            LIMIT 1
            """,
            (email, password),
        )
        return self.cursor.fetchone()

    def register(self, name: str, surname: str, email: str, password: str, account_type: bool, address: str):
        try:
            initial_balance = 5000 if account_type else 0
            wallet_address = address if address else str(random.randrange(100000))
            self.cursor.execute(
                """
                INSERT INTO Account_Balance (Crypto_Address, Account_Type, Current_Balance)
                VALUES (%s, %s, %s)
                """,
                (wallet_address, account_type, initial_balance),
            )
            balance_id = self.cursor.lastrowid
            self.cursor.execute(
                """
                INSERT INTO Utente (Nome, Cognome, Email, Password, FK_Balance)
                VALUES (%s, %s, %s, %s, %s)
                """,
                (name, surname, email, password, balance_id),
            )
            self.db.commit()
            return self.get_user_data(self.cursor.lastrowid)
        except Exception as e:
            print(e)
            self.db.rollback()
            return None

    def get_user_data(self, id_giocatore: int):
        self.cursor.execute(
            """
            SELECT
                Utente.ID_Giocatore AS id_giocatore,
                Utente.Nome AS nome,
                Account_Balance.Current_Balance AS bilancio
            FROM Utente
            INNER JOIN Account_Balance ON Utente.FK_Balance = Account_Balance.ID_Balance
            WHERE Utente.ID_Giocatore = %s
            LIMIT 1
            """,
            (id_giocatore,),
        )
        return self.cursor.fetchone()

    def get_slot(self):
        self.cursor.execute("SELECT Nome, Categoria FROM Giochi")
        return self.cursor.fetchall()
