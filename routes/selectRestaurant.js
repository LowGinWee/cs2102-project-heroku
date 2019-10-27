var express = require('express');
var router = express.Router();

const { Pool } = require('pg')

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: true
});

var restaurant;

/* SQL Query */
var sql_query = 'SELECT * FROM restaurant';

router.get('/', function(req, res, next) {
	pool.query(sql_query, (err, data) => {
		var restaurant = data.rows;
		res.render('selectRestaurant', { title: 'Restaurants table', userData: data.rows });
	});
});

router.get('/:rname-:location', async function(req, res, next) {
	var rname = req.params.rname;
	var location = req.params.location;
	var new_query =  "SELECT * FROM restaurant r LEFT OUTER JOIN restaurantprofile p ON (r.rname = p.rname)" + " WHERE r.rname = '" + rname + "'" + " AND r.branchid = '" + location + "'";
	console.log(new_query);
	var data1;

	await pool.query(new_query, (err, data) => {
		if(err){
			console.log(err);
		} else {
			data1 = data;
			res.render('viewRestaurant', { title: rname , branchid: location, userData: data1.rows})
		}
	});
});

router.get('/:rname-:location/menu', async function(req, res, next) {
	var rname = req.params.rname;
	var location = req.params.location;

	
	var course_query = "SELECT DISTINCT * FROM menu" +  " WHERE rname = '" + rname + "'" + " AND branchID = '" + location + "' ORDER BY course";
	var menu;
	await pool.query(course_query, (err, data) => {
		if(err){
			console.log(err);
		} else {
			menu = data;
			res.render('viewRestaurantMenu', { title: rname , location: location, menu: menu.rows})
		}
	});

});

router.post('/:rname-:location/edit', async function(req, res, next) {
	var rname = req.params.rname;
	var location = req.params.location;
	var a = req.body.area;
	var c = req.body.cuisine;
		// Construct Specific SQL Query
		insert_query = "INSERT INTO RestaurantProfile VALUES ('" + rname + "','" + location + "', '" + c + "', '" + a + "') ON CONFLICT (rname,branchid) DO UPDATE SET CuisineType='" + c + "', area='" + a + "'";
		console.log(insert_query);
		pool.query(insert_query, (err, data) => {
			if (err){
				console.log(err);
			}
			res.redirect('/selectRestaurant/' + rname + "-" + location);
		});
});

router.get('/:rname-:location/edit', async function(req, res, next) {
	var rname = req.params.rname;
	var location = req.params.location;

			res.render('editRestProfile', { title: rname , location: location})


});

// router.get('/:rname-:location/availability', async function(req, res, next) {
// 	var rname = req.params.rname;
// 	var location = req.params.location;
// 	var new_query =  "SELECT * FROM availability WHERE rname = '" + rname + "'" + " AND branchid = '" + location + "'";
// 	console.log(new_query);
// 	var data1;

// 	await pool.query(new_query, (err, data) => {
// 		if(err){
// 			console.log(err);
// 		} else {
// 			data1 = data;
// 			res.render('viewRestaurantAvail', { title: rname , branchid: location, userData: data1.rows})
// 		}
// 	});
// });

router.get('/:rname-:location/availability', async function(req, res, next) {
	var rname = req.params.rname;
	var location = req.params.location;
	var avail_query = "DROP VIEW IF EXISTS availableCapacity; \n" + 
	"CREATE VIEW availableCapacity(RName, branchID, capacityLeft, reserveDate, reserveTime) AS\n" + 
	"WITH reservedTablesCount(RName, branchID, totalreserved, reserveDate, reserveTime)\n" + 
	"	AS\n" + 
	"	(SELECT R.Rname, R.branchID, SUM(R.numTables) AS totalreserved, R.reserveDate, R.reserveTime\n" + 
	"FROM Reservation R\n" + 
	"GROUP BY R.Rname, R.branchID, R.reserveDate, R.reserveTime\n" + 
	")\n" + 
	"SELECT A.Rname, A.branchID, \n" + 
	"	(CASE \n" + 
	"		when R.totalreserved is null THEN A.numTables\n" + 
	"		ELSE A.numTables - R.totalreserved END) AS capacityLeft, A.reserveDate, A.reserveTime , R.totalreserved, A.numTables\n" + 
	"FROM Availability A \n" + 
	"Left JOIN reservedTablesCount R\n" + 
	"ON A.RName = R.RName AND A.branchID = R.branchID AND A.reserveDate = R.reserveDate AND A.reserveTime = R.reserveTime\n" + 
	"WHERE A.Rname = 'Astons' AND A.branchID = 'Clementi'; -- rName and branchID can be specified\n";
	
	var q2 = "select * from availableCapacity;";
	
	var new_query =  "SELECT * FROM availability WHERE rname = '" + rname + "'" + " AND branchid = '" + location + "'";

	
	await pool.query(avail_query, (err, data) => {
	});

	await pool.query(q2, (err, data) => {
		if(err){
			console.log(err);
		} else {
			console.log(data);
			res.render('viewRestaurantAvail', { title: rname , branchid: location, userData: data.rows})
		}
	});
});

module.exports = router;
