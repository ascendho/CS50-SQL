-- Find normal temperatures at 0m, 100m, and 200m near the Mariana Trench (12.5°N, 143.5°E)
SELECT "0m", "100m", "200m"
FROM normals
WHERE latitude = 12.5
  AND longitude = 143.5;