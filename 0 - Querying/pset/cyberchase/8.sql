-- Count the number of episodes released from 2018 to 2023, inclusive
SELECT COUNT(*)
FROM episodes
WHERE air_date BETWEEN '2018-01-01' AND '2023-12-31';