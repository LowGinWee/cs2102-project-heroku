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
	var new_query =  "SELECT * FROM restaurant NATURAL JOIN restaurantprofile" + " WHERE rname = '" + rname + "'" + " AND branchid = '" + location + "'";

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

	
	var course_query = "SELECT DISTINCT * FROM menu" +  " WHERE rname = '" + rname + "'" + " AND location = '" + location + "' ORDER BY course";
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

module.exports = router;
