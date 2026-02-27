-- Return latitude, longitude, and 50m temperature within the Arabian Sea
SELECT latitude, longitude, "50m"
FROM normals
WHERE latitude BETWEEN 0 AND 20
  AND longitude BETWEEN 55 AND 75;