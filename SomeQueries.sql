/*
Queries to showcase the functionality/features of the database
*/

/*
QUERIES ON USERS
*/

-- Find friends who have made a Reservation in a certain Restaurant in the past
-- and view their ratings of said Restaurant
WITH PastReservations(username, RName, branchID, rating, reserveDate, reserveTime)  
AS 
(SELECT RateVisit.username, RateVisit.RName, RateVisit.branchID, 
RateVisit.rating, RateVisit.reserveDate, RateVisit.reserveTime
FROM RateVisit
WHERE RateVisit.RName = 'Astons') -- rName variable
SELECT F.friendUsername, P.RName, P.branchID, P.reserveDate, P.reserveTime, P.rating  
FROM PastReservations P 
JOIN Friends F
ON F.friendUsername = P.username
WHERE F.myUsername = 'Lewis'; -- Friends.myUserName variable

/*
QUERIES ON RESTAURANTS
*/
-- Views for easy query of restaurants in a certain area
-- Restaurants in the North area
DROP VIEW IF EXISTS northRestaurants;
CREATE VIEW northRestaurants (rname, branchid, cuisinetype, area) AS
SELECT * 
FROM RestaurantProfile R 
WHERE R.area = 'North';

-- Restaurants in the South area
DROP VIEW IF EXISTS southRestaurants;
CREATE VIEW southRestaurants (rname, branchid, cuisinetype, area) AS
SELECT * 
FROM RestaurantProfile R 
WHERE R.area = 'South';

-- Restaurants in the East area
DROP VIEW IF EXISTS eastRestaurants;
CREATE VIEW eastRestaurants (rname, branchid, cuisinetype, area) AS
SELECT * 
FROM RestaurantProfile R 
WHERE R.area = 'East';

-- Restaurants in the West area
DROP VIEW IF EXISTS westRestaurants;
CREATE VIEW westRestaurants (rname, branchid, cuisinetype, area) AS
SELECT * 
FROM RestaurantProfile R 
WHERE R.area = 'West';


/*
QUERIES ON RESERVATION AND AVAILABILITY
*/

-- Check available capacity of a certain Restaurant at a specified date and time
-- Might be able to be expanded / used to query and make reservations
DROP VIEW IF EXISTS availableCapacity;
CREATE VIEW availableCapacity(RName, branchID, capacityLeft, reserveDate, reserveTime) AS
WITH reservedTablesCount(RName, branchID, totalreserved, reserveDate, reserveTime)
AS
(SELECT R.Rname, R.branchID, SUM(R.numTables) AS totalreserved, R.reserveDate, R.reserveTime
FROM Reservation R
WHERE R.reserveDate = '2019-11-16' AND R.reserveTime = '14:00' -- reserveDate and reserveTime can be specified
GROUP BY R.Rname, R.branchID, R.reserveDate, R.reserveTime
)
SELECT A.Rname, A.branchID, (A.numTables - R.totalreserved) AS capacityLeft, R.reserveDate, R.reserveTime
FROM Availability A 
FULL JOIN reservedTablesCount R
ON A.RName = R.RName AND A.branchID = R.branchID
WHERE A.Rname = 'Astons' AND A.branchID = 'Clementi'; -- rName and branchID can be specified

/*
QUERIES ON REWARDS
*/
-- Find what rewards can a Customer claim with their current amount of AwardPoints, 
-- as well as their balance AwardPoints after claiming
DROP VIEW IF EXISTS claimableRewards;
CREATE VIEW claimableRewards (rewardName, Points, BalPoints) 
AS
SELECT R.rewardName, R.Points, (U.AwardPoints - R.Points) AS BalPoints
FROM Rewards AS R, UserAccount AS U
WHERE U.UserName = 'Rigel' -- UserAccount.UserName variable
AND U.AwardPoints >= R.Points;

 
-- Query to find the most popular type of reward claimed
-- May possibly be useful for data analytics? 
-- Can see which are more popular then push more of those types in the future
-- Need to add Rewards.type attribute into claims and query the Count
DROP VIEW IF EXISTS popularRewards;
CREATE VIEW popularRewards(rewardName, numClaimed);
AS



