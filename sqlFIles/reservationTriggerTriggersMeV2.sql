CREATE OR REPLACE FUNCTION getCurrTables(myRName varchar(100), myBranchID varchar(100), myReserveDate date, myReserveTime time)
	RETURNS integer AS
	$$ 
	DECLARE 
		currtables integer;
	BEGIN
	WITH reservedTablesCount(RName, branchID, totalreserved, reserveDate, reserveTime) AS 
		(SELECT R.Rname, R.branchID, SUM(R.numTables) AS totalreserved, R.reserveDate, R.reserveTime
		FROM Reservation R
		WHERE R.reserveDate = myReserveDate 
		AND R.reserveTime = myReserveTime
		GROUP BY R.Rname, R.branchID, R.reserveDate, R.reserveTime)
	SELECT A.numTables - R.totalreserved
	INTO currtables -- set variable
	FROM Availability A 
	FULL JOIN reservedTablesCount R
	ON A.RName = R.RName 
	AND A.branchID = R.branchID
	WHERE A.Rname = myRName 
	AND A.branchID = myBranchID; -- rName and branchID can be specified
	RETURN currtables;
	END; 
	$$ LANGUAGE plpgsql;
		
CREATE OR REPLACE FUNCTION checkReservation()
RETURNS TRIGGER AS $$ BEGIN
RAISE NOTICE 'Sorry! Restaurant is over-booked at this timing.'; 
RETURN NULL;
END; $$ LANGUAGE plpgsql;
	
DROP TRIGGER IF EXISTS trig1 ON public.reservation;
CREATE TRIGGER trig1
BEFORE INSERT ON Reservation
FOR EACH ROW WHEN (NEW.numtables > getCurrTables(NEW.rname,NEW.branchID, NEW.reserveDate, NEW.reserveTime))
EXECUTE PROCEDURE checkReservation();

