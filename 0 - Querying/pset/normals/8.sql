-- Find the 10 locations with the lowest normal ocean surface temperature
SELECT latitude, longitude, "0m"
FROM normals
ORDER BY "0m" ASC, latitude ASC
LIMIT 10;