/* 
Top 3 restaurants everyday ranked by totalTables from reservations.
Total claims and points spent on rewards on the day tabulated as well (if available)
for managers/business owners to identify possible trends in totalTables count.
*/

DROP VIEW IF EXISTS popularRestaurants;
CREATE VIEW popularRestaurants (date, rank, rname, branchID, totalTables, totalClaims, totalPoints) AS
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
WHERE RANK <= 3
ORDER BY rankFilter.reserveDate;
SELECT * FROM popularRestaurants;

<<<<<<< HEAD

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
ORDER BY rankFilter.reserveDate;
end;
$$
LANGUAGE plpgsql;

select * from getpopularrestaurants();
=======
>>>>>>> 3afc435e46cf181011cb6d80501a1952772df3f1
--Subtables
DROP VIEW IF EXISTS totalTablesRanking;
CREATE VIEW totalTablesRanking (date, rname, branchID, totalTables) AS
WITH X AS (
	SELECT A.reserveDate, R.RName, R.branchID, SUM(R.numTables) as totalTables 
	FROM Reservation R JOIN Availability A
	ON R.rname = A.rname
	AND R.branchID = A.branchID
	GROUP BY A.reserveDate, R.Rname, R.branchID)
SELECT rankFilter.reserveDate, rankFilter.RName, rankFilter.branchID, rankFilter.totalTables  FROM (
	SELECT X.*,
		rank() OVER (
			PARTITION BY X.reserveDate
			ORDER BY X.totalTables DESC)
	FROM X
) rankFilter
WHERE RANK <= 1;
SELECT * FROM totalTablesRanking;

DROP VIEW IF EXISTS restaurantsTotalPoints;
CREATE VIEW restaurantsTotalPoints (date, rname, branchID, totalClaims) AS
SELECT C.claimDate, C.rname, C.branchID, SUM(R.points)
FROM Claims C, Rewards R
WHERE R.rewardName = C.rewardName
GROUP BY C.claimDate, C.rname, C.branchID;
SELECT * FROM restaurantsTotalPoints;





