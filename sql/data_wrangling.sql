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
ALTER COLUMN id INT NOT NULL

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
ALTER COLUMN host_id BIGINT NOT NULL

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
ALTER COLUMN host_identity_verified BIT

-- replace NULL with empty strings for host_name, neighbourhood_group, and neighbourhood
-- 404 host_names, 29 neighbourhood_group (with neighbourhood values), 16 neighbourhood values are NULL
SELECT * FROM AirbnbStaging
WHERE neighbourhood_group IS NULL

-- fix neighbourhood_group for rows with typos
SELECT DISTINCT neighbourhood_group FROM AirbnbStaging

UPDATE AirbnbStaging
SET [neighbourhood_group] = 'Brooklyn'
WHERE [neighbourhood_group] = 'brookln'

UPDATE AirbnbStaging
SET [neighbourhood_group] = 'Manhattan'
WHERE [neighbourhood_group] = 'manhatan'

-- fill in missing neighbourhood_group values by checking if the neighbourhood is in one of the 5 neighbourhood groups
UPDATE AirbnbStaging
SET [neighbourhood_group] = 'Bronx'
WHERE [neighbourhood_group] IS NULL 
AND [neighbourhood] IN (
  SELECT DISTINCT neighbourhood FROM AirbnbStaging
  WHERE neighbourhood_group = 'Bronx'
)

UPDATE AirbnbStaging
SET [neighbourhood_group] = 'Brooklyn'
WHERE [neighbourhood_group] IS NULL 
AND [neighbourhood] IN (
  SELECT DISTINCT neighbourhood FROM AirbnbStaging
  WHERE neighbourhood_group = 'Brooklyn'
)

UPDATE AirbnbStaging
SET [neighbourhood_group] = 'Manhattan'
WHERE [neighbourhood_group] IS NULL 
AND [neighbourhood] IN (
  SELECT DISTINCT neighbourhood FROM AirbnbStaging
  WHERE neighbourhood_group = 'Manhattan'
)

UPDATE AirbnbStaging
SET [neighbourhood_group] = 'Queens'
WHERE [neighbourhood_group] IS NULL 
AND [neighbourhood] IN (
  SELECT DISTINCT neighbourhood FROM AirbnbStaging
  WHERE neighbourhood_group = 'Queens'
)

UPDATE AirbnbStaging
SET [neighbourhood_group] = 'Staten Island'
WHERE [neighbourhood_group] IS NULL 
AND [neighbourhood] IN (
  SELECT DISTINCT neighbourhood FROM AirbnbStaging
  WHERE neighbourhood_group = 'Staten Island'
)

-- replace NULL values with empty string for host_name and neighbourhood
UPDATE AirbnbStaging
SET [host_name] = ''
WHERE [host_name] IS NULL

UPDATE AirbnbStaging
SET [neighbourhood] = ''
WHERE [neighbourhood] IS NULL

-- data types for host_name, neighbourhood_group, neighbourhood
ALTER TABLE AirbnbStaging
ALTER COLUMN host_name VARCHAR(55)

ALTER TABLE AirbnbStaging
ALTER COLUMN neighbourhood_group VARCHAR(55)

ALTER TABLE AirbnbStaging
ALTER COLUMN neighbourhood_group VARCHAR(55)

-- 8 rows are missing latitude and longitude, these rows will be dropped as they are an extremely small proportion of the data
SELECT * FROM AirbnbStaging
WHERE latitude IS NULL OR longitude IS NULL

DELETE FROM AirbnbStaging
WHERE latitude IS NULL OR longitude IS NULL

-- change data type for lat/long
ALTER TABLE AirbnbStaging
ALTER COLUMN latitude DECIMAL(8,6)

ALTER TABLE AirbnbStaging
ALTER COLUMN longitude DECIMAL(8,6)

-- data is for New York City, therefore country and country_code columns are not useful
ALTER TABLE AirbnbStaging
DROP COLUMN IF EXISTS country

ALTER TABLE AirbnbStaging
DROP COLUMN IF EXISTS country_code

-- map TRUE/FALSE values to 1s and 0s, with NULL being FALSE
UPDATE AirbnbStaging
SET [instant_bookable] = 0
WHERE [instant_bookable] = 'FALSE' OR [instant_bookable] IS NULL

UPDATE AirbnbStaging
SET [instant_bookable] = 1
WHERE [instant_bookable] = 'TRUE'

ALTER TABLE AirbnbStaging
ALTER COLUMN instant_bookable BIT

-- 76 rows where cancellation_policy is NULL, fill in NULLs with unknown
SELECT DISTINCT cancellation_policy FROM AirbnbStaging

UPDATE AirbnbStaging
SET [cancellation_policy] = 'unknown'
WHERE [cancellation_policy] IS NULL

ALTER TABLE AirbnbStaging
ALTER COLUMN cancellation_policy VARCHAR(16)

-- no room_type missing values
SELECT DISTINCT room_type FROM AirbnbStaging

ALTER TABLE AirbnbStaging
ALTER COLUMN room_type VARCHAR(16)

-- 213 rows with construction_year missing
SELECT DISTINCT construction_year FROM AirbnbStaging
SELECT * FROM AirbnbStaging WHERE construction_year IS NULL

-- change data type
ALTER TABLE AirbnbStaging
ALTER COLUMN construction_year INT

-- fill in missing year values using the average construction year
SELECT AVG(construction_year) FROM AirbnbStaging

UPDATE AirbnbStaging
SET [construction_year] = 2012
WHERE [construction_year] IS NULL

-- 247 rows where price is NULL, and 273 rows where service_fee is NULL
SELECT DISTINCT price FROM AirbnbStaging
SELECT DISTINCT service_fee FROM AirbnbStaging
SELECT * FROM AirbnbStaging WHERE price IS NULL
SELECT * FROM AirbnbStaging WHERE service_fee IS NULL

-- TODO
-- fill in missing values with average prices