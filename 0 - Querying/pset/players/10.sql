-- Find the tallest right-handed batters (6'6" or taller), showing their full name and height
SELECT first_name, last_name, height AS "Height (inches)"
FROM players
WHERE bats = 'R'
  AND height >= 78
ORDER BY height DESC, first_name ASC, last_name ASC;