-- Find first and last names of players not born in the United States
SELECT first_name, last_name
FROM players
WHERE birth_country != 'USA'
ORDER BY first_name ASC, last_name ASC;