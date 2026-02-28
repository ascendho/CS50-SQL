-- ============================================================
-- Melodify — Typical SQL Queries
-- CS50 SQL Final Project
-- ============================================================

-- ============================================================
-- INSERT statements  (seed / populate data)
-- ============================================================

-- Add a new genre
INSERT INTO "genres" ("name", "description")
VALUES ('Pop', 'Popular music characterised by catchy melodies and broad commercial appeal');

INSERT INTO "genres" ("name", "description")
VALUES ('Rock', 'Guitar-driven music evolving from 1950s rock and roll');

INSERT INTO "genres" ("name", "description")
VALUES ('Jazz', 'Improvisation-heavy genre originating in early 20th-century New Orleans');

INSERT INTO "genres" ("name", "description")
VALUES ('Hip-Hop', 'Urban genre built around rhythmic speech, sampling, and DJing');

INSERT INTO "genres" ("name", "description")
VALUES ('Electronic', 'Music produced primarily with electronic instruments and technology');

-- Add a new artist
INSERT INTO "artists" ("name", "country", "formed_year", "biography")
VALUES (
    'The Midnight',
    'United States',
    2012,
    'Synthwave duo Tyler Lyle and Tim McEwan blending 80s nostalgia with modern pop production.'
);

INSERT INTO "artists" ("name", "country", "formed_year", "biography")
VALUES (
    'Daft Punk',
    'France',
    1993,
    'Legendary French electronic duo known for pioneering house and electro music worldwide.'
);

INSERT INTO "artists" ("name", "country", "biography")
VALUES (
    'Billie Eilish',
    'United States',
    'Grammy-winning pop artist known for her dark, introspective songwriting and whisper-pop aesthetic.'
);

-- Add a new album (The Midnight – Monsters, 2022)
INSERT INTO "albums" ("title", "artist_id", "genre_id", "release_date")
VALUES (
    'Heroes',
    (SELECT "id" FROM "artists" WHERE "name" = 'The Midnight'),
    (SELECT "id" FROM "genres"  WHERE "name" = 'Electronic'),
    '2022-06-24'
);

-- Add tracks to an album
INSERT INTO "tracks" ("title", "album_id", "artist_id", "duration_seconds", "track_number")
VALUES (
    'Change Your Heart',
    (SELECT "id" FROM "albums"  WHERE "title" = 'Heroes'),
    (SELECT "id" FROM "artists" WHERE "name"  = 'The Midnight'),
    212,
    1
);

INSERT INTO "tracks" ("title", "album_id", "artist_id", "duration_seconds", "track_number")
VALUES (
    'Heroes',
    (SELECT "id" FROM "albums"  WHERE "title" = 'Heroes'),
    (SELECT "id" FROM "artists" WHERE "name"  = 'The Midnight'),
    246,
    2
);

-- Register a new user
INSERT INTO "users" ("username", "email", "subscription_type")
VALUES ('ascendho', 'ascendho@example.com', 'premium');

INSERT INTO "users" ("username", "email", "subscription_type")
VALUES ('jdoe', 'jdoe@example.com', 'free');

-- Create a playlist for a user
INSERT INTO "playlists" ("name", "user_id", "is_public")
VALUES (
    'Late Night Drives',
    (SELECT "id" FROM "users" WHERE "username" = 'ascendho'),
    1
);

-- Add a track to a playlist
INSERT INTO "playlist_tracks" ("playlist_id", "track_id", "position")
VALUES (
    (SELECT "id" FROM "playlists" WHERE "name" = 'Late Night Drives'),
    (SELECT "id" FROM "tracks"    WHERE "title" = 'Change Your Heart'),
    1
);

-- Record a stream event
INSERT INTO "play_history" ("user_id", "track_id", "duration_played")
VALUES (
    (SELECT "id" FROM "users"  WHERE "username" = 'ascendho'),
    (SELECT "id" FROM "tracks" WHERE "title"    = 'Heroes'),
    246   -- full play
);

-- User follows an artist
INSERT INTO "user_follows_artist" ("user_id", "artist_id")
VALUES (
    (SELECT "id" FROM "users"   WHERE "username" = 'ascendho'),
    (SELECT "id" FROM "artists" WHERE "name"     = 'The Midnight')
);

-- User likes a track
INSERT INTO "track_likes" ("user_id", "track_id")
VALUES (
    (SELECT "id" FROM "users"  WHERE "username" = 'ascendho'),
    (SELECT "id" FROM "tracks" WHERE "title"    = 'Change Your Heart')
);


-- ============================================================
-- SELECT statements  (read / analyse data)
-- ============================================================

-- 1. Look up all tracks in a specific album, ordered by track number.
--    Uses the track_details view for convenience.
SELECT "track_number", "track_title", "duration"
FROM   "track_details"
WHERE  "album_title" = 'Heroes'
ORDER BY "track_number";

-- 2. Search for tracks or artists whose name contains a keyword (case-insensitive).
SELECT "track_title", "artist_name", "album_title", "duration"
FROM   "track_details"
WHERE  "track_title" LIKE '%heart%'
   OR  "artist_name" LIKE '%heart%';

-- 3. Get the global top-10 most-played tracks.
SELECT "track_title", "artist_name", "play_count", "like_count"
FROM   "top_tracks"
LIMIT  10;

-- 4. Get a personalised activity summary for a specific user.
SELECT *
FROM   "user_activity_summary"
WHERE  "username" = 'ascendho';

-- 5. List all public playlists along with their track count.
SELECT
    p."name"                  AS "playlist",
    u."username"              AS "owner",
    COUNT(pt."track_id")      AS "track_count",
    p."created_at"
FROM  "playlists"       p
JOIN  "users"           u  ON u."id" = p."user_id"
LEFT JOIN "playlist_tracks" pt ON pt."playlist_id" = p."id"
WHERE p."is_public" = 1
GROUP BY p."id"
ORDER BY "track_count" DESC;

-- 6. Retrieve the listening history of a user (latest 20 streams).
SELECT
    t."title"            AS "track",
    a."name"             AS "artist",
    ph."played_at",
    ph."duration_played"
FROM  "play_history" ph
JOIN  "tracks"       t  ON t."id" = ph."track_id"
JOIN  "artists"      a  ON a."id" = t."artist_id"
WHERE ph."user_id" = (SELECT "id" FROM "users" WHERE "username" = 'ascendho')
ORDER BY ph."played_at" DESC
LIMIT 20;

-- 7. Find the artists followed by a specific user.
SELECT
    ar."name"                 AS "artist",
    ar."country",
    ufa."followed_at"
FROM  "user_follows_artist"  ufa
JOIN  "artists"              ar  ON ar."id" = ufa."artist_id"
WHERE ufa."user_id" = (SELECT "id" FROM "users" WHERE "username" = 'ascendho')
ORDER BY ufa."followed_at" DESC;

-- 8. Get an artist's discography (albums + track count per album).
SELECT
    al."title"            AS "album",
    al."release_date",
    g."name"              AS "genre",
    COUNT(t."id")         AS "tracks"
FROM  "albums"   al
JOIN  "artists"  ar ON ar."id" = al."artist_id"
LEFT JOIN "genres"  g  ON g."id"  = al."genre_id"
LEFT JOIN "tracks"  t  ON t."id"  IN (
    SELECT "id" FROM "tracks" WHERE "album_id" = al."id"
)
WHERE ar."name" = 'The Midnight'
GROUP BY al."id"
ORDER BY al."release_date" DESC;

-- 9. Count users per subscription tier.
SELECT
    "subscription_type",
    COUNT(*)  AS "user_count"
FROM  "users"
GROUP BY "subscription_type"
ORDER BY "user_count" DESC;

-- 10. Find tracks that have been skipped (played < 30 seconds) most often.
SELECT
    t."title"             AS "track",
    a."name"              AS "artist",
    COUNT(*)              AS "skip_count"
FROM  "play_history" ph
JOIN  "tracks"       t  ON t."id" = ph."track_id"
JOIN  "artists"      a  ON a."id" = t."artist_id"
WHERE ph."duration_played" < 30
GROUP BY t."id"
ORDER BY "skip_count" DESC
LIMIT 10;

-- 11. Get tracks liked by a user that the user has never streamed.
SELECT
    t."title"   AS "liked_but_unplayed",
    a."name"    AS "artist"
FROM  "track_likes"  tl
JOIN  "tracks"       t  ON t."id" = tl."track_id"
JOIN  "artists"      a  ON a."id" = t."artist_id"
WHERE tl."user_id" = (SELECT "id" FROM "users" WHERE "username" = 'ascendho')
  AND t."id" NOT IN (
      SELECT "track_id"
      FROM   "play_history"
      WHERE  "user_id" = (SELECT "id" FROM "users" WHERE "username" = 'ascendho')
  );

-- 12. Most-followed artists across the platform.
SELECT
    a."name"         AS "artist",
    a."country",
    COUNT(*)         AS "follower_count"
FROM  "user_follows_artist" ufa
JOIN  "artists"             a  ON a."id" = ufa."artist_id"
GROUP BY a."id"
ORDER BY "follower_count" DESC
LIMIT 10;

-- 13. Recommend tracks to a user based on genres of artists they follow
--     (tracks they have not already played).
SELECT DISTINCT
    td."track_title",
    td."artist_name",
    td."genre",
    td."album_title"
FROM  "track_details" td
WHERE td."genre" IN (
    SELECT DISTINCT g."name"
    FROM   "user_follows_artist" ufa
    JOIN   "artists"             a   ON a."id"  = ufa."artist_id"
    JOIN   "albums"              al  ON al."artist_id" = a."id"
    JOIN   "genres"              g   ON g."id"  = al."genre_id"
    WHERE  ufa."user_id" = (SELECT "id" FROM "users" WHERE "username" = 'ascendho')
)
AND td."track_id" NOT IN (
    SELECT "track_id"
    FROM   "play_history"
    WHERE  "user_id" = (SELECT "id" FROM "users" WHERE "username" = 'ascendho')
)
ORDER BY td."artist_name", td."album_title", td."track_number"
LIMIT 20;


-- ============================================================
-- UPDATE statements  (modify existing data)
-- ============================================================

-- Upgrade a user's subscription from free to premium.
UPDATE "users"
SET    "subscription_type" = 'premium'
WHERE  "username" = 'jdoe';

-- Rename a playlist.
UPDATE "playlists"
SET    "name" = 'Midnight Drives'
WHERE  "name" = 'Late Night Drives'
  AND  "user_id" = (SELECT "id" FROM "users" WHERE "username" = 'ascendho');

-- Make a private playlist public.
UPDATE "playlists"
SET    "is_public" = 1
WHERE  "id" = 1;

-- Reorder a track within a playlist (move it to position 3).
UPDATE "playlist_tracks"
SET    "position" = 3
WHERE  "playlist_id" = (SELECT "id" FROM "playlists" WHERE "name" = 'Midnight Drives')
  AND  "track_id"    = (SELECT "id" FROM "tracks"    WHERE "title" = 'Change Your Heart');

-- Correct a track's duration.
UPDATE "tracks"
SET    "duration_seconds" = 215
WHERE  "title" = 'Change Your Heart';


-- ============================================================
-- DELETE statements  (remove data)
-- ============================================================

-- Remove a track from a playlist (without deleting the track itself).
DELETE FROM "playlist_tracks"
WHERE "playlist_id" = (SELECT "id" FROM "playlists" WHERE "name" = 'Midnight Drives')
  AND "track_id"    = (SELECT "id" FROM "tracks"    WHERE "title" = 'Change Your Heart');

-- Unfollow an artist.
DELETE FROM "user_follows_artist"
WHERE "user_id"   = (SELECT "id" FROM "users"   WHERE "username" = 'ascendho')
  AND "artist_id" = (SELECT "id" FROM "artists" WHERE "name"     = 'Daft Punk');

-- Unlike a track.
DELETE FROM "track_likes"
WHERE "user_id"  = (SELECT "id" FROM "users"  WHERE "username" = 'ascendho')
  AND "track_id" = (SELECT "id" FROM "tracks" WHERE "title"    = 'Change Your Heart');

-- Delete a user account (cascades to playlists, history, likes, follows).
DELETE FROM "users"
WHERE "username" = 'jdoe';

-- Delete an artist and all associated albums / tracks via CASCADE.
DELETE FROM "artists"
WHERE "name" = 'Daft Punk';
