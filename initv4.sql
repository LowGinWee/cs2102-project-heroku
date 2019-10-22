

/*
--ORIGINAL
DROP TABLE IF EXISTS userAccount;
CREATE TABLE userAccount (
    username VARCHAR(50) PRIMARY KEY,
    email VARCHAR(355) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    awardPoints INTEGER DEFAULT 0
);

DROP TABLE IF EXISTS preferences;
CREATE TABLE preferences (
    username VARCHAR(50) PRIMARY KEY,
    cuisinetype VARCHAR(50),
    prefTime INTEGER, -- TAKE OUT?
    location VARCHAR(50),
    budget INTEGER,
    FOREIGN KEY (username) REFERENCES userAccount (username) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Restaurant;
CREATE TABLE Restaurant (
	RName varchar(100),
	Location varchar(100),
	CuisineType varchar(30) NOT NULL,
	OpeningHours varchar(20) NOT NULL,
	primary key (rname, location)
);
*/

/*
UNSURE: 
-Should we keep time/date in reservation/claims? I haven't seen any examples of relations having primary keys.
We may have to implement Availability entities for this, for now i put time/date in relation.

UPDATES:
- We are lacking entity sets in our current diagram? Not sure if weak entity sets double count.
- Why nickname for preferences?
Weak entity sets dont have primary keys that lead straight to userAccount, 
might as well put it under userAccount if we use same key. Users can use nickname
to show write reviews maybe? Thoughts?
- Adjusted all weak entity sets relations to "Has" to convert to SQL.
- Favourites is now a relation NOT an entity 
- "Food" all falls into their respective Menu (for ease of conversion to SQL)   
*/

--Updated
DROP TABLE IF EXISTS userAccount CASCADE;
CREATE TABLE userAccount (
username VARCHAR(50) UNIQUE PRIMARY KEY, -- for login purposes unique
email VARCHAR(355) UNIQUE NOT NULL,
password VARCHAR(50) NOT NULL,
awardPoints INTEGER DEFAULT 0
);

DROP TABLE IF EXISTS Customer CASCADE;
CREATE TABLE Customer (
username VARCHAR(50) PRIMARY KEY REFERENCES UserAccount (username)
);

DROP TABLE IF EXISTS Manager CASCADE;
CREATE TABLE Manager (
username VARCHAR(50) REFERENCES UserAccount (username),
RName varchar(100),
Location varchar(100),
PRIMARY KEY (username, RName, Location),
FOREIGN KEY (rname, location) REFERENCES Restaurant(rname, location)
);

DROP TABLE IF EXISTS Friends;
CREATE TABLE Friends (
    myUsername VARCHAR(50), 
	friendUsername VARCHAR(50), 
	PRIMARY KEY(myUsername, friendUsername),
	FOREIGN KEY(myUsername) REFERENCES Customer(username),
	FOREIGN KEY(friendUsername) REFERENCES Customer(username)
);

--Updated
DROP TABLE IF EXISTS preferences; -- Weak entity
CREATE TABLE preferences ( 
    username VARCHAR(50) PRIMARY KEY,
    cuisinetype VARCHAR(50),
    location VARCHAR(50),
    budget INTEGER,
    FOREIGN KEY (username) REFERENCES Customer (username) ON DELETE CASCADE ON UPDATE CASCADE
);

--Updated maxTables
DROP TABLE IF EXISTS Restaurant;
CREATE TABLE Restaurant (
	RName varchar(100),
	Location varchar(100),
	maxTables integer,
	CuisineType varchar(30) NOT NULL,
	OpeningHours varchar(20) NOT NULL, -- Change date/time? 
	primary key (rname, location)
);

DROP TABLE IF EXISTS Manages;
CREATE TABLE Manages (
	username varchar(50),
	RName varchar(100),
	Location varchar(100),
	PRIMARY KEY (username, RName, Location),
	FOREIGN KEY (username) REFERENCES Manager (username),
	FOREIGN KEY (RName, Location) REFERENCES Restaurant (RName, Location)
);

DROP TABLE IF EXISTS Favourites;
CREATE TABLE Favourites (
	username varchar(50),
	RName varchar(100),
	Location varchar(100),
	PRIMARY KEY (username, RName, Location),
	FOREIGN KEY (username) REFERENCES Customer (username),
	FOREIGN KEY (RName, Location) REFERENCES Restaurant (RName, Location)
);

DROP TABLE IF EXISTS Availability;
CREATE TABLE Availability (
	RName varchar(100),
	Location varchar(100),
	numTables integer,
	reserveDate date NOT NULL,
	reserveTime time NOT NULL,
	PRIMARY KEY (RName, Location, reserveDate, reserveTime),
	FOREIGN KEY (RName, Location) REFERENCES Restaurant (RName, Location) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Reservation;
CREATE TABLE Reservation (
	username varchar(50),
	RName varchar(100),
	Location varchar(100),
	numTables integer NOT NULL,
	reserveDate date NOT NULL,
	reserveTime time NOT NULL,
	confirmation boolean DEFAULT FALSE, -- implement some sort of confirmation?
	PRIMARY KEY (username, RName, Location, reserveDate, reserveTime),
	FOREIGN KEY (username) REFERENCES userAccount(username),
	FOREIGN KEY (RName, Location, reserveDate, reserveTime) REFERENCES Availability (RName, Location, reserveDate, reserveTime)
);

DROP TABLE IF EXISTS Menu; -- Weak entity
CREATE TABLE Menu (
	FName varchar(50),
	RName varchar(100),
	Location varchar(100),
	course varchar(30) NOT NULL,
	price integer NOT NULL,
	PRIMARY KEY (FName, RName, Location),
	FOREIGN KEY (RName, Location) REFERENCES Restaurant (RName, Location) ON DELETE CASCADE ON UPDATE CASCADE -- legal? or must call separately
);

DROP TABLE IF EXISTS OfferMenu; -- Weak entity
CREATE TABLE OfferMenu (
	OName varchar(50),
	RName varchar(100),
	Location varchar(100),
	course varchar(30) NOT NULL,
	price integer NOT NULL,
	startDate date NOT NULL,
	endDate date NOT NULL,
	PRIMARY KEY (OName, RName, Location),
	FOREIGN KEY (RName, Location) REFERENCES Restaurant (RName, Location) ON DELETE CASCADE ON UPDATE CASCADE -- legal? or must call separately
);

DROP TABLE IF EXISTS Rewards;
CREATE TABLE Rewards (
	rewardName varchar(50) PRIMARY KEY,
	points integer NOT NULL,
	type varchar(30), -- fluff description?
);

-- Aggregate Claims against OfferMenu (Weak entity)
DROP TABLE IF EXISTS Claims;
CREATE TABLE Claims (
	username varchar(50),
	rewardName varchar(50),
	OName varchar(50),
	RName varchar(100),
	Location varchar(100),
	claimDate date NOT NULL,
	claimTime time NOT NULL,
	PRIMARY KEY (username, OName, RName, Location),
	FOREIGN KEY (OName, RName, Location) REFERENCES OfferMenu (OName, RName, Location),
	FOREIGN KEY (username) REFERENCES userAccount (username) 
);
