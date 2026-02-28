SELECT "year", "salary"
FROM "salaries"
WHERE "player_id" = (
    SELECT "id" FROM "players"
    WHERE "first_name" = 'Cal' AND "last_name" = 'Ripken' AND "birth_year" = 1960
)
ORDER BY "year" DESC;
