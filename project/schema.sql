-- ============================================================
-- Melodify — Music Streaming Platform Database Schema
-- CS50 SQL Final Project
-- ============================================================

-- -------------------------------------------------------
-- Table: genres
-- Stores music genre categories (e.g., Pop, Rock, Jazz).
-- Kept separate so albums can be re-categorised without
-- touching artist or track data.
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "genres" (
    "id"          INTEGER,
    "name"        TEXT    NOT NULL UNIQUE,
    "description" TEXT,
    PRIMARY KEY("id")
);

-- -------------------------------------------------------
-- Table: artists
-- An artist can be a solo performer or a band.
-- "country" stores the country of origin.
-- "formed_year" is NULL for solo acts where it isn't
-- meaningful to speak of "formation."
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "artists" (
    "id"          INTEGER,
    "name"        TEXT    NOT NULL,
    "country"     TEXT,
    "formed_year" INTEGER CHECK("formed_year" > 1800 OR "formed_year" IS NULL),
    "biography"   TEXT,
    PRIMARY KEY("id")
);

-- -------------------------------------------------------
-- Table: albums
-- Each album belongs to exactly one primary artist and
-- one genre.  release_date uses ISO-8601 (YYYY-MM-DD).
-- cover_url stores an external image URL.
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "albums" (
    "id"           INTEGER,
    "title"        TEXT    NOT NULL,
    "artist_id"    INTEGER NOT NULL,
    "genre_id"     INTEGER,
    "release_date" TEXT,   -- YYYY-MM-DD
    "cover_url"    TEXT,
    PRIMARY KEY("id"),
    FOREIGN KEY("artist_id") REFERENCES "artists"("id") ON DELETE CASCADE,
    FOREIGN KEY("genre_id")  REFERENCES "genres"("id")  ON DELETE SET NULL
);

-- -------------------------------------------------------
-- Table: tracks
-- A track belongs to one album and one credited artist.
-- "duration_seconds" stores length as an integer for
-- easy arithmetic (no text parsing required).
-- "track_number" preserves the order within an album.
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "tracks" (
    "id"               INTEGER,
    "title"            TEXT    NOT NULL,
    "album_id"         INTEGER NOT NULL,
    "artist_id"        INTEGER NOT NULL,
    "duration_seconds" INTEGER NOT NULL CHECK("duration_seconds" > 0),
    "track_number"     INTEGER NOT NULL CHECK("track_number" > 0),
    PRIMARY KEY("id"),
    FOREIGN KEY("album_id")  REFERENCES "albums"("id")  ON DELETE CASCADE,
    FOREIGN KEY("artist_id") REFERENCES "artists"("id") ON DELETE CASCADE
);

-- -------------------------------------------------------
-- Table: users
-- Platform users.  "subscription_type" is constrained to
-- three tiers: free, premium, family.
-- Passwords are intentionally out of scope.
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "users" (
    "id"                INTEGER,
    "username"          TEXT    NOT NULL UNIQUE,
    "email"             TEXT    NOT NULL UNIQUE,
    "date_joined"       TEXT    NOT NULL DEFAULT (DATE('now')),
    "subscription_type" TEXT    NOT NULL DEFAULT 'free'
                            CHECK("subscription_type" IN ('free', 'premium', 'family')),
    PRIMARY KEY("id")
);

-- -------------------------------------------------------
-- Table: playlists
-- A user can own many playlists.  "is_public" uses 0/1
-- (SQLite has no BOOLEAN type).  "created_at" defaults to
-- the current UTC timestamp.
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "playlists" (
    "id"         INTEGER,
    "name"       TEXT    NOT NULL,
    "user_id"    INTEGER NOT NULL,
    "created_at" TEXT    NOT NULL DEFAULT (DATETIME('now')),
    "is_public"  INTEGER NOT NULL DEFAULT 1 CHECK("is_public" IN (0, 1)),
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id") ON DELETE CASCADE
);

-- -------------------------------------------------------
-- Table: playlist_tracks
-- Junction table linking playlists to tracks.
-- "position" stores the display order inside a playlist.
-- A (playlist_id, track_id) pair must be unique so the
-- same track cannot appear twice in one playlist.
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "playlist_tracks" (
    "id"          INTEGER,
    "playlist_id" INTEGER NOT NULL,
    "track_id"    INTEGER NOT NULL,
    "added_at"    TEXT    NOT NULL DEFAULT (DATETIME('now')),
    "position"    INTEGER NOT NULL CHECK("position" > 0),
    PRIMARY KEY("id"),
    UNIQUE("playlist_id", "track_id"),
    FOREIGN KEY("playlist_id") REFERENCES "playlists"("id") ON DELETE CASCADE,
    FOREIGN KEY("track_id")    REFERENCES "tracks"("id")    ON DELETE CASCADE
);

-- -------------------------------------------------------
-- Table: play_history
-- Records every stream event.  "duration_played" lets us
-- distinguish a full play from a skip (< 30 s is a skip
-- by industry convention).
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "play_history" (
    "id"              INTEGER,
    "user_id"         INTEGER NOT NULL,
    "track_id"        INTEGER NOT NULL,
    "played_at"       TEXT    NOT NULL DEFAULT (DATETIME('now')),
    "duration_played" INTEGER NOT NULL DEFAULT 0 CHECK("duration_played" >= 0),
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id")  REFERENCES "users"("id")  ON DELETE CASCADE,
    FOREIGN KEY("track_id") REFERENCES "tracks"("id") ON DELETE CASCADE
);

-- -------------------------------------------------------
-- Table: user_follows_artist
-- Many-to-many: a user can follow many artists;
-- an artist can be followed by many users.
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "user_follows_artist" (
    "user_id"     INTEGER NOT NULL,
    "artist_id"   INTEGER NOT NULL,
    "followed_at" TEXT    NOT NULL DEFAULT (DATETIME('now')),
    PRIMARY KEY("user_id", "artist_id"),
    FOREIGN KEY("user_id")   REFERENCES "users"("id")   ON DELETE CASCADE,
    FOREIGN KEY("artist_id") REFERENCES "artists"("id") ON DELETE CASCADE
);

-- -------------------------------------------------------
-- Table: track_likes
-- Many-to-many: users can like many tracks.
-- A (user_id, track_id) pair is a natural primary key.
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS "track_likes" (
    "user_id"  INTEGER NOT NULL,
    "track_id" INTEGER NOT NULL,
    "liked_at" TEXT    NOT NULL DEFAULT (DATETIME('now')),
    PRIMARY KEY("user_id", "track_id"),
    FOREIGN KEY("user_id")  REFERENCES "users"("id")  ON DELETE CASCADE,
    FOREIGN KEY("track_id") REFERENCES "tracks"("id") ON DELETE CASCADE
);

-- ============================================================
-- INDEXES
-- Created on columns that appear frequently in WHERE, JOIN,
-- or ORDER BY clauses to speed up common queries.
-- ============================================================

-- Speed up lookups of albums by artist
CREATE INDEX IF NOT EXISTS "idx_albums_artist"    ON "albums"("artist_id");

-- Speed up lookups of tracks by album and by artist
CREATE INDEX IF NOT EXISTS "idx_tracks_album"     ON "tracks"("album_id");
CREATE INDEX IF NOT EXISTS "idx_tracks_artist"    ON "tracks"("artist_id");

-- Speed up play-history queries filtered by user or by track
CREATE INDEX IF NOT EXISTS "idx_history_user"     ON "play_history"("user_id");
CREATE INDEX IF NOT EXISTS "idx_history_track"    ON "play_history"("track_id");

-- Speed up playlist membership lookups
CREATE INDEX IF NOT EXISTS "idx_pt_playlist"      ON "playlist_tracks"("playlist_id");
CREATE INDEX IF NOT EXISTS "idx_pt_track"         ON "playlist_tracks"("track_id");

-- Speed up "who does this user follow?" queries
CREATE INDEX IF NOT EXISTS "idx_follows_user"     ON "user_follows_artist"("user_id");
CREATE INDEX IF NOT EXISTS "idx_follows_artist"   ON "user_follows_artist"("artist_id");

-- ============================================================
-- VIEWS
-- Pre-built queries that simplify common access patterns.
-- ============================================================

-- -------------------------------------------------------
-- View: track_details
-- Denormalised view joining tracks with their album and
-- artist names, genre, and a human-readable duration
-- (MM:SS format).  Saves callers from writing the JOIN
-- every time.
-- -------------------------------------------------------
CREATE VIEW IF NOT EXISTS "track_details" AS
    SELECT
        t."id"                                        AS "track_id",
        t."title"                                     AS "track_title",
        a."name"                                      AS "artist_name",
        al."title"                                    AS "album_title",
        g."name"                                      AS "genre",
        t."track_number",
        t."duration_seconds",
        -- Format as MM:SS
        PRINTF('%d:%02d',
               t."duration_seconds" / 60,
               t."duration_seconds" % 60)             AS "duration",
        al."release_date"
    FROM "tracks"  t
    JOIN "artists" a  ON a."id" = t."artist_id"
    JOIN "albums"  al ON al."id" = t."album_id"
    LEFT JOIN "genres" g ON g."id" = al."genre_id";

-- -------------------------------------------------------
-- View: top_tracks
-- Aggregates total play counts and total likes per track.
-- Useful for charts / recommendations.
-- -------------------------------------------------------
CREATE VIEW IF NOT EXISTS "top_tracks" AS
    SELECT
        t."id"                        AS "track_id",
        t."title"                     AS "track_title",
        a."name"                      AS "artist_name",
        COUNT(DISTINCT ph."id")       AS "play_count",
        COUNT(DISTINCT tl."user_id")  AS "like_count"
    FROM "tracks"  t
    JOIN "artists" a  ON a."id" = t."artist_id"
    LEFT JOIN "play_history" ph ON ph."track_id" = t."id"
    LEFT JOIN "track_likes"  tl ON tl."track_id" = t."id"
    GROUP BY t."id", t."title", a."name"
    ORDER BY "play_count" DESC;

-- -------------------------------------------------------
-- View: user_activity_summary
-- Per-user statistics: streams, liked tracks, playlists,
-- and artists followed.  Handy for user dashboards.
-- -------------------------------------------------------
CREATE VIEW IF NOT EXISTS "user_activity_summary" AS
    SELECT
        u."id"                            AS "user_id",
        u."username",
        u."subscription_type",
        COUNT(DISTINCT ph."id")           AS "total_streams",
        COUNT(DISTINCT tl."track_id")     AS "liked_tracks",
        COUNT(DISTINCT p."id")            AS "playlists_created",
        COUNT(DISTINCT ufa."artist_id")   AS "artists_followed"
    FROM "users" u
    LEFT JOIN "play_history"        ph  ON ph."user_id"  = u."id"
    LEFT JOIN "track_likes"         tl  ON tl."user_id"  = u."id"
    LEFT JOIN "playlists"           p   ON p."user_id"   = u."id"
    LEFT JOIN "user_follows_artist" ufa ON ufa."user_id" = u."id"
    GROUP BY u."id", u."username", u."subscription_type";
