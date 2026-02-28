SELECT "players"."first_name", "players"."last_name"
FROM "players"
WHERE "players"."id" IN (
    SELECT "salaries"."player_id"
    FROM "salaries"
    JOIN "performances" ON "performances"."player_id" = "salaries"."player_id"
        AND "performances"."year" = "salaries"."year"
    WHERE "salaries"."year" = 2001 AND "performances"."H" > 0
    ORDER BY "salaries"."salary" / "performances"."H" ASC
    LIMIT 10
)
AND "players"."id" IN (
    SELECT "salaries"."player_id"
    FROM "salaries"
    JOIN "performances" ON "performances"."player_id" = "salaries"."player_id"
        AND "performances"."year" = "salaries"."year"
    WHERE "salaries"."year" = 2001 AND "performances"."RBI" > 0
    ORDER BY "salaries"."salary" / "performances"."RBI" ASC
    LIMIT 10
)
ORDER BY "players"."id" ASC;
