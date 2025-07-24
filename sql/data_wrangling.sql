USE airbnb;
GO

SELECT * FROM AirbnbStaging

-- check that there are no null id's
SELECT * FROM AirbnbStaging
WHERE id IS NULL

-- remove duplicate rows
DELETE T
FROM
(
SELECT *
, DupRank = ROW_NUMBER() OVER (
              PARTITION BY id
              ORDER BY (SELECT NULL)
            )
FROM AirbnbStaging
) AS T
WHERE DupRank > 1

-- use id as primary key
ALTER TABLE AirbnbStaging
ALTER COLUMN id int NOT NULL

ALTER TABLE AirbnbStaging
ADD CONSTRAINT PK_id PRIMARY KEY (id)

-- fill in values for listings without a name
UPDATE AirbnbStaging
SET [listing_name] = ''
WHERE [listing_name] IS NULL

-- change data type of listing_name
SELECT TOP 1 listing_name, len(listing_name) -- longest name is 251
FROM AirbnbStaging
ORDER BY len(listing_name) DESC

ALTER TABLE AirbnbStaging
ALTER COLUMN listing_name VARCHAR(255)

/* host_id is unique identifier for hosts, a host can have multiple listings,
check that there are no null host_id's */
SELECT * FROM AirbnbStaging
WHERE host_id IS NULL

-- change data type of host_id
ALTER TABLE AirbnbStaging
ALTER COLUMN host_id bigint NOT NULL

-- column values are either verified, unconfirmed, or NULL
SELECT DISTINCT host_identity_verified
FROM AirbnbStaging

-- update column to contain boolean values, with NULL being False
UPDATE AirbnbStaging
SET [host_identity_verified] = 0
WHERE [host_identity_verified] = 'unconfirmed' OR [host_identity_verified] IS NULL

UPDATE AirbnbStaging
SET [host_identity_verified] = 1
WHERE [host_identity_verified] = 'verified'

-- change data type of the column
ALTER TABLE AirbnbStaging
ALTER COLUMN host_identity_verified bit

-- replace NULL with empty strings for host_name, neighbourhood_group, and neighbourhood
-- 404 host_names, 29 neighbourhood_group, 16 neighbourhood values are NULL
UPDATE AirbnbStaging
SET [host_name] = ''
WHERE [host_name] IS NULL

UPDATE AirbnbStaging
SET [neighbourhood] = ''
WHERE [neighbourhood] IS NULL

UPDATE AirbnbStaging
SET [neighbourhood_group] = ''
WHERE [neighbourhood_group] IS NULL

-- 8 rows are missing latitude and longitude, these rows will be dropped as they are an extremely small proportion of the data
SELECT * FROM AirbnbStaging
WHERE latitude IS NULL OR longitude IS NULL

DELETE FROM AirbnbStaging
WHERE latitude IS NULL OR longitude IS NULL

-- data is for New York City, therefore country and country_code columns are not useful
ALTER TABLE AirbnbStaging
DROP COLUMN IF EXISTS country

ALTER TABLE AirbnbStaging
DROP COLUMN IF EXISTS country_code