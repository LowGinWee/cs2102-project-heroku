DROP TABLE IF EXISTS userAccount;
DROP TABLE IF EXISTS preferences;



CREATE TABLE userAccount (
    username VARCHAR(50) PRIMARY KEY,
    email VARCHAR(355) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    awardPoints INTEGER DEFAULT 0
);

CREATE TABLE preferences (
    username VARCHAR(50) PRIMARY KEY,
    cuisinetype VARCHAR(50),
    prefTime INTEGER,
    location VARCHAR(50),
    budget INTEGER,
    FOREIGN KEY (username) REFERENCES userAccount (username) ON DELETE CASCADE ON UPDATE CASCADE
);