CREATE DATABASE Casino;
USE Casino;
CREATE TABLE Giochi (
	ID_Gioco int PRIMARY KEY AUTO_INCREMENT,
	Nome varchar(255) NOT NULL,
	Categoria varchar(255) NOT NULL
);

CREATE TABLE Movimenti (
	ID_Movimento int PRIMARY KEY AUTO_INCREMENT,
	Data date NOT NULL,
	Tipo_Movimento varchar(255) NOT NULL,
	Importo float NOT NULL
);

CREATE TABLE Bonus (
	ID_Bonus int PRIMARY KEY AUTO_INCREMENT,
	Punti int NOT NULL,
	Tipo_Bonus varchar(255) NOT NULL
);

CREATE TABLE Account_Balance (
	ID_Balance int PRIMARY KEY AUTO_INCREMENT,
	Crypto_address varchar(255),
	Current_Balance float NOT NULL,
	Account_Type varchar(255) NOT NULL,
	FK_Movimenti int,
	FOREIGN KEY(FK_Movimenti) REFERENCES Movimenti(ID_Movimento)
);

CREATE TABLE Utente (
	ID_Giocatore int PRIMARY KEY AUTO_INCREMENT,
	Nome varchar(255) NOT NULL,
	Cognome varchar(255) NOT NULL,
	Email varchar(255) NOT NULL,
	Password varchar(255) NOT NULL,
	Profile_Picture varchar(255),
	FK_fidalty int,
	FK_Balance int NOT NULL,
	FK_Prefered_Game int,
	FOREIGN KEY(FK_fidalty) REFERENCES Bonus(ID_Bonus),
	FOREIGN KEY(FK_Balance) REFERENCES Account_Balance(ID_Balance),
	FOREIGN KEY(FK_Prefered_Game) REFERENCES Giochi(ID_Gioco)
);

INSERT INTO Giochi (Nome, Categoria) VALUES
('Roulette', 'Tavolo'),
('Ice Fishing', 'Arcade'),
('Slot Frutta', 'Slot'),
('Slot Cristalli', 'Slot'),
('Slot Fulmini', 'Slot'),
('Gate of Olympus', 'Slot'),
('Blackjack', 'Tavolo');
