-- Count Hiroshige prints whose English titles refer to the "Eastern Capital"
SELECT COUNT(*)
FROM views
WHERE artist = 'Hiroshige'
  AND english_title LIKE '%Eastern Capital%';