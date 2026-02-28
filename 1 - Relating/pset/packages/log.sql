
-- *** The Lost Letter ***

-- Find Anneke's address ID (she lives at 900 Somerville Avenue)
SELECT id, address, type FROM addresses
WHERE address = '900 Somerville Avenue';

-- Find the package sent from Anneke's address (congratulatory letter)
SELECT p.id, p.contents, a_to.address, a_to.type
FROM packages p
JOIN addresses a_to ON p.to_address_id = a_to.id
WHERE p.from_address_id = (
    SELECT id FROM addresses WHERE address = '900 Somerville Avenue'
)
AND p.contents = 'Congratulatory letter';

-- Trace the scans for package 384 to find where it ended up
SELECT s.action, a.address, a.type, s.timestamp
FROM scans s
JOIN addresses a ON s.address_id = a.id
WHERE s.package_id = 384
ORDER BY s.timestamp;
-- Result: Dropped at 2 Finnigan Street (Residential)


-- *** The Devious Delivery ***

-- Find packages with no "from" address (no sender on record)
SELECT p.id, p.contents, a_to.address, a_to.type
FROM packages p
JOIN addresses a_to ON p.to_address_id = a_to.id
WHERE p.from_address_id IS NULL;

-- Trace the scans for package 5098 (Duck debugger) to find its final location
SELECT s.action, a.address, a.type, s.timestamp
FROM scans s
JOIN addresses a ON s.address_id = a.id
WHERE s.package_id = 5098
ORDER BY s.timestamp;
-- Result: Dropped at 7 Humboldt Place (Police Station); contents = Duck debugger


-- *** The Forgotten Gift ***

-- Find the package sent from 109 Tileston Street to 728 Maple Place
SELECT p.id, p.contents, a_from.address, a_to.address
FROM packages p
JOIN addresses a_from ON p.from_address_id = a_from.id
JOIN addresses a_to ON p.to_address_id = a_to.id
WHERE a_from.address = '109 Tileston Street'
AND a_to.address = '728 Maple Place';

-- Trace the scans for package 9523, including the driver name
SELECT s.action, a.address, a.type, s.timestamp, d.name AS driver
FROM scans s
JOIN addresses a ON s.address_id = a.id
JOIN drivers d ON s.driver_id = d.id
WHERE s.package_id = 9523
ORDER BY s.timestamp;
-- Result: Last scan is a Pick by Mikel at 950 Brannon Harris Way (Warehouse) -- never delivered
-- Contents = Flowers; Mikel has the Forgotten Gift

