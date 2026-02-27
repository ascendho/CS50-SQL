-- Find the normal temperature at 225 meters of depth at 42.5° latitude, -69.5° longitude
SELECT "225m"
FROM normals
WHERE latitude = 42.5
  AND longitude = -69.5;