CREATE TABLE userAccount (
    username VARCHAR(50) PRIMARY KEY,
    email VARCHAR(355) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    awardPoints INTEGER DEFAULT 0
);