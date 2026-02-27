-- Count players who bat right/throw left or bat left/throw right
SELECT COUNT(*)
FROM players
WHERE (bats = 'R' AND throws = 'L')
   OR (bats = 'L' AND throws = 'R');