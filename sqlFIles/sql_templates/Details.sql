CREATE TABLE Details (
	ReservationTime  	integer 	PRIMARY KEY,
	ReservationDate		varchar(10)	PRIMARY KEY,
	NumDiners			integer		NOT NULL,
	Confirmation		boolean		NOT NULL,
	Rating				integer,
);