var express = require('express');
var router = express.Router();

const { Pool } = require('pg')

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: true
});

var restaurant;

/* SQL Query */
var sql_query = 'SELECT * FROM restaurant';

router.get('/', function(req, res, next) {
	pool.query(sql_query, (err, data) => {
		var restaurant = data.rows;
		res.render('selectRestaurant', { title: 'Restaurants table', userData: data.rows });
	});
});

router.get('/ratings', function(req, res, next) {
	var query = "Select * from ratevisit"
	pool.query(query, (err, data) => {
		res.render('selectRatings', { title: 'Ratings', userData: data.rows });
	});
});

router.get('/rewards', function(req, res, next) {
	var query = "Select * from rewards"
	pool.query(query, (err, data) => {
		res.render('viewRestaurantReward', { title: 'Rewards', userData: data.rows });
	});
});

router.get('/offers', function(req, res, next) {
	var query = "Select * from offermenu"
	pool.query(query, (err, data) => {
		res.render('viewRestaurantOffer', { title: 'Offers', userData: data.rows });
	});
});

router.get('/offers/claim/:oname-:rname-:branchid', async function(req, res, next) {
	var rname = req.params.rname;
	var branchID = req.params.branchid;
	var oname = req.params.oname;
	if(!req.isAuthenticated()){
		res.redirect('/login/'); return;
   }
   await (req.user)
   var user = req.user.username
	var get_points_query = "SELECT DISTINCT * FROM customer, rewards WHERE username = '"+user+"'";
	pool.query(get_points_query, (err, data) => {
		res.render('claiming', { title: 'Claiming', userData: data.rows, rname: rname, branchid : branchID, oname : oname });
	});
});

router.post('/offers/claim/:oname-:rname-:branchid', async function(req, res, next) {
	var rname = req.params.rname;
	var branchID = req.params.branchid;
	var oname = req.params.oname;
	if(!req.isAuthenticated()){
		res.redirect('/login/'); return;
   }
   await (req.user)
   var user = req.user.username
   var reward = req.body.rtier;
   var currDate = new Date();
   var month = currDate.getMonth();
   var year = currDate.getFullYear();
   var day = currDate.getDate();

   month = parseInt(month) + 1;

   year = parseInt(year);

   date = year +"-"+month+"-"+day;
   var time = currDate.getHours() + ":00:00";

   console.log(date);	
   console.log(reward);
   console.log(time);
	 var claim_q = "INSERT INTO claims (userName,rewardName,OName,RName,branchID,claimDate,claimTime) VALUES ('"+user+"','"+reward+"','"+oname+"','"+rname+"','"+branchID+"','"+date+"','"+time+"')";
   	console.log(claim_q);
	 pool.query(claim_q, (err, data) => {

		
//TODO add redirct
res.redirect('/account/claims/' + user); 

	 });
});

router.get('/:rname-:location', async function(req, res, next) {
	var rname = req.params.rname;
	var location = req.params.location;
	var new_query =  "Select * from getRestProfile('"+rname+"','"+location+"')";
	console.log(new_query);
	var data1;

	await pool.query(new_query, (err, data) => {
		if(err){
			console.log(err);
		} else {
			data1 = data;
			res.render('viewRestaurant', { title: rname , branchid: location, userData: data1.rows})
		}
	});
});

router.get('/:rname-:location/menu', async function(req, res, next) {
	var rname = req.params.rname;
	var location = req.params.location;

	
	var course_query = "SELECT DISTINCT * FROM menu" +  " WHERE rname = '" + rname + "'" + " AND branchID = '" + location + "' ORDER BY course";
	var menu;
	await pool.query(course_query, (err, data) => {
		if(err){
			console.log(err);
		} else {
			menu = data;
			res.render('viewRestaurantMenu', { title: rname , location: location, menu: menu.rows})
		}
	});

});

router.post('/:rname-:location/edit', async function(req, res, next) {
	var rname = req.params.rname;
	var location = req.params.location;
	var a = req.body.area;
	var c = req.body.cuisine;
		// Construct Specific SQL Query
		insert_query = "INSERT INTO RestaurantProfile VALUES ('" + rname + "','" + location + "', '" + c + "', '" + a + "') ON CONFLICT (rname,branchid) DO UPDATE SET CuisineType='" + c + "', area='" + a + "'";
		console.log(insert_query);
		pool.query(insert_query, (err, data) => {
			if (err){
				console.log(err);
			}
			res.redirect('/selectRestaurant/' + rname + "-" + location);
		});
});

router.get('/:rname-:location/edit', async function(req, res, next) {
	var rname = req.params.rname;
	var location = req.params.location;

			res.render('editRestProfile', { title: rname , location: location})


});

// router.get('/:rname-:location/availability', async function(req, res, next) {
// 	var rname = req.params.rname;
// 	var location = req.params.location;
// 	var new_query =  "SELECT * FROM availability WHERE rname = '" + rname + "'" + " AND branchid = '" + location + "'";
// 	console.log(new_query);
// 	var data1;

// 	await pool.query(new_query, (err, data) => {
// 		if(err){
// 			console.log(err);
// 		} else {
// 			data1 = data;
// 			res.render('viewRestaurantAvail', { title: rname , branchid: location, userData: data1.rows})
// 		}
// 	});
// });

router.get('/:rname-:location/availability', async function(req, res, next) {
	var rname = req.params.rname;
	var location = req.params.location;
	//var drop = "DROP VIEW IF EXISTS availableCapacity; \n"
	var avail_query =    /*	"CREATE VIEW availableCapacity(RName, branchID, capacityLeft, reserveDate, reserveTime) AS\n" + */
	"WITH reservedTablesCount(RName, branchID, totalreserved, reserveDate, reserveTime)\n" + 
	"	AS\n" + 
	"	(SELECT R.Rname, R.branchID, SUM(R.numTables) AS totalreserved, R.reserveDate, R.reserveTime\n" + 
	"FROM Reservation R\n" + 
	"GROUP BY R.Rname, R.branchID, R.reserveDate, R.reserveTime\n" + 
	")\n" + 
	"SELECT A.Rname, A.branchID, \n" + 
	"	(CASE \n" + 
	"		when R.totalreserved is null THEN A.numTables\n" + 
	"		ELSE A.numTables - R.totalreserved END) AS capacityLeft, A.reserveDate, A.reserveTime , R.totalreserved, A.numTables\n" + 
	"FROM Availability A \n" + 
	"Left JOIN reservedTablesCount R\n" + 
	"ON A.RName = R.RName AND A.branchID = R.branchID AND A.reserveDate = R.reserveDate AND A.reserveTime = R.reserveTime\n" + 
	"WHERE A.Rname = '"+ rname+"' AND A.branchID = '"+ location+"'; -- rName and branchID can be specified\n";
	
	//var q2 = "select * from availableCapacity;";
	
	var new_query =  "SELECT * FROM availability WHERE rname = '" + rname + "'" + " AND branchid = '" + location + "'";

	// await pool.query(drop, (err, data) => {
	// 	//console.log(data);
	// 	setTimeout(function(){}, 1000);
	// });

	pool.query(avail_query, (err, data) => {
		if(err){
			//console.log(err);
		} else {
			//console.log(data);
			res.render('viewRestaurantAvail', { title: rname , branchid: location, userData: data.rows})
		}
	});

	// await pool.query(avail_query, (err, data) => {
	// 	if (err) {
	// 	}
	// 	setTimeout(function(){
	// 		pool.query(q2, (err, data) => {
	// 			if(err){
	// 				//console.log(err);
	// 			} else {
	// 				//console.log(data);
	// 				res.render('viewRestaurantAvail', { title: rname , branchid: location, userData: data.rows})
	// 			}
	// 		});
	// 	}, 1000);
	// });

});

router.get('/:rname-:location/reservation', async function(req, res, next) {
	var rname = req.params.rname;
	var location = req.params.location;
	var a = req.body.area;
	var c = req.body.cuisine;
		// Construct Specific SQL Query
		select_query = "Select * FROM Reservation WHERE rname = '" + rname + "' AND branchID = '" + location+ "'";
		console.log(select_query);
		pool.query(select_query, (err, data) => {
			if (err){
				console.log(err);
			}
			res.render('viewRestaurantReservation', { title: rname , branchid: location, userData: data.rows})
		});
});

router.post('/book/:rname-:branchid-:year.:month.:day-:time', async function(req, res, next) {
	if(!req.isAuthenticated()){
		 res.redirect('/login/'); return;
	}
	await (req.user)
	var username = req.user.username
	var rname = req.params.rname;
    var branchid = req.params.branchid;
    var year = req.params.year;
    var month = req.params.month;
    var day = req.params.day;
	var time = req.params.time;
	var numTables = req.body.numTables;


	date = year +"-"+month+"-"+day;
	
	book_query = "INSERT INTO reservation (username,RName,branchID,numTables,reserveDate,reserveTime) VALUES ('"+username+"','"+rname+"','"+branchid+"',"+numTables+",'"+date+"','"+time+"')";
	console.log(book_query);
	await pool.query(book_query, (err, data) => {
		if (err) {
		}

		res.redirect('/account/'+username+'/reservation');

	});

});

router.get('/book/:rname-:branchid-:year.:month.:day-:time', async function(req, res, next) {
	if(!req.isAuthenticated()){
		res.redirect('/login/'); return;
   }
   await (req.user)
	var username = req.user.username
	var rname = req.params.rname;
    var branchid = req.params.branchid;
    var year = req.params.year;
    var month = req.params.month;
    var day = req.params.day;
	var time = req.params.time;

    month = parseInt(month) + 1;

    year = parseInt(year) + 1900;

	date = year +"-"+month+"-"+day;

	res.render('book', {username : username, rname : rname, branchid:branchid, year:year, month:month, day:day, time:time})

});


router.get('/delete/:rname-:branchid-:year.:month.:day-:time', async function(req, res, next) {
	if(!req.isAuthenticated()){
		res.redirect('/login/'); return;
   }
   await (req.user)
	var username = req.user.username
	var rname = req.params.rname;
    var branchid = req.params.branchid;
    var year = req.params.year;
    var month = req.params.month;
    var day = req.params.day;
	var time = req.params.time;

    month = parseInt(month) + 1;

    year = parseInt(year) + 1900;

	date = year +"-"+month+"-"+day;

	delete_query = "Delete from reservation WHERE username ='"+username+"' AND rname = '"+rname+"' AND branchID = '"+branchid+"' AND reserveDate = '"+date+"' AND reserveTime = '"+time+"'";
	console.log(book_query);
	await pool.query(delete_query, (err, data) => {
		if (err) {
		}

		res.redirect('/account/'+username+'/reservation');

	});

});

router.get('/analyze/', async function(req, res, next) {

	
	var ana_query = "select * from getpopularrestaurants()";

	await pool.query(ana_query, (err, data) => {
		if (err) {
		}

		res.render('analyze', {userData : data.rows})

	});

});



module.exports = router;
