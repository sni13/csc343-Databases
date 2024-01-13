-- Consistent raters.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q9 CASCADE;

CREATE TABLE q9(
    client_id INTEGER,
    email VARCHAR(30)
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:

-- Find clients who have completed at least one ride and each row their request_id 
DROP VIEW IF EXISTS atLeastOneRide CASCADE;
CREATE VIEW atLeastOneRide AS 
SELECT client_id, D.request_id
FROM Request R JOIN Dropoff D
ON R.request_id=D.request_id;

-- Find client and each row of their ever rated request_id
DROP VIEW IF EXISTS clientRated CASCADE;
CREATE VIEW clientRated AS 
SELECT client_id, DriverRating.request_id
FROM Request NATURAL JOIN DriverRating;

-- Find request_id to their driver_id
DROP VIEW IF EXISTS requestToDriver CASCADE;
CREATE VIEW requestToDriver AS 
SELECT A.request_id, driver_id
FROM atLeastOneRide A, Dispatch D, ClockedIn C
WHERE A.request_id = D.request_id and D.shift_id = C.shift_id;

-- Filter atLeastOneRide to distinct pairs of (client_id, driver_id )
DROP VIEW IF EXISTS atLeastOneRideFiltered CASCADE;
CREATE VIEW atLeastOneRideFiltered AS 
SELECT DISTINCT client_id, driver_id 
FROM requestToDriver NATURAL JOIN atLeastOneRide;


-- Filter atLeastOneRide to distinct pairs of (client_id, driver_id )
DROP VIEW IF EXISTS clientRatedFiltered CASCADE;
CREATE VIEW clientRatedFiltered AS 
SELECT DISTINCT client_id, driver_id 
FROM requestToDriver NATURAL JOIN clientRated;


-- Find the unrated client_id, driver_id pairs
DROP VIEW IF EXISTS missingFiltered CASCADE;
CREATE VIEW missingFiltered AS 
SELECT client_id, driver_id
FROM atLeastOneRideFiltered
EXCEPT
(SELECT client_id, driver_id FROM clientRatedFiltered);


-- Find the client_id of which never appeared in any pairs in missing
DROP VIEW IF EXISTS allRated CASCADE;
CREATE VIEW allRated AS 
SELECT client_id FROM atLeastOneRideFiltered
EXCEPT
(SELECT client_id FROM missingFiltered);


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q9
(SELECT allRated.client_id, email
FROM allRated NATURAL JOIN Client
);

