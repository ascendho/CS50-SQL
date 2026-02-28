-- Which cities have the highest average graduation rate across all their schools?
SELECT schools.city, ROUND(AVG(graduation_rates.graduated), 2) AS avg_graduation_rate
FROM schools
JOIN graduation_rates ON schools.id = graduation_rates.school_id
GROUP BY schools.city
ORDER BY avg_graduation_rate DESC
LIMIT 10;