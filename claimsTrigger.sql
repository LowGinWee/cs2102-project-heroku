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

/*Trigger to award the user points when ever they rate a restaurant*/
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

/*
INSERT INTO "reservation" (username,RName,branchID,numTables,reserveDate,reserveTime) VALUES ('Kadeem','High End West','Lakeside',8,'2019-12-02','11:00');
INSERT INTO "reservation" (username,RName,branchID,numTables,reserveDate,reserveTime) VALUES ('Ignacia','Astons','Clementi',2,'2019-11-16','14:00');

Select * from userAccount where username = 'Kadeem' OR username = 'Ignacia';

INSERT INTO "ratevisit" (username,RName,branchID,reserveDate,reserveTime,rating, confirmation) VALUES ('Ignacia','Astons','Clementi','2019-11-16','14:00',null,false);
INSERT INTO "ratevisit" (username,RName,branchID,reserveDate,reserveTime,rating, confirmation) VALUES ('Kadeem','High End West','Lakeside','2019-12-02','11:00',3,true);

Select * from userAccount where username = 'Kadeem' OR username = 'Ignacia';

Delete from rateVisit where username = 'Kadeem' OR username = 'Ignacia';*/