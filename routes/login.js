
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
    res.render('login', {title: "Log in", userData: req.user});
    }
});

router.post('/', passport.authenticate('local', {
    successRedirect: '/account',
    failureRedirect: '/login',
    failureFlash: true
    }), function(req, res) {
    if (req.body.remember) {
    req.session.cookie.maxAge = 30 * 24 * 60 * 60 * 1000; // Cookie expires after 30 days
    } else {
    req.session.cookie.expires = false; // Cookie expires at end of session
    }
    res.redirect('/');
    });

passport.use('local', new LocalStrategy({passReqToCallback : true}, (req, username, password, done) => {
 
    loginAttempt();
    async function loginAttempt() {
        const client = await pool.connect()
        try{
            await client.query('BEGIN')

            var sqlQuery = "SELECT username, email, password FROM userAccount WHERE email='" + username + "'";

           await (client.query(sqlQuery, function(err, result) {
            
                if (err) {
                    return done(err)
                } 
                if (result.rows[0] == null) {
                    //TODO:display error for wrong login details
                    return done(null, false);
                } else {
                    if(result.rows[0].password == password) {
                        console.log("user loged in");
                        return done(null,{email: result.rows[0].email, username: result.rows[0].username});            
                    } else {
                        console.log("user wrong password");
                        return done(null, false);
                    }    
                    
                    /*bcrypt.compare(password, result.rows[0].password, function(err, check) {
                        if (err){
                            console.log('Error while checking password');
                            return done();
                        } else if (check){
                            return done(null, {email: result.rows[0].email, username: result.rows[0].username});
                        } else {
                            return done(null, false);
                        }
                    }); */
                }
            }))
        }
        
        catch(e){throw (e);}
    };
}))

passport.serializeUser(function(user, done) {
    done(null, user);
});

passport.deserializeUser(function(user, done) {
    done(null, user);
});

module.exports = router;
    
    