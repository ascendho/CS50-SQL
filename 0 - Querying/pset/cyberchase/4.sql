-- Find the titles of episodes that do not yet have a listed topic
SELECT title
FROM episodes
WHERE topic IS NULL;