-- List the English titles of the 5 prints with the least contrast by Hokusai, least to highest
SELECT english_title
FROM views
WHERE artist = 'Hokusai'
ORDER BY contrast ASC
LIMIT 5;