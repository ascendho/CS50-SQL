-- Find average height and weight of players who debuted on or after January 1st, 2000
SELECT ROUND(AVG(height), 2) AS "Average Height",
       ROUND(AVG(weight), 2) AS "Average Weight"
FROM players
WHERE debut >= '2000-01-01';