-- Find all usernames of users who have logged in since 2024-01-01
-- Uses the search_users_by_last_login index on last_login_date
SELECT "username"
FROM "users"
WHERE "last_login_date" >= '2024-01-01';
