var express = require('express');
var router = express.Router();

const { Pool } = require('pg')

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: true
});

var restaurant;

/* SQL Query */
/* var sql_query = 'SELECT * FROM restaurant';

router.get('/', function(req, res, next) {
	pool.query(sql_query, (err, data) => {
		var restaurant = data.rows;
		res.render('selectRestaurant', { title: 'Restaurants table', userData: data.rows });
	});
}); */

router.get('/:rname-:location', function(req, res, next) {
 	var rname = req.params.rname;
	var location = req.params.location;
	res.render('insertMenu', { title: rname , location: location });
});

router.post('/:rname-:location', async function(req, res, next) {
	// Retrieve Information
	var course  = req.body.course;
	var rname = req.params.rname;
	var location = req.params.location;
	var a = req.body.food;
	a = a.split("\r\n");

	var fname;
	var price;
	var insert_query = "";

	for (var i = 0; i < a.length; i++) {
		var t = a[i].split("-");
		fname = t[0];
		price = t[1];
		insert_query += "INSERT INTO Menu (fname, rname, location, course, price) VALUES ('"+ fname + "','" + rname +"','" + location + "','" + course + "'," + price +");\n";
	}
	console.log(insert_query);
/* test data
chicken rice-2.50
pizaa-10.50
noodle-0.10
love-99999

water-2.50
coke-10.50
leaf broth-0.10
bean juice-0.01
happiness-99999

salad-50
pickles-10
squid-0.45
death-0.00

stuff-99
	*/
	// Construct Specific SQL Query
	await pool.query(insert_query, (err, data) => {
        if (err) {
            console.log(err);
		}
		res.redirect('/selectRestaurant/' + rname + '-' + location);
	});

	
});

module.exports = router;
