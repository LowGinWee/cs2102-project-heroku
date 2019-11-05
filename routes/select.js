var express = require('express');
var router = express.Router();

const { Pool } = require('pg')

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: true
});


/* SQL Query */
var sql_query = 'SELECT u.username, u.email, u.password, c.awardpoints FROM useraccount u LEFT OUTER JOIN customer c on u.username = c.username';

router.get('/', function(req, res, next) {
	pool.query(sql_query, (err, data) => {
		res.render('select', { title: 'useraccount table', data: data.rows });
	});
});

module.exports = router;
