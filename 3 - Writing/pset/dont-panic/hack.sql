-- Step 1: Insert a false log entry to frame emily33.
-- It must look as if the admin account's password was changed TO emily33's password.
-- We do this BEFORE actually changing admin's password, so the old_password subquery
-- still reflects admin's current (original) password.
INSERT INTO "user_logs" ("type", "old_username", "new_username", "old_password", "new_password")
SELECT
    'update',
    'admin',
    'admin',
    (SELECT "password" FROM "users" WHERE "username" = 'admin'),
    (SELECT "password" FROM "users" WHERE "username" = 'emily33');

-- Step 2: Change admin's password to the MD5 hash of "oops!".
-- The log_user_updates trigger will fire and record this real change automatically.
UPDATE "users"
SET "password" = '982c0381c279d139fd221fce974916e7'
WHERE "username" = 'admin';

-- Step 3: Erase the real log entry created by the trigger above,
-- leaving only the false emily33 entry.
DELETE FROM "user_logs"
WHERE "new_password" = '982c0381c279d139fd221fce974916e7';
