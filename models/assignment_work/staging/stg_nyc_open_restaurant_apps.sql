>-
  -- Clean and standardize NYC Open Restaurant Applications data

  WITH source AS (

  SELECT * FROM {{ source('raw_restaurants', 'source_nyc_open_restaurant_apps')
  }}

  ),

  cleaned AS (

  SELECT

  -- identifiers CAST(objectid AS STRING) AS application_id, CAST(globalid AS
  STRING) AS global_id,

  -- timestamps CAST(time_of_submission AS TIMESTAMP) AS time_of_submission,

  -- restaurant info CAST(restaurant_name AS STRING) AS restaurant_name,
  CAST(legal_business_name AS STRING) AS legal_business_name,
  CAST(doing_business_as_dba AS STRING) AS doing_business_as_dba,

  -- location CASE WHEN LENGTH(zip) = 5 THEN zip WHEN LENGTH(zip) > 5 THEN
  SUBSTR(zip, 1, 5) ELSE NULL END AS zip,

  CASE WHEN UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN
  'Manhattan' WHEN UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
  WHEN UPPER(TRIM(borough)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn' WHEN
  UPPER(TRIM(borough)) IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY') THEN 'Queens'
  WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten
  Island' ELSE 'UNKNOWN' END AS borough,

  CAST(street AS STRING) AS street, CAST(bulding_number AS STRING) AS
  bulding_number, CAST(business_address AS STRING) AS business_address,

  CAST(latitude AS FLOAT64) AS latitude, CAST(longitude AS FLOAT64) AS
  longitude,

  -- approvals CAST(approved_for_sidewalk_seating AS STRING) AS
  approved_for_sidewalk_seating, CAST(approved_for_roadway_seating AS STRING) AS
  approved_for_roadway_seating,

  -- other attributes CAST(community_board AS STRING) AS community_board,
  CAST(council_district AS STRING) AS council_district, CAST(census_tract AS
  STRING) AS census_tract,

  CAST(food_service_establishment AS STRING) AS food_service_establishment,
  CAST(healthcompliance_terms AS STRING) AS healthcompliance_terms,

  CAST(nta AS STRING) AS nta, CAST(qualify_alcohol AS STRING) AS
  qualify_alcohol,

  -- metadata CURRENT_TIMESTAMP() AS _stg_loaded_at

  FROM source

  WHERE objectid IS NOT NULL

  ),

  deduplicated AS (

  SELECT * FROM cleaned QUALIFY ROW_NUMBER() OVER ( PARTITION BY application_id
  ORDER BY time_of_submission DESC ) = 1

  )

  SELECT * FROM deduplicated
