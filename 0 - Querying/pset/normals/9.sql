-- Find the 10 locations with the highest normal ocean surface temperature
SELECT latitude, longitude, "0m"
FROM normals
ORDER BY "0m" DESC, latitude ASC
LIMIT 10;