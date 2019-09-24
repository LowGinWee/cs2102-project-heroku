var express = require('express');
var router = express.Router();

const { Pool } = require('pg')

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: true
});



router.get('/', async function(req, res, next) {
    var sql_query = "SELECT * FROM userAccount u LEFT OUTER JOIN preferences p ON (u.username = p.username) WHERE u.username = '";
    if(req.isAuthenticated()){
        await (req.user)
        var username = req.user.username
        sql_query = sql_query + req.user.username + "'";
        console.log(sql_query);
        pool.query(sql_query, (err, data) => {
            console.log(data.rows[0].preftime);
            res.render('account', { title: 'Account', username: username, userData: data.rows});
        });
        
    } else {
        res.render('login', { title: 'Login'});
    }
  });

  
  module.exports = router;