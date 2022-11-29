-- Qeury 2:
-- For each owner, report how many venues they own.

--  Sample output:
-- owner_id |                     owner_name                     | num_venues 
------------+-----------------------------------------------------+------------
--        1 | The Corporation of Massey Hall and Roy Thomson Hall |          2
--        2 | Maple Leaf Sports & Entertainment                   |          1
 
SET SEARCH_PATH TO ticketchema, public;

-- Output Final Result
-- Join Owner and Venue on owner_id and count number of venues each owner owns.
SELECT Venue.owner_id, Owner.name as owner_name, count(*) AS num_venues
FROM Venue JOIN Owner
ON Venue.owner_id = Owner.owner_id
GROUP BY Venue.owner_id, Owner.name
ORDER BY Venue.owner_id;