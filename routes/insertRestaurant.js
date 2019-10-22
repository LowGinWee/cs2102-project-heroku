var express = require('express');
var router = express.Router();

const { Pool } = require('pg')
const pool = new Pool({
	connectionString: process.env.DATABASE_URL,
	ssl: true
  });

/* SQL Query */
var sql_query = 'INSERT INTO restaurant VALUES';

// GET
router.get('/', function(req, res, next) {
	res.render('insertRestaurant', { title: 'Add Restaurants' });
});

// POST
router.post('/', function(req, res, next) {
	// Retrieve Information
	var rname  = req.body.rname;
	var branchid    = req.body.branchid;
    var tables = req.body.tables;
    //var rating = req.body.rating;
    var open = req.body.open;
	var close = req.body.close;
	var id = req.body.admin;

    var opening = open + " - " + close;
	
	// Construct Specific SQL Query
	var insert_query = sql_query + "('" + rname + "','" + branchid + "'," + tables + ",'" + opening +"','" + id +"')";
	console.log(insert_query);
	pool.query(insert_query, (err, data) => {
        if (err) {
            console.log(err);
        }
		res.redirect('/selectRestaurant')
	});
});

module.exports = router;
