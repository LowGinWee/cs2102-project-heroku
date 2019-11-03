DROP FUNCTION getRatings2(myDate date, daysCount integer, orderBy varchar(50));
Create or REPLACE FUNCTION getRatings2(myDate date, daysCount integer, orderBy varchar(50)) RETURNS TABLE (Rname varchar(50), BranchID varchar(50), Rating numeric, Dinners bigint) AS
$$
begin
IF (OrderBy = 'Dinners') THEN
RETURN QUERY
Select rv.RName, rv.branchID, AVG(rv.rating) AS Rating, Count(rv.RName) as Dinners
FROM RateVisit rv 
Where rv.ReserveDate < myDate + daysCount AND rv.ReserveDate >= myDate
Group By rv.Rname, rv.BranchID ORDER BY Dinners DESC;
ELSE 
RETURN QUERY
Select rv.RName, rv.branchID, AVG(rv.rating) AS Rating, Count(rv.RName) as Dinners
FROM RateVisit rv 
Where rv.ReserveDate < myDate + daysCount AND rv.ReserveDate >= myDate
Group By rv.Rname, rv.BranchID ORDER BY Rating DESC;
END IF;
end;
$$
LANGUAGE plpgsql;

SELECT * from getRatings2('2019-11-02', 100, 'Dinners');

SELECT * from getRatings2('2019-11-02', 100, 'Rating');















/*Create or REPLACE FUNCTION dateTest(myDate date, daysCount integer) RETURNS TABLE (dater date) AS
$$
begin RETURN QUERY
Select myDate + daysCount;

end;
$$
LANGUAGE plpgsql;

SELECT * from dateTest('2019-12-22', 10); */
