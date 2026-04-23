CREATE DATABASE Casino;

CREATE TABLE Giochi (
	ID_Gioco int NOT NULL UNIQUE,
	Nome varchar(255) NOT NULL,
	Categoria varchar(255) NOT NULL,
	PRIMARY KEY(ID_Gioco)
);

CREATE TABLE Movimenti (
	ID_Movimento int NOT NULL UNIQUE,
	Data date NOT NULL,
	Tipo_Movimento varchar(255) NOT NULL,
	Importo float NOT NULL,
	PRIMARY KEY(ID_Movimento)
);

CREATE TABLE Bonus (
	ID_Bonus int NOT NULL UNIQUE,
	Punti int NOT NULL,
	Tipo_Bonus varchar(255) NOT NULL,
	PRIMARY KEY(ID_Bonus)
);

CREATE TABLE Account_Balance (
	ID_Balance int NOT NULL UNIQUE,
	Crypto_address varchar(255),
	Current_Balance float NOT NULL,
	Account_Type varchar(255) NOT NULL,
	FK_Movimenti int,
	PRIMARY KEY(ID_Balance),
	FOREIGN KEY(FK_Movimenti) REFERENCES Movimenti(ID_Movimento)
);

CREATE TABLE Utente (
	ID_Giocatore int NOT NULL UNIQUE,
	Nome varchar(255) NOT NULL,
	Cognome varchar(255) NOT NULL,
	Email varchar(255) NOT NULL,
	Password varchar(255) NOT NULL,
	Profile_Picture varbinary(max),
	FK_fidalty int,
	FK_Balance int NOT NULL,
	FK_Prefered_Game int,
	PRIMARY KEY(ID_Giocatore)
	FOREIGN KEY(FK_fidalty) REFERENCES Bonus(ID_Bonus)
	FOREIGN KEY(FK_Balance) REFERENCES Account_Balance(ID_Balance)
	FOREIGN KEY(FK_Prefered_Game) REFERENCES Giochu(ID_Gioco)
);
