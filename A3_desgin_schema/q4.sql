-- Qeury 4:
-- Report the username of the person who has purchased the most tickets. 
-- If there is a tie, report them all.

--  Sample output:
-- username | max_count 
------------+-----------
-- cristonc |         3


-- Find count of user purchases.
DROP VIEW IF EXISTS userPurchase CASCADE;
CREATE VIEW userPurchase AS
SELECT username, count(*)
FROM Ticket
GROUP BY username;

-- Output Final Result
SELECT username, count AS max_count
FROM userPurchase
WHERE count >= all (select count from userPurchase);