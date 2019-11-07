
DROP VIEW IF EXISTS restaurantFullProfile;
CREATE VIEW restaurantFullProfile (RName, branchID, maxtables, openinghours, adminID, cuisineType, area, avgRating, avgPrice) AS
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
WHERE R2.rname = 'Astons' -- **VARIABLE rname**
AND R2.branchID = 'Ang Mo Kio'-- **VARIABLE branchid**
AND R2.rname = RP2.rname
AND R2.branchID = RP2.branchID
AND R2.rname = X.rname
AND R2.branchID = X.branchID) A LEFT OUTER JOIN Y ON (A.rname = Y.rname
AND A.branchID = Y.branchID)
;

SELECT * FROM restaurantFullProfile;

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

Select * from getRestProfile('High End West','Lakeside');

--Compute average Price
DROP VIEW IF EXISTS computeAvgPrice;
CREATE VIEW computeAvgPrice (avgPrice)  AS 
SELECT ROUND(AVG(M.price),2) as avgPrice
FROM RestaurantProfile AS RP JOIN Menu AS M
ON RP.RName = M.RName
AND RP.branchID = M.branchID
AND M.course = 'Main'
AND RP.RName = 'High End West' --*** VARIABLE rname***
AND RP.branchID = 'Lakeside' --*** VARIABLE branchID***
GROUP BY RP.RName, RP.branchID;
SELECT * FROM computeAvgPrice;

--Compute average rating
DROP VIEW IF EXISTS computeAvgRating;
CREATE VIEW computeAvgRating (avgRating) AS 
SELECT ROUND(AVG(RV.rating),1) as avgRating
FROM RateVisit AS RV
WHERE RV.RName = 'High End West' --*** VARIABLE rname***
AND RV.branchID = 'Lakeside' --*** VARIABLE branchID***
GROUP BY RV.RName, RV.branchID;
SELECT * FROM computeAvgRating;



	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	