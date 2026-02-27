-- Find titles and air dates of episodes about patterns or sequences
-- that aired in Season 1 or Season 2
SELECT title, air_date
FROM episodes
WHERE (topic LIKE '%pattern%' OR topic LIKE '%sequence%')
  AND (season = 1 OR season = 2);