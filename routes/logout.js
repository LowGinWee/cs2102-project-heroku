var express = require('express');
var router = express.Router();

const { Pool } = require('pg')

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: true
});


/* SQL Query */
var sql_query = 'SELECT * FROM useraccount';

router.get('/', function(req, res, next) {
    req.logout();
    res.redirect('/login');
});


module.exports = router;
