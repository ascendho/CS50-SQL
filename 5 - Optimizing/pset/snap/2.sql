-- Find when the message with ID 151 expires
-- Uses the automatic index on the primary key column of the messages table
SELECT "expires_timestamp"
FROM "messages"
WHERE "id" = 151;
