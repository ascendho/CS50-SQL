-- List average colors of Hokusai prints that include "river" in the English title
SELECT average_color
FROM views
WHERE artist = 'Hokusai'
  AND english_title LIKE '%river%';