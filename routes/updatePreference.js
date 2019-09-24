var express = require('express');
var router = express.Router();

const { Pool } = require('pg')
const pool = new Pool({
	connectionString: process.env.DATABASE_URL,
	ssl: true
  });

/* SQL Query */


// GET
router.get('/',async function(req, res, next) {
    if(req.isAuthenticated()){
        await (req.user)
        var sql_query = "SELECT * FROM preferences"
        sql_query = sql_query + " WHERE username ='" + req.user.username + "'";
        pool.query(sql_query, (err, data) => {
            if(err) {
                console.log(err);
            }
            if (data != null) {
                console.log(data.rows[0].cuisinetype);
                res.render('updatePreference', { title: 'Update Preferences', userData: data.rows});       
            } else {
                var emptyData = [{ cuisinetype:"", preftime:0, location:"", budget:0}];
                res.render('updatePreference', { title: 'Update Preferences', userData: emptyData});
            }
            
        });  
    } else {
        res.render('login', { title: 'Login'});
    }
});

// POST

router.post('/', async function(req, res, next) {
	// Retrieve Information
    var cuisinetype  = req.body.cuisinetype;
    var preftime  = req.body.preftime;
    var location  = req.body.location;
    var budget  = req.body.budget;
    await (req.user)
    var username = req.user.username;

	
	// Construct Specific SQL Query
    insert_query = "INSERT INTO preferences VALUES ('" + username + "','" + cuisinetype + "', " + preftime + ", '" + location + "', " + budget + ") ON CONFLICT (username) DO UPDATE SET cuisinetype='" + cuisinetype + "',preftime=" + preftime + ", location='" + location + "', budget=" + budget;
    console.log(insert_query);
	pool.query(insert_query, (err, data) => {
        if(err) {
            console.log(err);        
        }
        res.redirect('/account')
	});
});

module.exports = router;
