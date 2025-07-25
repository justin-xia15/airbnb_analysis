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

-- change data types
ALTER TABLE AirbnbStaging
ALTER COLUMN price MONEY

ALTER TABLE AirbnbStaging
ALTER COLUMN service_fee MONEY

-- fill in missing prices with average price of 625
SELECT AVG(price) FROM AirbnbStaging

UPDATE AirbnbStaging
SET [price] = 625.00
WHERE [price] IS NULL

-- fill in missing service fees with average
SELECT AVG((service_fee/price)*100) FROM AirbnbStaging -- average service fee is 19.9935% of price

UPDATE AirbnbStaging
SET [service_fee] = ROUND(price*0.199935, 0)
WHERE [service_fee] IS NULL

-- min_nights
ALTER TABLE AirbnbStaging
ALTER COLUMN min_nights INT

-- replace negative values and NULL with 1, meaning there is no minimum stay requirement 
SELECT DISTINCT min_nights FROM AirbnbStaging

UPDATE AirbnbStaging
SET [min_nights] = 1
WHERE [min_nights] < 0 OR [min_nights] IS NULL

-- num_reviews
ALTER TABLE AirbnbStaging
ALTER COLUMN num_reviews INT

-- replace NULL values with 0
SELECT DISTINCT num_reviews FROM AirbnbStaging

UPDATE AirbnbStaging
SET [num_reviews] = 0
WHERE [num_reviews] IS NULL

-- last_review date
SELECT * FROM AirbnbStaging WHERE last_review IS NULL -- 15831 rows without last review date

-- 15796 of those rows have no reviews and should have last_review date left blank
SELECT * FROM AirbnbStaging WHERE last_review IS NULL
AND num_reviews = 0

-- 35 of those rows have reviews and reviews_per_month but no last_review date
SELECT * FROM AirbnbStaging WHERE last_review IS NULL
AND num_reviews != 0

-- since only 35 rows are missing this date, and it's not as useful for analysis as num_reviews or reviews_per_month, it will also be left blank
ALTER TABLE AirbnbStaging
ALTER COLUMN last_review DATE

-- convert reviews_per_month to numeric values
ALTER TABLE AirbnbStaging
ALTER COLUMN reviews_per_month FLOAT

-- 15817 rows with no value for reviews_per_month
SELECT * FROM AirbnbStaging WHERE reviews_per_month <= 0 OR reviews_per_month IS NULL

-- 15795 of these rows have no reviews, so reviews per month should be 0
-- the remaining 22 rows will have reviews_per_month set to -1 to indicate this value is unknown
-- cannot calculate this as the amount of time the listing has been posted is not provided
SELECT * FROM AirbnbStaging 
WHERE (reviews_per_month <= 0 OR reviews_per_month IS NULL)
AND num_reviews = 0

UPDATE AirbnbStaging
SET [reviews_per_month] = 0
WHERE ([reviews_per_month] <= 0 OR [reviews_per_month] IS NULL)
AND num_reviews = 0

UPDATE AirbnbStaging
SET [reviews_per_month] = -1
WHERE ([reviews_per_month] <= 0 OR [reviews_per_month] IS NULL)
AND num_reviews > 0

-- review scores are the average rating of a listing on a scale of 1-5
-- if a listing has reviews but no review_score, this will be filled in with the average
-- if there are no reviews the score will be kept as NULL instead of being replaced with 0 to not affect the average score
SELECT DISTINCT review_score FROM AirbnbStaging

-- convert to numeric values
ALTER TABLE AirbnbStaging
ALTER COLUMN review_score INT

SELECT AVG(review_score) FROM AirbnbStaging -- avg of 3

UPDATE AirbnbStaging
SET [review_score] = 3
WHERE [review_score] IS NULL
AND [num_reviews] > 0

