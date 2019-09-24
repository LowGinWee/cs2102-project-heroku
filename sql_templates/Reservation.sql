CREATE TABLE Reservation (
	username			varchar(50)		NOT NULL,
	RName				varchar(100) 	NOT NULL,
	Location			varchar(100)	NOT NULL,
	ReservationTime  	integer 		REFERENCES Details,
	ReservationDate		varchar(10)		REFERENCES Details,
	PRIMARY KEY (ReservationTime, ReservationDate),
	FOREIGN KEY (username) REFERENCES UserAccount,
	FOREIGN KEY (RName) REFERENCES Restaurant,
	FOREIGN KEY (Location) REFERENCES Restaurant,
);