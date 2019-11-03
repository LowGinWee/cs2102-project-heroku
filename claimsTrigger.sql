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




