var express = require('express');
var router = express.Router();

const { Pool } = require('pg')

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: true
});



router.get('/', async function(req, res, next) {
    var sql_query = "SELECT * FROM (userAccount u Left outer JOIN customer c ON u.username = c.username) LEFT OUTER JOIN preferences p ON (u.username = p.username) WHERE u.username = '";
    if(req.isAuthenticated()){
        await (req.user)
        var username = req.user.username
        sql_query = sql_query + req.user.username + "'";
        console.log(sql_query);
        pool.query(sql_query, (err, data) => {
            res.render('account', { title: 'Account', username: username, userData: data.rows});
        });
        
    } else {
        res.render('login', { title: 'Login'});
    }
  });

  router.get('/:user', async function(req, res, next) {
    var sql_query = "SELECT * FROM (userAccount u Left outer JOIN customer c ON u.username = c.username) LEFT OUTER JOIN preferences p ON (u.username = p.username) WHERE u.username = '";

        var username = req.params.user
        sql_query = sql_query + username + "'";
        console.log(sql_query);
        pool.query(sql_query, (err, data) => {
            res.render('account', { title: 'Account', username: username, userData: data.rows});
        });
        
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

router.get('/:user/recommend', async function(req, res, next) {
    var user = req.params.user;
    //var drop = "DROP VIEW IF EXISTS preferredRestaurants; \n"
    var query =  "WITH X AS (SELECT RP.RName, RP.branchID, RP.cuisineType, RP.area, ROUND(AVG(M.price),2) as avgPrice \n" +
                    "FROM RestaurantProfile AS RP JOIN Menu AS M \n" +
                    "ON RP.RName = M.RName \n" +
                    "AND RP.branchID = M.branchID \n" +
                    "AND M.course = 'Main' \n" +
                    "GROUP BY RP.RName, RP.branchID), \n" +
                "Y AS (SELECT RV.RName, RV.branchID, ROUND(AVG(RV.rating),1) as avgRating \n" +
                    "FROM RateVisit AS RV \n" +
                    "GROUP BY RV.RName, RV.branchID) \n" +
                "SELECT X.RName, X.branchID, Y.avgRating, X.avgPrice \n" +
                "FROM X, Preferences AS P, Y \n" +
                "WHERE P.username = '" + user + "' \n" +
                "AND P.prefArea = X.area \n" +
                "AND P.prefCuisinetype = X.cuisineType \n" +
                "AND P.prefBudget >= X.avgPrice \n" +
                "AND Y.RName = X.RName \n" +
                "AND Y.branchID = X.branchID \n" +
                "ORDER BY Y.avgRating DESC, X.avgPrice ASC \n" +
                "LIMIT 3; \n";    
    //var query2 = "SELECT * FROM preferredRestaurants; \n"
                console.log(query);

                await pool.query(query, (err, data) => {
                    if (data == null) {
                        res.render('recommend', { title: 'Recommendation', username: user, userData: data});
                    } else 
                    res.render('recommend', { title: 'Recommendation', username: user, userData: data.rows});
                
                });
  });

  router.get('/:user/favourites', async function(req, res, next) {
    var user = req.params.user;
    var query = "select * from favourites where username ='" + user +"'";
    console.log(query);
    await pool.query(query, (err, data) => {
        res.render('favourites', { title: 'Favourites', username: user, userData : data.rows});

        if (data == null) {
            res.render('favourites', { title: 'favouritess', username: user, userData: data});
        } else 
        res.render('favourites', { title: 'favourites', username: user, userData: data.rows}); 
    
    });   

  });

  router.get('/favourites/:rname-:location', async function(req, res, next) {
    var rname = req.params.rname;
    var location = req.params.location;
    if(!req.isAuthenticated()){
        res.redirect('/login/');
        return;
    }
    await (req.user)
    var username = req.user.username
    var query1 = "INSERT INTO favourites (username,RName,branchID) VALUES ('"+username+"','"+rname+"','"+location+"')";
        console.log(query1);
        pool.query(query1, (err, data) => {
            res.redirect('/account/'+username+'/favourites');
        });
        

  });

  router.get('/:user/reservation', async function(req, res, next) {
    var user = req.params.user;
    var query = "select * from Reservation where username ='" + user +"'";
    console.log(query);
    await pool.query(query, (err, data) => {
        if (data == null) {
            res.render('reservation', { title: 'Reservation', username: user, userData: data});
        } else 
        res.render('reservation', { title: 'Reservation', username: user, userData: data.rows}); 
    });   
  });

  router.get('/:user/friendrating', async function(req, res, next) {
    var user = req.params.user;
    var query = "select * from friendratings('" + user +"')";
    console.log(query);
    await pool.query(query, (err, data) => {
        if (data == null) {
            res.render('friendRating', { title: 'Friends Ratings', username: user, userData: data});
        } else 
        res.render('friendRating', { title: 'Friends Ratings', username: user, userData: data.rows}); 
    });   
  });

  router.get('/:user/rate/:rname-:branchid-:year.:month.:day-:time', async function(req, res, next) {
    var user = req.params.user;
    var rname = req.params.rname;
    var branchid = req.params.branchid;
    var year = req.params.year;
    var month = req.params.month;
    var day = req.params.day;
    var time = req.params.time;

    month = parseInt(month) + 1;

    year = parseInt(year) + 1900;
    

    date = year +"-"+month+"-"+day;

    console.log(user+ "  " + rname+ " " + branchid+ " " +date + " " + time);



    res.render('rate', { title: 'Rate', username: user,  rname: rname, branchid: branchid, year: year, time: time}); 
  });

  router.post('/:user/rate/:rname-:branchid-:year-:month-:day-:time', async function(req, res, next) {
    var user = req.params.user;
    var rname = req.params.rname;
    var branchid = req.params.branchid;
    var year = req.params.year;
    var month = req.params.month;
    var day = req.params.day;
    var time = req.params.time;
    var rating = req.body.rating;



    year = year +"-"+month+"-"+day;

    console.log(user+ "  " + rname+ " " + branchid+ " " +date + " " + time);
    console.log(rating);
    var query = "INSERT INTO ratevisit (username,RName,branchID,reserveDate,reserveTime,rating, confirmation) VALUES ('"+user+"','"+rname+"','"+branchid+"','"+year+"','"+time+"',"+rating+",true);"
    console.log(query);

    await pool.query(query, (err, data) => {
        res.redirect('/selectRestaurant/ratings'); 
    }); 
 
  });



  
  module.exports = router;