-- Find the English title and entropy of high-entropy prints (entropy > 7.5),
-- showing the most visually complex works, sorted from most to least complex
SELECT english_title, artist, entropy AS "Complexity Score"
FROM views
WHERE entropy > 7.5
ORDER BY entropy DESC;