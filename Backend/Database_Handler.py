import mysql.connector

class Database():
    def __init__(self) -> None:
        self.db = mysql.connector.connect(host="127.0.0.1", user="root", password="password", database="main")
        self.cursor = self.db.cursor()
        pass

    def login(self, email: str, password: str):
        self.cursor.execute(f"SELECT ID_Giocatore FROM Utente WHERE Email LIKE '{email}' and Passwork LIKE '{password}'")
        row = self.cursor.fetchone()
        if row == '':
            return False
        else:
            return True
