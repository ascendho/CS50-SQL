-- List the English titles of the 5 brightest prints by Hiroshige, most to least bright
SELECT english_title
FROM views
WHERE artist = 'Hiroshige'
ORDER BY brightness DESC
LIMIT 5;