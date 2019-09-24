CREATE TABLE Reservation (
	username	varchar(50)		REFERENCES UserAccount,
	RName		varchar(100) 	REFERENCES Restaurant,
	Location	varchar(100)	REFERENCES Restaurant,
	PRIMARY KEY (username, RName, Location)
);