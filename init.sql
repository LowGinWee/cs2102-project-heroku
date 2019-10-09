DROP TABLE IF EXISTS userAccount;
DROP TABLE IF EXISTS preferences;
DROP TABLE IF EXISTS Restaurant;

CREATE TABLE userAccount (
    username VARCHAR(50) PRIMARY KEY,
    email VARCHAR(355) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    awardPoints INTEGER DEFAULT 0
);

CREATE TABLE preferences (
    username VARCHAR(50) PRIMARY KEY,
    cuisinetype VARCHAR(50),
    prefTime INTEGER,
    location VARCHAR(50),
    budget INTEGER,
    FOREIGN KEY (username) REFERENCES userAccount (username) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Restaurant (
	RName varchar(100),
	Location varchar(100),
	CuisineType varchar(30) NOT NULL,
	OpeningHours varchar(20) NOT NULL,
	primary key (rname, location)
);
