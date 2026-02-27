-- Find first name, last name, and debut date of players born in Pittsburgh, PA
SELECT first_name, last_name, debut
FROM players
WHERE birth_city = 'Pittsburgh'
  AND birth_state = 'PA'
ORDER BY debut DESC, first_name ASC, last_name ASC;