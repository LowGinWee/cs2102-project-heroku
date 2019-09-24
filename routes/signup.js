
var passport = require("passport");
var request = require('request');
const bcrypt = require('bcrypt')
const uuidv4 = require('uuid/v4');
const LocalStrategy = require('passport-local').Strategy;
const { Pool, Client } = require('pg')
const pool = new Pool({
	connectionString: process.env.DATABASE_URL,
	ssl: true
  });

var express = require('express');
var router = express.Router();
var app = express();

router.get('/', function(req, res, next) {
        if (req.isAuthenticated()) {
          res.redirect('/account');
          }
          else{
            res.render('signup', { title: 'Signup' });
          }


});

router.post('/',  async function (req, res, next) {
    try{
        
        const client = await pool.connect()
        await client.query('BEGIN')
        var pwd = await bcrypt.hash(req.body.password, 5);
        
        //var pwd = req.body.password;
        var sqlQuery = "SELECT * FROM userAccount WHERE email ='" + req.body.email + "' OR username ='" + req.body.username + "'";
        console.log(sqlQuery);
        await (client.query(sqlQuery, function(err, result) {
            if(result.rows[0]){
                req.flash('warning', "This email address or username is already registered. <a href='/login'>Log in!</a>");
                res.redirect('/signup');
            } else{
                var insertQuery = "INSERT INTO userAccount (username, email, password) VALUES" + "('" + req.body.username + "','" + req.body.email + "'," + pwd + ")";
                client.query(insertQuery, function(err, result) {
                    if(err){
                        console.log(err);
                    } else {
                        client.query('COMMIT')
                        console.log(result)
                        req.flash('success','User created.')
                        res.redirect('/login');
                        return;
                    }
                });        
            }
        }));
        client.release();
    } 
    catch(e){throw(e)}
});

module.exports = router;
