

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
    branchID VARCHAR(50),
    budget INTEGER,
    FOREIGN KEY (username) REFERENCES userAccount (username) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Restaurant;
CREATE TABLE Restaurant (
	RName varchar(100),
	branchID varchar(100),
	CuisineType varchar(30) NOT NULL,
	OpeningHours varchar(20) NOT NULL,
	primary key (rname, branchID)
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

DROP TABLE IF EXISTS Admin CASCADE;
CREATE TABLE Admin (
username VARCHAR(50) PRIMARY KEY REFERENCES UserAccount (username)
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
    prefCuisinetype VARCHAR(50),
    prefArea VARCHAR(50),
    prefBudget INTEGER,
    FOREIGN KEY (username) REFERENCES Customer (username) ON DELETE CASCADE ON UPDATE CASCADE
);

--Updated maxTables
DROP TABLE IF EXISTS Restaurant;
CREATE TABLE Restaurant (
	RName varchar(100),
	branchID varchar(100),
	maxTables integer,
	OpeningHours varchar(20) NOT NULL, 
	AdminID VARCHAR(50) NOT NULL REFERENCES Admin(username), -- Account manager
	primary key (rname, branchID)
);

DROP TABLE IF EXISTS RestaurantProfile;
CREATE TABLE RestaurantProfile (
	RName varchar(100),
	branchID varchar(100),
	CuisineType varchar(30) NOT NULL,
	area varchar(50),
	primary key (RName, branchID),
	FOREIGN KEY (RName, branchID) REFERENCES Restaurant (RName, branchID) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Favourites;
CREATE TABLE Favourites (
	username varchar(50),
	RName varchar(100),
	branchID varchar(100),
	PRIMARY KEY (username, RName, branchID),
	FOREIGN KEY (username) REFERENCES Customer (username),
	FOREIGN KEY (RName, branchID) REFERENCES Restaurant (RName, branchID)
);

DROP TABLE IF EXISTS Availability;
CREATE TABLE Availability (
	RName varchar(100),
	branchID varchar(100),
	numTables integer,
	reserveDate date NOT NULL,
	reserveTime time NOT NULL,
	PRIMARY KEY (RName, branchID, reserveDate, reserveTime),
	FOREIGN KEY (RName, branchID) REFERENCES Restaurant (RName, branchID) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Reservation;
CREATE TABLE Reservation (
	username varchar(50),
	RName varchar(100),
	branchID varchar(100),
	numTables integer NOT NULL,
	reserveDate date NOT NULL,
	reserveTime time NOT NULL,
	confirmation boolean DEFAULT FALSE, -- implement some sort of confirmation?
	PRIMARY KEY (username, RName, branchID, reserveDate, reserveTime),
	FOREIGN KEY (username) REFERENCES Customer(username),
	FOREIGN KEY (RName, branchID, reserveDate, reserveTime) REFERENCES Availability (RName, branchID, reserveDate, reserveTime)
);

DROP TABLE IF EXISTS RateVisit;
CREATE TABLE RateVisit (
	username varchar(50),
	RName varchar(100),
	branchID varchar(100),
	reserveDate date NOT NULL,
	reserveTime time NOT NULL,
	rating numeric(1,1),
	PRIMARY KEY (username, RName, branchID, reserveDate, reserveTime),
	FOREIGN KEY (username, RName, branchID, reserveDate, reserveTime) REFERENCES Reservation(username, RName, branchID, reserveDate, reserveTime),
	CHECK(rating <= 5 AND rating >=0)
);

DROP TABLE IF EXISTS Menu; -- Weak entity
CREATE TABLE Menu (
	FName varchar(50),
	RName varchar(100),
	branchID varchar(100),
	course varchar(30) NOT NULL,
	price numeric NOT NULL,
	PRIMARY KEY (FName, RName, branchID),
	FOREIGN KEY (RName, branchID) REFERENCES Restaurant (RName, branchID) ON DELETE CASCADE ON UPDATE CASCADE, -- legal? or must call separately
	CHECK(course <> '')
);

DROP TABLE IF EXISTS OfferMenu; -- Weak entity
CREATE TABLE OfferMenu (
	OName varchar(50),
	RName varchar(100),
	branchID varchar(100),
	course varchar(30) NOT NULL,
	price integer NOT NULL,
	startDate date NOT NULL,
	endDate date NOT NULL,
	PRIMARY KEY (OName, RName, branchID),
	FOREIGN KEY (RName, branchID) REFERENCES Restaurant (RName, branchID) ON DELETE CASCADE ON UPDATE CASCADE -- legal? or must call separately
);

DROP TABLE IF EXISTS Rewards;
CREATE TABLE Rewards (
	rewardName varchar(50) PRIMARY KEY,
	points integer NOT NULL,
	type varchar(30), 
);

-- Aggregate Claims against OfferMenu (Weak entity)
DROP TABLE IF EXISTS Claims;
CREATE TABLE Claims (
	username varchar(50),
	rewardName varchar(50),
	OName varchar(50),
	RName varchar(100),
	branchID varchar(100),
	claimDate date NOT NULL,
	claimTime time NOT NULL,
	PRIMARY KEY (username, rewardName, OName, RName, branchID),
	FOREIGN KEY (OName, RName, branchID) REFERENCES OfferMenu (OName, RName, branchID),
	FOREIGN KEY (username) REFERENCES customer (username) 
);
