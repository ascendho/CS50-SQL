-- Find user IDs of mutual friends between lovelytrust487 and exceptionalinspiration482
-- Uses the sqlite_autoindex_friends_1 index on primary key columns of the friends table
SELECT "friend_id"
FROM "friends"
WHERE "user_id" = (
    SELECT "id"
    FROM "users"
    WHERE "username" = 'lovelytrust487'
)
INTERSECT
SELECT "friend_id"
FROM "friends"
WHERE "user_id" = (
    SELECT "id"
    FROM "users"
    WHERE "username" = 'exceptionalinspiration482'
);
