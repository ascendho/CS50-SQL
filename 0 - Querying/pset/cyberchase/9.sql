-- Count the number of episodes released from 2002 to 2007, inclusive
SELECT COUNT(*)
FROM episodes
WHERE air_date BETWEEN '2002-01-01' AND '2007-12-31';