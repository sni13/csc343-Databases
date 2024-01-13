-- Ratings histogram.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q7 CASCADE;

CREATE TABLE q7(
    driver_id INTEGER,
    r5 INTEGER,
    r4 INTEGER,
    r3 INTEGER,
    r2 INTEGER,
    r1 INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:

-- Find request_id to their driver_id
DROP VIEW IF EXISTS requestToDriver CASCADE;
CREATE VIEW requestToDriver AS 
SELECT A.request_id, driver_id
FROM DriverRating A, Dispatch D, ClockedIn C
WHERE A.request_id = D.request_id and D.shift_id = C.shift_id;

-- ***** r1 ***** --
-- Find request_id, driver_id for all r1
DROP VIEW IF EXISTS r1 CASCADE;
CREATE VIEW r1 AS 
SELECT driver_id, count(rating) AS r1
FROM requestToDriver R 
    NATURAL JOIN
    (SELECT request_id, rating
    FROM DriverRating
    WHERE rating = 1
    ) Q
GROUP BY driver_id
;

-- Adjust r1 by adding those driver_id has no r1 records
DROP VIEW IF EXISTS r1adjusted CASCADE;
CREATE VIEW r1adjusted AS 
(SELECT driver_id, 0 AS r1
FROM 
    (SELECT driver_id
    FROM Driver
    EXCEPT (SELECT driver_id FROM r1)
    ) R
)
UNION
(SELECT driver_id, r1 FROM r1);


-- ***** r2 ***** --
-- Find request_id, driver_id for all r2
DROP VIEW IF EXISTS r2 CASCADE;
CREATE VIEW r2 AS 
SELECT driver_id, count(rating) AS r2
FROM requestToDriver R 
    NATURAL JOIN
    (SELECT request_id, rating
    FROM DriverRating
    WHERE rating = 2
    ) Q
GROUP BY driver_id
;

-- Adjust r2 by adding those driver_id has no r2 records
DROP VIEW IF EXISTS r2adjusted CASCADE;
CREATE VIEW r2adjusted AS 
(SELECT driver_id, 0 AS r2
FROM 
    (SELECT driver_id
    FROM Driver
    EXCEPT (SELECT driver_id FROM r2)
    ) R
)
UNION
(SELECT driver_id, r2 FROM r2);


-- ***** r3 ***** --
-- Find request_id, driver_id for all r3
DROP VIEW IF EXISTS r3 CASCADE;
CREATE VIEW r3 AS 
SELECT driver_id, count(rating) AS r3
FROM requestToDriver R 
    NATURAL JOIN
    (SELECT request_id, rating
    FROM DriverRating
    WHERE rating = 3
    ) Q
GROUP BY driver_id
;

-- Adjust r3 by adding those driver_id has no r3 records
DROP VIEW IF EXISTS r3adjusted CASCADE;
CREATE VIEW r3adjusted AS 
(SELECT driver_id, 0 AS r3
FROM 
    (SELECT driver_id
    FROM Driver
    EXCEPT (SELECT driver_id FROM r3)
    ) R
)
UNION
(SELECT driver_id, r3 FROM r3);


-- ***** r4 ***** --
-- Find request_id, driver_id for all r4
DROP VIEW IF EXISTS r4 CASCADE;
CREATE VIEW r4 AS 
SELECT driver_id, count(rating) AS r4
FROM requestToDriver R 
    NATURAL JOIN
    (SELECT request_id, rating
    FROM DriverRating
    WHERE rating = 4
    ) Q
GROUP BY driver_id
;

-- Adjust r4 by adding those driver_id has no r4 records
DROP VIEW IF EXISTS r4adjusted CASCADE;
CREATE VIEW r4adjusted AS 
(SELECT driver_id, 0 AS r4
FROM 
    (SELECT driver_id
    FROM Driver
    EXCEPT (SELECT driver_id FROM r4)
    ) R
)
UNION
(SELECT driver_id, r4 FROM r4);

-- ***** r5 ***** --
-- Find request_id, driver_id for all r5
DROP VIEW IF EXISTS r5 CASCADE;
CREATE VIEW r5 AS 
SELECT driver_id, count(rating) AS r5
FROM requestToDriver R 
    NATURAL JOIN
    (SELECT request_id, rating
    FROM DriverRating
    WHERE rating = 5
    ) Q
GROUP BY driver_id
;

-- Adjust r5 by adding those driver_id has no r5 records
DROP VIEW IF EXISTS r5adjusted CASCADE;
CREATE VIEW r5adjusted AS 
(SELECT driver_id, 0 AS r5
FROM 
    (SELECT driver_id
    FROM Driver
    EXCEPT (SELECT driver_id FROM r5)
    ) R
)
UNION
(SELECT driver_id, r5 FROM r5);


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q7
(SELECT r1adjusted.driver_id, r5, r4, r3, r2, r1
FROM r1adjusted , r2adjusted, r3adjusted, r4adjusted, r5adjusted
WHERE r1adjusted.driver_id = r2adjusted.driver_id
    and r2adjusted.driver_id = r3adjusted.driver_id
    and r3adjusted.driver_id = r4adjusted.driver_id
    and r4adjusted.driver_id = r5adjusted.driver_id
);





