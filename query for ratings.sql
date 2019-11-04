DROP FUNCTION getRatings2(myDate date, daysCount integer, orderBy varchar(50));
Create or REPLACE FUNCTION getRatings2(myDate date, daysCount integer, orderBy varchar(50)) RETURNS TABLE (Rname varchar(50), BranchID varchar(50), Rating numeric, Dinners bigint) AS
$$
begin
IF (OrderBy = 'Dinners') THEN
RETURN QUERY
Select r.RName, r.branchID, AVG(rv.rating) AS Rating, Sum(r.numTables) as Dinners 
FROM reservation r LEFT OUTER JOIN RateVisit rv 
ON (rv.username = r.username AND r.rname = rv.rname AND r.branchID = rv.branchID AND r.ReserveDate = rv.ReserveDate AND r.ReserveTime = rv.ReserveTime)
Where r.ReserveDate < myDate + daysCount AND r.ReserveDate >= myDate
Group By r.Rname, r.BranchID ORDER BY Dinners DESC;
ELSE 
RETURN QUERY
Select r.RName, r.branchID, AVG(rv.rating) AS Rating, Sum(r.numTables) as Dinners 
FROM reservation r LEFT OUTER JOIN RateVisit rv 
ON (rv.username = r.username AND r.rname = rv.rname AND r.branchID = rv.branchID AND r.ReserveDate = rv.ReserveDate AND r.ReserveTime = rv.ReserveTime)
Where r.ReserveDate < myDate + daysCount AND r.ReserveDate >= myDate
Group By r.Rname, r.BranchID ORDER BY Rating DESC;
END IF;
end;
$$
LANGUAGE plpgsql;

SELECT * from getRatings2('2019-11-02', 1, 'Dinners');

SELECT * from getRatings2('2019-11-02', 100, 'Rating');
















/*Create or REPLACE FUNCTION dateTest(myDate date, daysCount integer) RETURNS TABLE (dater date) AS
$$
begin RETURN QUERY
Select myDate + daysCount;

end;
$$
LANGUAGE plpgsql;

SELECT * from dateTest('2019-12-22', 10); */
