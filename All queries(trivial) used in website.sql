
/*To show user's data and preferences. If preference is not created, join null*/
"SELECT * FROM userAccount u LEFT OUTER JOIN preferences p ON (u.username = p.username) WHERE u.username = '";

/*To insert or update user preference*/
insert_query = "INSERT INTO preferences VALUES ('" + username + "','" + cuisinetype + "','" + location + "', " + budget + ") ON CONFLICT (username) DO UPDATE SET prefCuisinetype='" + cuisinetype + "', prefArea='" + location + "', prefBudget=" + budget;

/*To show all friends and their preferences. If preferences are not created, show null*/
var getFriends = "(SELECT friendUsername FROM Friends where myUsername = '" + user + "')";
var sql_query = "SELECT * FROM " + getFriends + " f LEFT OUTER JOIN preferences p ON (f.friendUsername = p.username)";

/*to rate a visit*/
var query = "INSERT INTO ratevisit (username,RName,branchID,reserveDate,reserveTime,rating, confirmation) VALUES ('"+user+"','"+rname+"','"+branchid+"','"+year+"','"+time+"',"+rating+",true);"

/*To select a Restaurant and to display its profile.  If profile is not created, show null*/
var new_query =  "SELECT * FROM restaurant r LEFT OUTER JOIN restaurantprofile p ON (r.rname = p.rname)" + " WHERE r.rname = '" + rname + "'" + " AND r.branchid = '" + location + "'";

/*Insert or update a Restaurant's profile*/
insert_query = "INSERT INTO RestaurantProfile VALUES ('" + rname + "','" + location + "', '" + c + "', '" + a + "') ON CONFLICT (rname,branchid) DO UPDATE SET CuisineType='" + c + "', area='" + a + "'";
