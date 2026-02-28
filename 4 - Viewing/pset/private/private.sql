-- Create table to store the cipher triplets from the detective's note
CREATE TABLE IF NOT EXISTS "triplets" (
    "sentence_id" INTEGER,
    "start_char"  INTEGER,
    "length"      INTEGER
);

-- Insert the 8 triplets inscribed on the paper
INSERT INTO "triplets" ("sentence_id", "start_char", "length") VALUES
    (14,   98,  4),
    (114,   3,  5),
    (618,  72,  9),
    (630,   7,  3),
    (932,  12,  5),
    (2230, 50,  7),
    (2346, 44, 10),
    (3041, 14,  5);

-- Create the message view by decoding each triplet via substr
CREATE VIEW "message" AS
SELECT substr("sentences"."sentence", "triplets"."start_char", "triplets"."length") AS "phrase"
FROM "triplets"
JOIN "sentences" ON "sentences"."id" = "triplets"."sentence_id";
