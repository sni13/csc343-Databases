-- Bigger and smaller spenders.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5(
    client_id INTEGER,
    month VARCHAR(7),
    total FLOAT,
    comparison VARCHAR(30)
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Gather completed requests and the datetime of the request, as well as client_id and amount
-- Clients who has at least one ride.
DROP VIEW IF EXISTS completed CASCADE;
CREATE VIEW completed AS 
SELECT Request.request_id, Request.datetime, client_id, amount
FROM Request, Dropoff, Billed
WHERE Request.request_id = Dropoff.request_id and Request.request_id = Billed.request_id;

-- Convert datetime to required 7-char string "YYYY MM" formot
DROP VIEW IF EXISTS converted CASCADE;
CREATE VIEW converted AS 
SELECT client_id, 
       concat(to_char(datetime, 'YYYY'), ' ', to_char(datetime, 'MM')) AS month, 
       amount
FROM completed;

-- Get total amount for each client for each month 
DROP VIEW IF EXISTS counted CASCADE;
CREATE VIEW counted AS 
SELECT client_id, month, SUM(amount) as total
FROM converted
GROUP BY client_id, month;

-- Get the monthly averages of all clients
DROP VIEW IF EXISTS averaged CASCADE;
CREATE VIEW averaged AS 
SELECT month, AVG(total) as average
FROM counted
GROUP BY month;

-- Get result
DROP VIEW IF EXISTS result CASCADE;
CREATE VIEW result AS
(SELECT client_id, month, total, 'below' AS comparison
FROM counted C
WHERE total < (SELECT average FROM averaged A WHERE C.month=A.month)
)
UNION
(SELECT client_id, month, total, 'at or above' AS comparison
FROM counted C
WHERE total >= (SELECT average FROM averaged A WHERE C.month=A.month)
);

-- Count those client without any completed trips, set their months to be 0
DROP VIEW IF EXISTS complemented CASCADE;
CREATE VIEW complemented AS
SELECT client_id, month, 0 AS total, 'below' AS comparison
FROM Client, averaged
WHERE NOT EXISTS(SELECT client_id, month 
                 FROM counted 
                 WHERE counted.client_id = Client.client_id and counted.month = averaged.month);


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q5
((SELECT client_id, month, total, comparison FROM result)
UNION
(SELECT client_id, month, total, comparison FROM complemented))
;