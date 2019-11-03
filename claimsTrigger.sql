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

INSERT INTO "useraccount" (username,email,password,awardPoints) VALUES ('PointsTriggerTester9','do2es5tsh2swork@2gmail.com','123123',100);
select * from userAccount where username = 'PointsTriggerTester9';
INSERT INTO "customer" (username) VALUES ('PointsTriggerTester9');
INSERT INTO "claims" (userName,rewardName,OName,RName,branchID,claimDate,claimTime) VALUES ('PointsTriggerTester','Holiday Giveaway','Hirame Sushi','Itacho Sushi','Tampines','2019-12-20','16:00');
select * from userAccount where username = 'PointsTriggerTester';

 INSERT INTO "availability" (RName,branchID,numTables,reserveDate,reserveTime) VALUES ('High End West','Lakeside',1000,'2019-12-20','11:00');



