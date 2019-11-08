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
CHECK(email LIKE '%@%.%')
);

CREATE TABLE Customer (
username VARCHAR(50) PRIMARY KEY REFERENCES UserAccount (username),
awardPoints INTEGER DEFAULT 0,
CHECK (awardPoints >= 0)
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

CREATE TABLE preferences (
    username VARCHAR(50) PRIMARY KEY,
    prefCuisineType VARCHAR(50),
    prefArea VARCHAR(50),
    prefBudget INTEGER,
    FOREIGN KEY (username) REFERENCES Customer (username) ON DELETE CASCADE ON UPDATE CASCADE,
	CHECK(prefBudget > 0
	AND (prefArea = 'North' 
	OR prefArea = 'South' 
	OR prefArea = 'East' 
	OR prefArea = 'West' 
	OR prefArea = 'Central'))
);

CREATE TABLE Restaurant (
	RName varchar(100),
	branchID varchar(100),
	maxTables integer NOT NULL,
	OpeningHours varchar(20) NOT NULL, 
	AdminID VARCHAR(50) NOT NULL REFERENCES Admin(username),
	PRIMARY KEY (rname, branchID),
	CHECK (maxTables > 0)
);

CREATE TABLE RestaurantProfile ( 
	RName varchar(100),
	branchID varchar(100),
	CuisineType varchar(30) NOT NULL,
	area varchar(50),
	PRIMARY KEY (RName, branchID),
	FOREIGN KEY (RName, branchID) REFERENCES Restaurant (RName, branchID) ON DELETE CASCADE ON UPDATE CASCADE,
	CHECK (area = 'North' 
	OR area = 'South' 
	OR area = 'East' 
	OR area = 'West' 
	OR area = 'Central')
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
	FOREIGN KEY (RName, branchID) REFERENCES Restaurant (RName, branchID) ON DELETE CASCADE ON UPDATE CASCADE,
	CHECK(numTables >= 0)
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
	confirmation boolean DEFAULT false, 
	PRIMARY KEY (username, RName, branchID, reserveDate, reserveTime),
	FOREIGN KEY (username, RName, branchID, reserveDate, reserveTime) REFERENCES Reservation(username, RName, branchID, reserveDate, reserveTime),
	CHECK(rating <= 5 
	AND rating >= 1
	AND (confirmation = true OR rating IS NULL))
);

CREATE TABLE Menu (
	FName varchar(50),
	RName varchar(100),
	branchID varchar(100),
	course varchar(30) NOT NULL,
	price numeric(10,2) NOT NULL,
	PRIMARY KEY (FName, RName, branchID),
	FOREIGN KEY (RName, branchID) REFERENCES Restaurant (RName, branchID) ON DELETE CASCADE ON UPDATE CASCADE,
	CHECK(price > 0
	AND (course = 'Main'
	OR course = 'Appetizer'
	OR course = 'Drinks'))
);

CREATE TABLE OfferMenu (
	OName varchar(50),
	RName varchar(100),
	branchID varchar(100),
	course varchar(30) NOT NULL,
	price numeric(10,2) NOT NULL,
	startDate date NOT NULL,
	endDate date NOT NULL,
	PRIMARY KEY (OName, RName, branchID),
	FOREIGN KEY (RName, branchID) REFERENCES Restaurant (RName, branchID) ON DELETE CASCADE ON UPDATE CASCADE,
	CHECK (endDate > startDate
	AND price > 0
	AND (course = 'Main'
	OR course = 'Appetizer'
	OR course = 'Drinks'))
);

CREATE TABLE Rewards (
	rewardName varchar(50) PRIMARY KEY,
	points integer NOT NULL,
	type varchar(30),
	CHECK(points > 0)
);

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
	
DROP TRIGGER IF EXISTS trig2 ON claims;
CREATE TRIGGER trig2
BEFORE INSERT ON claims
FOR EACH ROW WHEN  (checkValid(NEW.OName, NEW.RName, NEW.branchID, NEW.claimDate))
EXECUTE PROCEDURE checkClaim();

/*Trigger to check if user has enough points for the claim and updates points accordingly*/
CREATE OR REPLACE FUNCTION updateUser() RETURNS TRIGGER AS
	$$
	DECLARE isValid BOOLEAN;
	BEGIN
		SELECT C.awardPoints >= r.points  FROM Customer C, Rewards r
		WHERE C.username = NEW.username AND r.rewardName =  NEW.rewardName
		INTO isValid;
		if (isValid = TRUE) THEN
		UPDATE Customer SET awardPoints = C.awardPoints - r.points FROM Customer C, Rewards r WHERE C.username = NEW.username 
			AND r.rewardName = NEW.rewardName AND Customer.username = NEW.username;
		RETURN NEW;
		ELSE
		RAISE NOTICE 'Sorry. You do not have enough points for this claim'; 
		RETURN NULL;
		END IF;
		RETURN NULL;
	END; 
	$$
 LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trig4 ON claims;
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

DROP TRIGGER IF EXISTS trig5 ON availability;
CREATE TRIGGER trig4
BEFORE INSERT ON availability 
FOR EACH ROW EXECUTE PROCEDURE checkMaxTables();

/*Trigger to check if user is trying to book a reservation when there is no more tables*/
CREATE OR REPLACE FUNCTION getCurrTables(myRName varchar(100), myBranchID varchar(100), myReserveDate date, myReserveTime time)
	RETURNS integer AS
	$$ 
	DECLARE 
		currtables integer;
		maxTables integer;

	BEGIN
	WITH reservedTablesCount(RName, branchID, totalreserved, reserveDate, reserveTime) AS 
		(SELECT R.Rname, R.branchID, 
		SUM(R.numTables) AS totalreserved 
		, R.reserveDate, R.reserveTime
		FROM Reservation R
		WHERE R.reserveDate = myReserveDate 
		AND R.reserveTime = myReserveTime
		GROUP BY R.Rname, R.branchID, R.reserveDate, R.reserveTime)
	SELECT A.numTables - R.totalreserved, A.numTables
	INTO currtables, maxTables -- set variable
	FROM Availability A 
	LEFT OUTER JOIN reservedTablesCount R
	ON A.RName = R.RName 
	AND A.branchID = R.branchID
	WHERE A.Rname = myRName 
	AND A.branchID = myBranchID; -- rName and branchID can be specified
	if (currtables IS NULL) THEN RETURN maxTables;
	ELSE RETURN currtables;
	END IF;
	END; 
	$$ LANGUAGE plpgsql;
		
CREATE OR REPLACE FUNCTION checkReservation()
RETURNS TRIGGER AS $$ BEGIN
RAISE NOTICE 'Sorry! Restaurant is over-booked at this timing.'; 
RETURN NULL;
END; $$ LANGUAGE plpgsql;
	
DROP TRIGGER IF EXISTS trig1 ON reservation;
CREATE TRIGGER trig1
BEFORE INSERT ON Reservation
FOR EACH ROW WHEN (NEW.numtables > getCurrTables(NEW.rname,NEW.branchID, NEW.reserveDate, NEW.reserveTime))
EXECUTE PROCEDURE checkReservation();

/*Trigger to award the customer points whenever they rate a restaurant*/
CREATE OR REPLACE FUNCTION awardUserPoints() RETURNS TRIGGER AS
	$$
	BEGIN
		IF (NEW.confirmation = true) THEN
		UPDATE Customer SET awardPoints = awardPoints + 10 WHERE Customer.username = NEW.username;
		RAISE NOTICE 'User awarded 10 points!';
		ELSE
		RAISE NOTICE 'User Visit not confirmed.';
		RETURN NEW;
		END IF;
		RETURN NEW;
	END; 
	$$
 LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS awardUserPointsTrigger ON RateVisit;
CREATE TRIGGER awardUserPointsTrigger
AFTER INSERT ON RateVisit 
FOR EACH ROW
EXECUTE PROCEDURE awardUserPoints();

/*function for complex query for friends*/
DROP FUNCTION friendratings(myName varchar(50));
Create or REPLACE FUNCTION friendratings(myName varchar(50))
RETURNS TABLE (rname varchar(50), branchid varchar(50), mylatestrating integer, friendsavgrating numeric) AS
$$
begin
RETURN QUERY
WITH X AS (
	SELECT RV.rname, RV.branchid, ROUND(AVG(RV.rating),2) AS friendsAvgRating
	FROM RateVisit RV, Friends F 
	WHERE F.myusername = myName --*** VARIABLE ***
	AND RV.username = F.friendusername -- conect friends ratings to uname
	AND EXISTS (SELECT 1
				FROM RateVisit RV2
				WHERE RV2.username = F.myusername
				AND RV2.rname = RV.rname
				AND RV2.branchid = RV.branchid)
	GROUP BY RV.rname, RV.branchid),
Y AS ( -- myLatestRating for each restaurant
	SELECT rankFilter.rname, rankFilter.branchid, rankFilter.rating FROM (
		SELECT *,
			rank() OVER (
				PARTITION BY RV.rname, RV.branchid
				ORDER BY RV.reservedate DESC, RV.reservetime DESC)
		FROM RateVisit RV
		WHERE RV.username = myName -- ***VARIABLE***
		AND RV.rating IS NOT NULL
	) rankFilter
	WHERE RANK <=1)	
SELECT Y.rname, Y.branchid, Y.rating, X.friendsAvgRating 
FROM Y LEFT JOIN X -- in case of friendsAvgRating NULL
ON Y.rname = X.rname
AND Y.branchid = X.branchid;
end;
$$
LANGUAGE plpgsql;

/*FUnction to get restaurant profile*/
DROP FUNCTION getRestProfile(myRname varchar(50), mybranchid varchar(50));
Create or REPLACE FUNCTION getRestProfile(myRname varchar(50), mybranchid varchar(50))
RETURNS TABLE (rname varchar(50), branchid varchar(50), maxtables integer, openinghours varchar(50), adminid varchar(50), cuisinetype varchar(50), area varchar(50), averating numeric, avgprice numeric ) AS
$$
begin
RETURN QUERY
WITH X AS (SELECT RP.RName, RP.branchID, ROUND(AVG(M.price),2) as avgPrice
				FROM RestaurantProfile AS RP JOIN Menu AS M
				ON RP.RName = M.RName
				AND RP.branchID = M.branchID
				WHERE M.course = 'Main'
				GROUP BY RP.RName, RP.branchID),
Y AS (SELECT RV.RName, RV.branchID, ROUND(AVG(RV.rating),1) as avgRating
				FROM RateVisit AS RV
				GROUP BY RV.RName, RV.branchID)
SELECT A.RName, A.branchID, A.maxtables, A.openinghours, A.adminID, A.cuisineType, A.area, y.avgRating, A.avgPrice FROM
(SELECT X.RName, X.branchID, R2.maxtables, R2.openinghours, R2.adminID, RP2.cuisineType, RP2.area, X.avgPrice FROM X, RestaurantProfile RP2, Restaurant R2 
WHERE R2.rname =  myRname -- **VARIABLE rname**
AND R2.branchID = mybranchid-- **VARIABLE branchid**
AND R2.rname = RP2.rname
AND R2.branchID = RP2.branchID
AND R2.rname = X.rname
AND R2.branchID = X.branchID) A LEFT OUTER JOIN Y ON (A.rname = Y.rname
AND A.branchID = Y.branchID);
end;
$$
LANGUAGE plpgsql;


/*Function for complex query 3*/


DROP FUNCTION getPopularRestaurants();
Create or REPLACE FUNCTION getPopularRestaurants()
RETURNS TABLE (day date, rank bigint, rname varchar(50), branchID varchar(50), totalTables bigint, totalClaims bigint, totalPoints bigint) AS
$$
begin
RETURN QUERY
WITH X AS (
	SELECT A.reserveDate, R.RName, R.branchID, SUM(R.numTables) as totalTables 
	FROM Reservation R JOIN Availability A
	ON R.rname = A.rname
	AND R.branchID = A.branchID
	GROUP BY A.reserveDate, R.Rname, R.branchID),
Y AS (SELECT C.claimDate, C.rname, C.branchID, COUNT(*) AS totalClaims, SUM(R.points) AS totalPoints
	FROM Claims C, Rewards R
	WHERE R.rewardName = C.rewardName
	GROUP BY C.claimDate, C.rname, C.branchID)
SELECT rankFilter.reserveDate, rankFilter.rank, rankFilter.RName, rankFilter.branchID, rankFilter.totalTables, Y.totalClaims, Y.totalPoints FROM (
	SELECT X.*,
		rank() OVER (
			PARTITION BY X.reserveDate
			ORDER BY X.totalTables DESC)
	FROM X
) rankFilter LEFT JOIN Y 
ON rankFilter.reserveDate = Y.claimDate
AND rankFilter.RName = Y.RName
AND rankFilter.branchID = Y.branchID
WHERE rankFilter.RANK <= 3
ORDER BY rankFilter.reserveDate, rankFilter.rank;
end;
$$
LANGUAGE plpgsql;

