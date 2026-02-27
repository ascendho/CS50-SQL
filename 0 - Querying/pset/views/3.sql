-- Count how many Hokusai prints include "Fuji" in the English title
SELECT COUNT(*)
FROM views
WHERE artist = 'Hokusai'
  AND english_title LIKE '%Fuji%';