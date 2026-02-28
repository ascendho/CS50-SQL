-- Find the username of the most popular user (most messages received)
-- Uses the search_messages_by_to_user_id index
SELECT "username"
FROM "users"
WHERE "id" = (
    SELECT "to_user_id"
    FROM "messages"
    GROUP BY "to_user_id"
    ORDER BY COUNT(*) DESC
    LIMIT 1
);
