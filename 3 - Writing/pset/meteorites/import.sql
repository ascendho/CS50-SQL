-- Drop tables from any previous run
DROP TABLE IF EXISTS "meteorites_temp";
DROP TABLE IF EXISTS "meteorites";

-- Step 1: Create a temporary staging table (all TEXT to safely hold raw CSV data)
CREATE TABLE "meteorites_temp" (
    "name"      TEXT,
    "id"        TEXT,
    "nametype"  TEXT,
    "class"     TEXT,
    "mass"      TEXT,
    "discovery" TEXT,
    "year"      TEXT,
    "lat"       TEXT,
    "long"      TEXT
);

-- Step 2: Import CSV into the temporary table (skip the header row)
.import --csv --skip 1 meteorites.csv meteorites_temp

-- Step 3: Clean empty strings → NULL for columns that may be empty
UPDATE "meteorites_temp" SET "mass"  = NULL WHERE TRIM("mass")  = '';
UPDATE "meteorites_temp" SET "year"  = NULL WHERE TRIM("year")  = '';
UPDATE "meteorites_temp" SET "lat"   = NULL WHERE TRIM("lat")   = '';
UPDATE "meteorites_temp" SET "long"  = NULL WHERE TRIM("long")  = '';

-- Step 4: Create the final meteorites table with proper types
CREATE TABLE "meteorites" (
    "id"        INTEGER,
    "name"      TEXT    NOT NULL,
    "class"     TEXT    NOT NULL,
    "mass"      REAL,
    "discovery" TEXT,
    "year"      INTEGER,
    "lat"       REAL,
    "long"      REAL,
    PRIMARY KEY("id")
);

-- Step 5: Insert cleaned data into the final table.
--   • Exclude "Relict" nametypes
--   • Round mass, lat, long to 2 decimal places
--   • Cast year to INTEGER (CSV stores it as e.g. "1880.0")
--   • Sort by year (oldest first, NULLs last), then name alphabetically
--   • id is auto-assigned by SQLite (1, 2, 3, …) in insertion order
INSERT INTO "meteorites" ("name", "class", "mass", "discovery", "year", "lat", "long")
SELECT
    "name",
    "class",
    ROUND(CAST("mass" AS REAL), 2),
    "discovery",
    CAST("year" AS INTEGER),
    ROUND(CAST("lat"  AS REAL), 2),
    ROUND(CAST("long" AS REAL), 2)
FROM "meteorites_temp"
WHERE "nametype" != 'Relict'
ORDER BY
    CAST("year" AS INTEGER) ASC,
    "name" ASC;

-- Step 6: Drop the temporary staging table
DROP TABLE "meteorites_temp";
