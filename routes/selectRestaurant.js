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
	var new_query = sql_query + " WHERE rname = '" + rname + "'" + " AND location = '" + location + "'";

	var data1;

	await pool.query(new_query, (err, data) => {
		if(err){
			console.log(err);
		} else {
			data1 = data;
			console.log(data1);
			res.render('viewRestaurant', { title: rname , userData: data1.rows})
		}
	});
	
/* 	var course_query = "SELECT DISTINCT * FROM menu" +  " WHERE rname = '" + rname + "'" + " AND location = '" + location + "' ORDER BY course";
	var menu;
	await pool.query(course_query, (err, data) => {
		if(err){
			console.log(err);
		} else {
			menu = data;
			res.render('viewRestaurant', { title: rname , userData: data1.rows, menu: menu.rows})
		}


	}); */

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

module.exports = router;
