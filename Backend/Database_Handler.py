import mysql.connector, random

class Database():
    def __init__(self) -> None:
        self.db = mysql.connector.connect(host="127.0.0.1", user="root", password="", database="Casino")
        self.cursor = self.db.cursor()
        pass

    def login(self, email: str, password: str):
        self.cursor.execute(f"SELECT ID_Giocatore FROM Utente WHERE Email LIKE '{email}' and Password LIKE '{password}'")
        row = self.cursor.fetchone()
        if row == '':
            return False
        else:
            return True
        
    def register(self, name: str, surname: str, email: str, password: str, account_type: bool, address: str):
        try:
            if address == '':
                address = str(random.randrange(100000)) 
            self.cursor.execute(f"INSERT INTO Balance (Crypto_Address, Account_Type) VALUES({address}, {account_type})")
            self.cursor.execute(f"INSERT INTO Utente (Nome, Cognome, Email, Password, FK_Balance) VALUES ({name}, {surname}, {email}, {password}, SELECT ID_Balance FROM Balance WHERE Crypto_Address LIKE '{address}')")
            return True
        except:
            return False

    def get_slot(self):
        self.cursor.execute(f"SELECT Nome, Categoria FROM Giochi")
        return self.cursor.fetchall()
