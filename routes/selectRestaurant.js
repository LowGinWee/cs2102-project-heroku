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

router.get('/:rname-:location', function(req, res, next) {
	var rname = req.params.rname;
	var location = req.params.location;
	var new_query = sql_query + " WHERE rname = '" + rname + "'" + " AND location = '" + location + "'";

	pool.query(new_query, (err, data) => {
		if(err){
			console.log(err);
		} else if(data.rows.length != 0) {
			res.render('viewRestaurant', { title: rname , userData: data.rows });
		} else {
			res.redirect("/selectRestaurant");
		}
	});
});

module.exports = router;
