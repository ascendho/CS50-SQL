-- Find the highest contrast value of prints by Hokusai
SELECT MAX(contrast) AS "Maximum Contrast"
FROM views
WHERE artist = 'Hokusai';