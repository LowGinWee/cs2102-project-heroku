/*trigger to check if more tables are made available then max tables of the restaurant*/
INSERT INTO "availability" (RName,branchID,numTables,reserveDate,reserveTime) VALUES ('Itacho Sushi','Tampines',999,'2019-11-29','15:00');

/*Trigger to check if user is trying to book a reservation when there is no more tables*/
INSERT INTO "reservation" (username,RName,branchID,numTables,reserveDate,reserveTime) VALUES ('Nasim','Din Tai Fung','Marina Bay',20,'2019-12-02','11:00');
INSERT INTO "reservation" (username,RName,branchID,numTables,reserveDate,reserveTime) VALUES ('Paki','Din Tai Fung','Marina Bay',15,'2019-12-02','11:00');

/*Trigger to award the customer points whenever they rate a restaurant*/
INSERT INTO "ratevisit" (username,RName,branchID,reserveDate,reserveTime,rating, confirmation) VALUES ('Amethyst','Astons','Clementi','2019-11-16','14:00',1,true);
INSERT INTO "ratevisit" (username,RName,branchID,reserveDate,reserveTime,rating, confirmation) VALUES ('Giacomo','Astons','Clementi','2019-11-17','14:00',null,false);

/*Trigger to check if the respective claim is within the window period*/
INSERT INTO "claims" (userName,rewardName,OName,RName,branchID,claimDate,claimTime) VALUES ('Alexandra','30% off any purchase','Christmas Turkey','Astons','Ang Mo Kio','2019-08-10','14:00');
INSERT INTO "claims" (userName,rewardName,OName,RName,branchID,claimDate,claimTime) VALUES ('Alexandra','Holiday Giveaway','Winter Sashimi Set','Itacho Sushi','Tampines','2020-02-29','16:00');


/*Trigger to check if user has enough points for the claim and updates points accordingly*/
INSERT INTO "claims" (userName,rewardName,OName,RName,branchID,claimDate,claimTime) VALUES ('Brody','Chaching','Winter Sashimi Set','Itacho Sushi','Tampines','2019-11-29','16:00');
