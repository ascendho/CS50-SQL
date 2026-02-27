-- Find the average ocean surface temperature along the equator (latitude -0.5 to 0.5)
SELECT ROUND(AVG("0m"), 2) AS "Average Equator Ocean Surface Temperature"
FROM normals
WHERE latitude BETWEEN -0.5 AND 0.5;