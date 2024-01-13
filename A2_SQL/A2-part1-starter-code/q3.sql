-- Rest bylaw.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3(
    driver_id INTEGER,
    start DATE,
    driving INTERVAL,
    breaks INTERVAL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;


-- Define views for your intermediate steps here:

-- Find request_id to their driver_id for all requests
DROP VIEW IF EXISTS requestToDriver CASCADE;
CREATE VIEW requestToDriver AS 
SELECT A.request_id, driver_id
FROM Request A, Dispatch D, ClockedIn C
WHERE A.request_id = D.request_id and D.shift_id = C.shift_id;

-- Find corresponding pickup, dropoff time
DROP VIEW IF EXISTS requestToDriverAndTime CASCADE;
CREATE VIEW requestToDriverAndTime AS 
SELECT R.request_id, driver_id, P.datetime AS pickup_time, D.datetime AS dropoff_time
FROM requestToDriver R, Pickup P, Dropoff D
WHERE R.request_id = P.request_id and P.request_id = D.request_id
ORDER BY driver_id, pickup_time;

-- Find last drop off for each driver's each ride
DROP VIEW IF EXISTS driverBreakHelper CASCADE;
CREATE VIEW driverBreakHelper AS 
SELECT driver_id, 
        LAG(dropoff_time) OVER (PARTITION BY driver_id ORDER BY pickup_time) AS last_dropoff_time, 
        pickup_time, dropoff_time
FROM requestToDriverAndTime;

-- Find breaks * on the same day * for each driver's each ride
DROP VIEW IF EXISTS driverBreaks CASCADE;
CREATE VIEW driverBreaks AS 
SELECT driver_id, last_dropoff_time, pickup_time, (pickup_time - last_dropoff_time) AS break
FROM driverBreakHelper
where to_char(last_dropoff_time, 'YYYY-MM-DD') = to_char(pickup_time, 'YYYY-MM-DD');

-- Find duration of all rides that starts and finishes on the same dates
DROP VIEW IF EXISTS driverDurations CASCADE;
CREATE VIEW driverDurations AS
SELECT driver_id, pickup_time, dropoff_time, 
      (dropoff_time - pickup_time) AS duration
FROM requestToDriverAndTime
where to_char(pickup_time, 'YYYY-MM-DD') = to_char(dropoff_time, 'YYYY-MM-DD');

-- Find daily total_duration
DROP VIEW IF EXISTS driverDailyDurations CASCADE;
CREATE VIEW driverDailyDurations AS
SELECT driver_id, day, sum(duration) AS daily_durations
FROM 
(SELECT driver_id, duration, to_char(pickup_time, 'YYYY-MM-DD') AS day
FROM driverDurations) Q
GROUP BY driver_id, day;

-- Find drivers, days of durations > 12 hrs
DROP VIEW IF EXISTS driverDailyDurationsViolations CASCADE;
CREATE VIEW driverDailyDurationsViolations AS
SELECT driver_id, day, daily_durations
FROM driverDailyDurations
WHERE daily_durations >= '12:00:00';

-- Find daily breaks for each driver
DROP VIEW IF EXISTS driverDailyBreaks CASCADE;
CREATE VIEW driverDailyBreaks AS
SELECT driver_id, break AS daily_break, to_char(pickup_time, 'YYYY-MM-DD') AS day
FROM driverBreaks;

-- Find daily breaks >= 15 min for each driver
DROP VIEW IF EXISTS driverDaily15minBreaks CASCADE;
CREATE VIEW driverDaily15minBreaks AS
SELECT driver_id, break, to_char(pickup_time, 'YYYY-MM-DD') AS day
FROM driverBreaks
WHERE break > '00:15:00';


-- Find 3 consecutive rows for each driver in the table
DROP VIEW IF EXISTS consecutiveDaysViolations CASCADE;
CREATE VIEW consecutiveDaysViolations AS
SELECT  driver_id, 
        day AS startDay,
       LEAD(day) OVER ( 
                       PARTITION BY driver_id
                       ORDER BY day) AS nextDay,
       LEAD(day, 2) OVER ( 
                        PARTITION BY driver_id
                       ORDER BY day) AS dayAfterNextDay
FROM driverDailyDurationsViolations;

-- Find 3 consecutive days of violation about total durations
DROP VIEW IF EXISTS consecutiveDaysFiltered CASCADE;
CREATE VIEW consecutiveDaysFiltered AS
SELECT driver_id, startDay, nextDay, dayAfterNextDay
FROM consecutiveDaysViolations
WHERE extract(day from nextDay::timestamp - startDay::timestamp) = 1
    and extract(day from dayAfterNextDay::timestamp - nextDay::timestamp) = 1;

-- Find drivers with 3 consecutive days of violation and has never taken 15breaks
DROP VIEW IF EXISTS consecutiveAndNoBreak CASCADE;
CREATE VIEW consecutiveAndNoBreak AS
(SELECT driver_id, startDay, nextDay, dayAfterNextDay
FROM consecutiveDaysFiltered)
EXCEPT
(SELECT driver_id, startDay, nextDay, dayAfterNextDay
FROM consecutiveDaysFiltered NATURAL JOIN driverDaily15minBreaks
WHERE day = startDay or day = nextDay or day = dayAfterNextDay);


-- Find total durations (or driving)
DROP VIEW IF EXISTS result_driving CASCADE;
CREATE VIEW result_driving AS
SELECT A.driver_id, startDay::date AS start, 
        sum(daily_durations) AS driving
FROM consecutiveAndNoBreak A, driverDailyDurations B
WHERE A.driver_id = B.driver_id 
     and B.day in (startDay, nextDay, dayAfterNextDay)
GROUP BY A.driver_id, startDay;

-- Find total breaks (or driving)
DROP VIEW IF EXISTS result_breaks CASCADE;
CREATE VIEW result_breaks AS
SELECT A.driver_id, startDay::date AS start, 
        sum(daily_break) AS breaks
FROM consecutiveAndNoBreak A, driverDailyBreaks B
WHERE A.driver_id = B.driver_id 
     and B.day in (startDay, nextDay, dayAfterNextDay)
GROUP BY A.driver_id, startDay;

-- Find driver_id, start, with zero breaks
DROP VIEW IF EXISTS result_zero_breaks CASCADE;
CREATE VIEW result_zero_breaks AS
SELECT driver_id, start 
        FROM result_driving 
        EXCEPT (SELECT driver_id, start FROM  result_breaks);

-- Find total breaks (or driving)
DROP VIEW IF EXISTS result_breaks_adj CASCADE;
CREATE VIEW result_breaks_adj AS
(SELECT driver_id, start, breaks 
            FROM result_breaks)
UNION
(
SELECT driver_id, start, '00:00:00' AS breaks
FROM
    (SELECT driver_id, start FROM result_zero_breaks) K
);


-- Find result
DROP VIEW IF EXISTS result CASCADE;
CREATE VIEW result AS
SELECT D.driver_id, D.start, driving, breaks
FROM result_driving D NATURAL JOIN result_breaks_adj B;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3
(SELECT driver_id, start, driving, breaks
FROM result);






