CREATE TABLE restaurant (
	Name 			varchar(100) 	PRIMARY KEY,
	Location 		varchar(100) 	PRIMARY KEY,
	CuisineType		varchar(30)		NOT NULL,
	Rating			integer,
	OpeningHours	varchar(20)		NOT NULL,
	AveragePrice	numeric(5,2)
);
	