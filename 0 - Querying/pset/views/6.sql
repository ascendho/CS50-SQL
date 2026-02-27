-- Find the average entropy of prints by Hiroshige, rounded to two decimal places
SELECT ROUND(AVG(entropy), 2) AS "Hiroshige Average Entropy"
FROM views
WHERE artist = 'Hiroshige';