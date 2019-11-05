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