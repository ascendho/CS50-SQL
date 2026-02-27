-- Find the hometown (city, state, country) of Jackie Robinson
SELECT birth_city, birth_state, birth_country
FROM players
WHERE first_name = 'Jackie'
  AND last_name = 'Robinson';