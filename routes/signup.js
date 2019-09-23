
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
  res.render('signup', { title: 'Signup' });
});

router.post('/',  async function (req, res, next) {
    try{
        const client = await pool.connect()
        await client.query('BEGIN')
        var pwd = await bcrypt.hash(req.body.password, 5);
        await JSON.stringify(client.query('SELECT id FROM "users" WHERE "email"=$1', [req.body.username], function(err, result) {
            if(result.rows[0]){
            req.flash('warning', "This email address is already registered. <a href='/login'>Log in!</a>");
            res.redirect('/signup');
            } else{
            client.query('INSERT INTO users (id, "firstName", "lastName", email, password) VALUES ($1, $2, $3, $4, $5)', [uuidv4(), req.body.firstName, req.body.lastName, req.body.username, pwd], function(err, result) {
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
