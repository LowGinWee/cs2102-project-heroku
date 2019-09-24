var express = require('express');
var router = express.Router();

const { Pool } = require('pg')

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: true
});

var sql_query = 'SELECT * FROM userAccount';

router.get('/', async function(req, res, next) {
    //res.render('account', { title: 'Account', userData: req.user});
    if(req.isAuthenticated()){
        await (req.user)
        sql_query = sql_query + " WHERE username ='" + req.user.username + "'";
        console.log(sql_query);
        pool.query(sql_query, (err, data) => {
            console.log(data.rows[0].awardpoints);
            res.render('account', { title: 'Account', userData: data.rows});
        });
        
    } else {
        res.render('login', { title: 'Login'});
    }
  });

  
  module.exports = router;