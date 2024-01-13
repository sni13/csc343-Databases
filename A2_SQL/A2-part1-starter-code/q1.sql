-- Months.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1(
    client_id INTEGER,
    email VARCHAR(30),
    months INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:
-- Gather completed requests and the datetime of the request
DROP VIEW IF EXISTS completed CASCADE;
CREATE VIEW completed AS 
SELECT Request.request_id, Request.datetime, client_id
FROM Request, Dropoff
WHERE Request.request_id = Dropoff.request_id;

-- Convert datetime to month and year, and join to get the client info
DROP VIEW IF EXISTS converted CASCADE;
CREATE VIEW converted AS
SELECT 
client_id,
email,
EXTRACT(YEAR FROM datetime) AS year,
EXTRACT(MONTH FROM datetime) AS month
FROM completed NATURAL JOIN Client;

-- Count the distinct comb of (client_id, year, month)
DROP VIEW IF EXISTS counted CASCADE;
CREATE VIEW counted AS
SELECT
client_id, 
count(distinct concat(year, month)) AS months
FROM converted
GROUP BY client_id;

-- Count those client without any completed trips, set their months to be 0
DROP VIEW IF EXISTS complemented CASCADE;
CREATE VIEW complemented AS
SELECT
client_id, 
email,
0 AS months
FROM Client 
WHERE NOT EXISTS (SELECT client_id FROM counted WHERE Client.client_id = counted.client_id);


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1
((SELECT client_id, email, months 
    FROM counted NATURAL JOIN Client) 
UNION
(SELECT client_id, email, months
    FROM complemented));