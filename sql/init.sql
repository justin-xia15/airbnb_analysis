USE airbnb;
GO

DROP TABLE IF EXISTS AirbnbStaging

CREATE TABLE [dbo].AirbnbStaging (
    id VARCHAR(MAX),
    listing_name VARCHAR(MAX),
    host_id VARCHAR(MAX),
    host_identity_verified VARCHAR(MAX),
    host_name VARCHAR(MAX),
    neighbourhood_group VARCHAR(MAX),
    neighbourhood VARCHAR(MAX),
    latitude VARCHAR(MAX),
    longitude VARCHAR(MAX),
    country VARCHAR(MAX),
    country_code VARCHAR(MAX),
    instant_bookable VARCHAR(MAX),
    cancellation_policy VARCHAR(MAX),
    room_type VARCHAR(MAX),
    construction_year VARCHAR(MAX),
    price VARCHAR(MAX),
    service_fee VARCHAR(MAX),
    min_nights VARCHAR(MAX),
    num_reviews VARCHAR(MAX),
    last_review VARCHAR(MAX),
    reviews_per_month VARCHAR(MAX),
    review_score VARCHAR(MAX),
    calculated_host_listings_count VARCHAR(MAX),
    availability_365 VARCHAR(MAX),
    house_rules VARCHAR(MAX),
    license VARCHAR(MAX)
);


BULK INSERT AirbnbStaging
FROM 'path_to_csv_file'
WITH (
    FIRSTROW = 2,               
    FIELDTERMINATOR = ',',      
    ROWTERMINATOR = '\n',        
    TABLOCK,
    CODEPAGE = '65001'
);

