/*
Find all Restaurants of a given username who matches the user's preferences
in cuisine type, area and budget. Budget is estimated by calculating the average
price of all the "Main" courses in the restaurant.
The top 3 restaurants are returned sorted by Best rating then cheapest price.
*/

-- X to compute budget (2dp)
-- Y to compute rating (1dp)
DROP VIEW IF EXISTS preferredRestaurants;
CREATE VIEW preferredRestaurants (RName, branchID, rating, avgPrice)  AS 
	WITH X AS (SELECT RP.RName, RP.branchID, RP.cuisineType, RP.area, ROUND(AVG(M.price),2) as avgPrice
				FROM RestaurantProfile AS RP JOIN Menu AS M
				ON RP.RName = M.RName
				AND RP.branchID = M.branchID
				AND M.course = 'Main'
				GROUP BY RP.RName, RP.branchID),
	Y AS (SELECT RV.RName, RV.branchID, ROUND(AVG(RV.rating),1) as avgRating
				FROM RateVisit AS RV
				GROUP BY RV.RName, RV.branchID)
	SELECT X.RName, X.branchID, Y.avgRating, X.avgPrice
	FROM X, Preferences AS P, Y
	WHERE P.username = 'Hall' -- **USERNAME VARIABLE HERE**
	AND P.prefArea = X.area -- get restaurants based on preferences
	AND P.prefCuisinetype = X.cuisineType
	AND P.prefBudget >= X.avgPrice
	AND Y.RName = X.RName -- join restaurants to their associated rating
	AND Y.branchID = X.branchID
	ORDER BY Y.avgRating DESC, X.avgPrice ASC
	LIMIT 3;
	
SELECT * FROM preferredRestaurants;