-- Qeury 1:
-- For each concert, report the total value of all tickets 
-- sold and the percentage of the venue that was sold.

--  Sample output:
--   name       |      datetime       | percentage_sold  | total_value_sold 
---------------------------------------+---------------------+--------------
-- Ron Sexsmith | 2022-12-03 19:30:00 | 0.04000000000000000000 |      130
 
SET SEARCH_PATH TO ticketchema, public;

-- Find number of total seats for all concerts
DROP VIEW IF EXISTS concertAllSeats CASCADE;
CREATE VIEW concertAllSeats AS 
SELECT concert_id, count(seat_id) AS total
FROM Concert JOIN Venue ON Concert.venue_id = Venue.venue_id
             JOIN Section ON Venue.venue_id = Section.venue_id
             JOIN Seat ON Section.section_id = Seat.section_id
GROUP BY concert_id
ORDER BY concert_id;

-- Find number of seats sold for all concerts
DROP VIEW IF EXISTS concertSoldSeats CASCADE;
CREATE VIEW concertSoldSeats AS
(SELECT concert_id, count(seat_id) AS sold
FROM Ticket
GROUP BY concert_id
ORDER BY concert_id)
UNION
(SELECT concert_id, 0 AS sold
FROM concert NATURAL JOIN
(SELECT concert_id FROM Concert except (SELECT concert_id FROM Ticket)) Q
);

-- Find percentage of seats sold for each concert.
DROP VIEW IF EXISTS percentageSeatsSold CASCADE;
CREATE VIEW percentageSeatsSold AS
SELECT concert_id, sold * 1.0/total AS percentage_sold
FROM concertAllSeats NATURAL JOIN concertSoldSeats;

-- Find sum of prices for all seats ever sold, for each concert.
DROP VIEW IF EXISTS concertTotalSold CASCADE;
CREATE VIEW concertTotalSold AS
(SELECT Ticket.concert_id, sum(price) AS total_value_sold
FROM Ticket JOIN Seat ON Ticket.seat_id = Seat.seat_id
            JOIN Price ON Seat.section_id = Price.section_id 
                          and Ticket.concert_id = Price.concert_id
GROUP BY Ticket.concert_id)
UNION
(SELECT concert_id, 0 AS sold
FROM concert NATURAL JOIN
(SELECT concert_id FROM Concert except (SELECT concert_id FROM Ticket)) Q
);

-- Output Final Result
Select name as concert_name, datetime, percentage_sold, total_value_sold
FROM percentageSeatsSold NATURAL JOIN concertTotalSold NATURAL JOIN Concert;

