--Updated

--Drops moved to the top. All using CASCADE to ensure full drop.
--Drops failed without CASCADE since it was unable to drop tables that depend on another
DROP TABLE IF EXISTS userAccount CASCADE;
DROP TABLE IF EXISTS Customer CASCADE;
DROP TABLE IF EXISTS Admin CASCADE;
DROP TABLE IF EXISTS Friends CASCADE;
DROP TABLE IF EXISTS preferences CASCADE;
DROP TABLE IF EXISTS Restaurant CASCADE;
DROP TABLE IF EXISTS RestaurantProfile CASCADE;
DROP TABLE IF EXISTS Favourites CASCADE;
DROP TABLE IF EXISTS Availability CASCADE;
DROP TABLE IF EXISTS Reservation CASCADE;
DROP TABLE IF EXISTS RateVisit CASCADE;
DROP TABLE IF EXISTS Menu CASCADE;
DROP TABLE IF EXISTS OfferMenu CASCADE;
DROP TABLE IF EXISTS Rewards CASCADE;
DROP TABLE IF EXISTS Claims CASCADE;


CREATE TABLE userAccount (
username VARCHAR(50) UNIQUE PRIMARY KEY, -- for login purposes unique
email VARCHAR(355) UNIQUE NOT NULL,
password VARCHAR(50) NOT NULL,
awardPoints INTEGER DEFAULT 0
);

CREATE TABLE Customer (
username VARCHAR(50) PRIMARY KEY REFERENCES UserAccount (username)
);

CREATE TABLE Admin (
username VARCHAR(50) PRIMARY KEY REFERENCES UserAccount (username)
);

CREATE TABLE Friends (
    myUsername VARCHAR(50), 
	friendUsername VARCHAR(50), 
	PRIMARY KEY(myUsername, friendUsername),
	FOREIGN KEY(myUsername) REFERENCES Customer(username),
	FOREIGN KEY(friendUsername) REFERENCES Customer(username),
	CHECK (myUsername <> friendUsername)
);

--Updated
CREATE TABLE preferences ( 		-- Weak entity
    username VARCHAR(50) PRIMARY KEY,
    prefCuisinetype VARCHAR(50),
    prefArea VARCHAR(50),
    prefBudget INTEGER,
    FOREIGN KEY (username) REFERENCES Customer (username) ON DELETE CASCADE ON UPDATE CASCADE
);

--Updated maxTables
CREATE TABLE Restaurant (
	RName varchar(100),
	branchID varchar(100),
	maxTables integer,
	OpeningHours varchar(20) NOT NULL, 
	AdminID VARCHAR(50) NOT NULL REFERENCES Admin(username), -- Account manager
	primary key (rname, branchID)
);

CREATE TABLE RestaurantProfile (
	RName varchar(100),
	branchID varchar(100),
	CuisineType varchar(30) NOT NULL,
	area varchar(50),
	primary key (RName, branchID),
	FOREIGN KEY (RName, branchID) REFERENCES Restaurant (RName, branchID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Favourites (
	username varchar(50),
	RName varchar(100),
	branchID varchar(100),
	PRIMARY KEY (username, RName, branchID),
	FOREIGN KEY (username) REFERENCES Customer (username),
	FOREIGN KEY (RName, branchID) REFERENCES Restaurant (RName, branchID)
);

CREATE TABLE Availability (
	RName varchar(100),
	branchID varchar(100),
	numTables integer,
	reserveDate date NOT NULL,
	reserveTime time NOT NULL,
	PRIMARY KEY (RName, branchID, reserveDate, reserveTime),
	FOREIGN KEY (RName, branchID) REFERENCES Restaurant (RName, branchID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Reservation (
	username varchar(50),
	RName varchar(100),
	branchID varchar(100),
	numTables integer NOT NULL,
	reserveDate date NOT NULL,
	reserveTime time NOT NULL,
	PRIMARY KEY (username, RName, branchID, reserveDate, reserveTime),
	FOREIGN KEY (username) REFERENCES Customer(username),
	FOREIGN KEY (RName, branchID, reserveDate, reserveTime) REFERENCES Availability (RName, branchID, reserveDate, reserveTime)
);

CREATE TABLE RateVisit (
	username varchar(50),
	RName varchar(100),
	branchID varchar(100),
	reserveDate date NOT NULL,
	reserveTime time NOT NULL,
	rating integer,
	confirmation boolean DEFAULT true, -- implement some sort of confirmation?
	PRIMARY KEY (username, RName, branchID, reserveDate, reserveTime),
	FOREIGN KEY (username, RName, branchID, reserveDate, reserveTime) REFERENCES Reservation(username, RName, branchID, reserveDate, reserveTime),
	CHECK(rating <= 5 
	AND rating >=0
	AND (confirmation = true OR rating IS NULL))
);

CREATE TABLE Menu (		 -- Weak entity
	FName varchar(50),
	RName varchar(100),
	branchID varchar(100),
	course varchar(30) NOT NULL,
	price numeric(4,2) NOT NULL,
	PRIMARY KEY (FName, RName, branchID),
	FOREIGN KEY (RName, branchID) REFERENCES Restaurant (RName, branchID) ON DELETE CASCADE ON UPDATE CASCADE, -- legal? or must call separately
	CHECK(course <> '')
);

CREATE TABLE OfferMenu (		 -- Weak entity
	OName varchar(50),
	RName varchar(100),
	branchID varchar(100),
	course varchar(30) NOT NULL,
	price numeric(4,2) NOT NULL,
	startDate date NOT NULL,
	endDate date NOT NULL,
	PRIMARY KEY (OName, RName, branchID),
	FOREIGN KEY (RName, branchID) REFERENCES Restaurant (RName, branchID) ON DELETE CASCADE ON UPDATE CASCADE -- legal? or must call separately
);

CREATE TABLE Rewards (
	rewardName varchar(50) PRIMARY KEY,
	points integer NOT NULL,
	type varchar(30)
);

CREATE TABLE Claims (		-- Aggregate Claims against OfferMenu (Weak entity)
	username varchar(50),
	rewardName varchar(50),
	OName varchar(50),
	RName varchar(100),
	branchID varchar(100),
	claimDate date NOT NULL,
	claimTime time NOT NULL,
	PRIMARY KEY (username, rewardName, OName, RName, branchID),
	FOREIGN KEY (OName, RName, branchID) REFERENCES OfferMenu (OName, RName, branchID),
	FOREIGN KEY (username) REFERENCES customer (username) ,
	FOREIGN KEY (rewardName) REFERENCES Rewards (rewardName)
);