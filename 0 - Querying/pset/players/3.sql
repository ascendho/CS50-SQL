-- Find the ids of rows where debut is missing
SELECT id
FROM players
WHERE debut IS NULL;