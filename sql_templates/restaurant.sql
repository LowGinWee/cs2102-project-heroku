CREATE TABLE Restaurant (
	RName varchar(100),
	Location varchar(100),
	CuisineType varchar(30) NOT NULL,
	OpeningHours varchar(20) NOT NULL,
	primary key (rname, location)
);
	