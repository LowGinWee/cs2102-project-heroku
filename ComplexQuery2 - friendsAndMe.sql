/* 
For all restaurants that a user had a reservation at AND gave a NON-NULL rating
Compute average rating of all friends of the user who attended a reservation at the same restaurant,branch.
Also compute latest rating of user at each restaurant the user had a reservation at.
*/

DROP VIEW IF EXISTS friendsAndMe;
CREATE VIEW friendsAndMe (rname, branchid, myLatestRating, friendsAvgRating) AS
WITH X AS (
	SELECT RV.rname, RV.branchid, ROUND(AVG(RV.rating),2) AS friendsAvgRating
	FROM RateVisit RV, Friends F 
	WHERE F.myusername = 'Lewis' --*** VARIABLE ***
	AND RV.username = F.friendusername
	AND EXISTS (SELECT 1
				FROM RateVisit RV2
				WHERE RV2.username = F.myusername
				AND RV2.rname = RV.rname
				AND RV2.branchid = RV.branchid)
	GROUP BY RV.rname, RV.branchid),
Y AS (
	SELECT rankFilter.rname, rankFilter.branchid, rankFilter.rating FROM (
		SELECT *,
			rank() OVER (
				PARTITION BY rname, branchid
				ORDER BY RV.reservedate DESC, RV.reservetime DESC)
		FROM RateVisit RV
		WHERE RV.username = 'Lewis' -- ***VARIABLE***
		AND RV.rating IS NOT NULL
	) rankFilter
	WHERE RANK <=1)	
SELECT Y.rname, Y.branchid, Y.rating, X.friendsAvgRating 
FROM Y LEFT JOIN X
ON Y.rname = X.rname
AND Y.branchid = X.branchid;

select * from friendsAndMe;

INSERT INTO "availability" (RName,branchID,numTables,reserveDate,reserveTime) VALUES ('Astons','Ang Mo Kio',80,'2019-12-15','13:00');
INSERT INTO "reservation" (username,RName,branchID,numTables,reserveDate,reserveTime) VALUES ('Lewis','Astons','Ang Mo Kio',5,'2019-12-15','13:00');
INSERT INTO "ratevisit" (username,RName,branchID,reserveDate,reserveTime,rating, confirmation) VALUES ('Lewis','Astons','Ang Mo Kio','2019-12-15','13:00',3,true);

-- This will show latest rating, which is 3
select * from friendsAndMe;

/*function version*/
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

--INSERT INTO "ratevisit" (username,RName,branchID,reserveDate,reserveTime,rating, confirmation) VALUES ('Lewis','Astons','Ang Mo Kio','2019-12-12','13:00',4,true);
select * from friendsAndMe;

INSERT INTO "availability" (RName,branchID,numTables,reserveDate,reserveTime) VALUES ('Astons','Ang Mo Kio',80,'2019-12-15','13:00');
INSERT INTO "reservation" (username,RName,branchID,numTables,reserveDate,reserveTime) VALUES ('Lewis','Astons','Ang Mo Kio',5,'2019-12-15','13:00');
INSERT INTO "ratevisit" (username,RName,branchID,reserveDate,reserveTime,rating, confirmation) VALUES ('Lewis','Astons','Ang Mo Kio','2019-12-15','13:00',3,true);

select * from friendratings('Lewis');

-- This will show latest rating, which is 3
select * from friendsAndMe;




/* Sub tables */

DROP VIEW IF EXISTS friendsAvgRatingsV; -- DONE Find friends average ratings in restaurants you been to (ONLY IF you have friends who been there before)
CREATE VIEW friendsAvgRatingsV (rname, branchid, friendsAvgRating) AS
	SELECT RV.rname, RV.branchid, ROUND(AVG(RV.rating),2) AS friendsAvgRating
	FROM RateVisit RV, Friends F 
	WHERE F.myusername = 'Lewis' --*** VARIABLE ***
	AND RV.username = F.friendusername -- conect friends ratings to uname
	AND EXISTS (SELECT 1
				FROM RateVisit RV2
				WHERE RV2.username = F.myusername
				AND RV2.rname = RV.rname
				AND RV2.branchid = RV.branchid)
	GROUP BY RV.rname, RV.branchid;
SELECT * FROM friendsAvgRatingsV;
-------------
DROP VIEW IF EXISTS myLatestRatingV; -- DONE Find latest reservation's rating for all restaurants, even null
CREATE VIEW myLatestRatingV (rname, branchid, myLatestRating) AS
SELECT rankFilter.rname, rankFilter.branchid, rankFilter.rating FROM (
	SELECT *,
		rank() OVER (
			PARTITION BY rname, branchid
			ORDER BY RV.reservedate DESC, RV.reservetime DESC)
	FROM RateVisit RV
	WHERE RV.username = 'Hall' -- ***VARIABLE***
	AND RV.rating IS NOT NULL
) rankFilter
WHERE RANK <=1;	
SELECT * FROM myLatestRatingV;
----------------------
