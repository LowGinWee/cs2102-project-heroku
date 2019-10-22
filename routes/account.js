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

  router.get('/:user/friends', async function(req, res, next) {
    var user = req.params.user;
    var getFriends = "(SELECT friendUsername FROM Friends where myUsername = '" + user + "')";
    var sql_query = "SELECT * FROM " + getFriends + " f LEFT OUTER JOIN preferences p ON (f.friendUsername = p.username)";
    console.log(sql_query);
    pool.query(sql_query, (err, data) => {
        res.render('friends', { title: 'Friends', username: user, userData: data.rows});
    });
  });

  router.get('/:user/addfriends', async function(req, res, next) {
    var user = req.params.user;
        res.render('addFriends', { title: 'addFriends', username: user});
  });

  router.post('/:user/:user/add', async function(req, res, next) {
    var user = req.params.user;
    var del = req.body.del;
    var a = req.body.names;
	a = a.split("\r\n");
	var insert_query = "";
    if (del == 'true'){
        for (var i = 0; i < a.length; i++) {
            insert_query += "DELETE FROM friends WHERE myusername = '"+ user + "' AND friendusername = '" + a[i] +"';\n";
        }
    } else {
	    for (var i = 0; i < a.length; i++) {
		    insert_query += "INSERT INTO friends VALUES ('"+ user + "','" + a[i] +"');\n";
        }
    }
    
    console.log(insert_query);

    await pool.query(insert_query, (err, data) => {
       res.redirect('/account/');
    });
});

  
  module.exports = router;