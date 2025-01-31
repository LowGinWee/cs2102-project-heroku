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
	maxTables integer NOT NULL,
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
	numTables integer NOT NULL,
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
	FOREIGN KEY (RName, branchID) REFERENCES RestaurantProfile(RName, branchID),
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

/*Trigger to check if the respective claim is within the window period*/
CREATE OR REPLACE FUNCTION checkValid(offer varchar(50), restaurant varchar(100), myBranchId varchar(100), checkClaimDate date)
	RETURNS BOOLEAN AS
	$$ 
	DECLARE 
		isValid BOOLEAN;
	BEGIN
	SELECT checkClaimDate < Om.startDate OR checkClaimDate > Om.endDate FROM OfferMenu Om 
		WHERE offer = Om.Oname AND restaurant = Om.Rname AND myBranchId = Om.branchID
	INTO isValid;
	RETURN isValid;
	END; 
	$$ LANGUAGE plpgsql;
	
CREATE OR REPLACE FUNCTION checkClaim()
RETURNS TRIGGER AS $$ BEGIN
RAISE NOTICE 'Sorry. The Offer has not started or expired'; 
RETURN NULL;
END; $$ LANGUAGE plpgsql;
	
DROP TRIGGER IF EXISTS trig2 ON public.claims;
CREATE TRIGGER trig2
BEFORE INSERT ON claims
FOR EACH ROW WHEN  (checkValid(NEW.OName, NEW.RName, NEW.branchID, NEW.claimDate))
EXECUTE PROCEDURE checkClaim();

/*Trigger to check if user has enough points for the claim and updates points accordingly*/
CREATE OR REPLACE FUNCTION updateUser() RETURNS TRIGGER AS
	$$
	DECLARE isValid BOOLEAN;
	BEGIN
		SELECT uA.awardPoints >= r.points  FROM userAccount uA, Rewards r
		WHERE uA.username = NEW.username AND r.rewardName =  NEW.rewardName
		INTO isValid;
		if (isValid = TRUE) THEN
		UPDATE userAccount SET awardPoints = uA.awardPoints - r.points FROM userAccount uA, Rewards r WHERE uA.username = NEW.username AND r.rewardName = NEW.rewardName AND userAccount.username = NEW.username;
		RETURN NEW;
		ELSE
		RAISE NOTICE 'Sorry. You do not have enough points for this claim'; 
		RETURN NULL;
		END IF;
		RETURN NULL;
	END; 
	$$
 LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trig4 ON public.claims;
CREATE TRIGGER trig4
BEFORE INSERT ON claims 
FOR EACH ROW EXECUTE PROCEDURE updateUser();

/*trigger to check if more tables are made available then max tables of the restaurant*/
CREATE OR REPLACE FUNCTION checkMaxTables() RETURNS TRIGGER AS
	$$
	DECLARE isValid BOOLEAN;
	BEGIN
		SELECT NEW.numTables <= r.maxTables FROM Restaurant r
		WHERE r.RName = NEW.RName AND r.branchID = NEW.branchID
		INTO isValid;
		if (isValid = TRUE) THEN
		RETURN NEW;
		ELSE
		RAISE NOTICE 'WARNING, You are allocating more tables than available'; 
		RETURN NULL;
		END IF;
		RETURN NULL;
	END; 
	$$
 LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trig5 ON public.availability;
CREATE TRIGGER trig4
BEFORE INSERT ON availability 
FOR EACH ROW EXECUTE PROCEDURE checkMaxTables();

/*Trigger to check if user is trying to book a reservation when there is no more tables*/
CREATE OR REPLACE FUNCTION getCurrTables(myRName varchar(100), myBranchID varchar(100), myReserveDate date, myReserveTime time)
	RETURNS integer AS
	$$ 
	DECLARE 
		currtables integer;
	BEGIN
	WITH reservedTablesCount(RName, branchID, totalreserved, reserveDate, reserveTime) AS 
		(SELECT R.Rname, R.branchID, SUM(R.numTables) AS totalreserved, R.reserveDate, R.reserveTime
		FROM Reservation R
		WHERE R.reserveDate = myReserveDate 
		AND R.reserveTime = myReserveTime
		GROUP BY R.Rname, R.branchID, R.reserveDate, R.reserveTime)
	SELECT A.numTables - R.totalreserved
	INTO currtables -- set variable
	FROM Availability A 
	FULL JOIN reservedTablesCount R
	ON A.RName = R.RName 
	AND A.branchID = R.branchID
	WHERE A.Rname = myRName 
	AND A.branchID = myBranchID; -- rName and branchID can be specified
	RETURN currtables;
	END; 
	$$ LANGUAGE plpgsql;
		
CREATE OR REPLACE FUNCTION checkReservation()
RETURNS TRIGGER AS $$ BEGIN
RAISE NOTICE 'Sorry! Restaurant is over-booked at this timing.'; 
RETURN NULL;
END; $$ LANGUAGE plpgsql;
	
DROP TRIGGER IF EXISTS trig1 ON public.reservation;
CREATE TRIGGER trig1
BEFORE INSERT ON Reservation
FOR EACH ROW WHEN (NEW.numtables > getCurrTables(NEW.rname,NEW.branchID, NEW.reserveDate, NEW.reserveTime))
EXECUTE PROCEDURE checkReservation();

/*Trigger to award the user points whenever they rate a restaurant*/
CREATE OR REPLACE FUNCTION awardUserPoints() RETURNS TRIGGER AS
	$$
	BEGIN
		IF (NEW.confirmation = true) THEN
		UPDATE userAccount SET awardPoints = awardPoints + 10 WHERE userAccount.username = NEW.username;
		RAISE NOTICE 'User awarded 10 points!';
		ELSE
		RAISE NOTICE 'User Visit not confirmed.';
		RETURN NEW;
		END IF;
		RETURN NEW;
	END; 
	$$
 LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS awardUserPointsTrigger ON public.RateVisit;
CREATE TRIGGER awardUserPointsTrigger
AFTER INSERT ON RateVisit 
FOR EACH ROW
EXECUTE PROCEDURE awardUserPoints();