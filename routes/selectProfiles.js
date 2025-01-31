var express = require('express');
var router = express.Router();

const { Pool } = require('pg')

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: true
});


/* SQL Query */
var sql_query = 'SELECT * FROM preferences';

router.get('/', function(req, res, next) {
	pool.query(sql_query, (err, data) => {
		res.render('selectProfiles', { title: 'Profiles table', userData: data.rows });
	});
});

module.exports = router;
