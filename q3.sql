-- Qeury 3:
-- For each venue, report the percentage of seats that are accessible.

--  Sample output:
-- venue_id |    venue_name    | percentage_accessible  
------------+------------------+------------------------
--        1 | Massey Hall      | 0.24000000000000000000
--        2 | Roy Thomson Hall | 0.00000000000000000000
--        3 | ScotiaBank Arena | 0.33333333333333333333

-- Find total number of seats for all venues
DROP VIEW IF EXISTS venueAllSeats CASCADE;
CREATE VIEW venueAllSeats AS 
SELECT Venue.venue_id, count(seat_id) AS total
FROM Venue JOIN Section ON Venue.venue_id = Section.venue_id
             JOIN Seat ON Section.section_id = Seat.section_id
GROUP BY Venue.venue_id
ORDER BY Venue.venue_id;

-- Find total number of accesible seats for all venues
DROP VIEW IF EXISTS venueAccessibleSeats CASCADE;
CREATE VIEW venueAccessibleSeats AS 
SELECT Venue.venue_id, count(seat_id) AS accessible_count
FROM Venue JOIN Section ON Venue.venue_id = Section.venue_id
             JOIN Seat ON Section.section_id = Seat.section_id
WHERE Seat.accessible = true
GROUP BY Venue.venue_id
ORDER BY Venue.venue_id;

-- Adjust accessible seats count for those with count of 0
DROP VIEW IF EXISTS venueAccessibleSeatsAdj CASCADE;
CREATE VIEW venueAccessibleSeatsAdj AS 
(SELECT * FROM venueAccessibleSeats)
UNION
(SELECT venue_id, 0 AS accessible_count
FROM Venue NATURAL JOIN
(SELECT venue_id FROM Venue except (SELECT venue_id FROM venueAccessibleSeats)) Q
);

-- Output Final Result
SELECT venue_id, name AS venue_name, accessible_count * 1.0/total AS percentage_accessible
FROM venueAccessibleSeatsAdj NATURAL JOIN venueAllSeats NATURAL JOIN Venue;


