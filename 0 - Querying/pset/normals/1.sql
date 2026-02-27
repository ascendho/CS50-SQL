-- Find the normal ocean surface temperature at 42.5° latitude, -69.5° longitude (Gulf of Maine)
SELECT "0m"
FROM normals
WHERE latitude = 42.5
  AND longitude = -69.5;