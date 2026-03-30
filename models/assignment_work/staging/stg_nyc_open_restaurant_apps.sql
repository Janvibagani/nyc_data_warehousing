>-
  -- Clean and standardize NYC Open Restaurant Applications data

  WITH source AS ( SELECT * FROM {{ source('raw',
  'source_nyc_open_restaurant_apps') }} ),

  cleaned AS (

  SELECT

  -- Keep all except ones we will clean * EXCEPT ( objectid, restaurant_name,
  borough, zip_code, time_of_submission ),

  -- Identifiers CAST(objectid AS STRING) AS application_id,

  -- Restaurant info CAST(restaurant_name AS STRING) AS restaurant_name,

  -- Date CAST(time_of_submission AS TIMESTAMP) AS time_of_submission,

  -- Borough standardization (same logic style as 311) CASE WHEN
  UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN 'Manhattan' WHEN
  UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx' WHEN
  UPPER(TRIM(borough)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn' WHEN
  UPPER(TRIM(borough)) IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY') THEN 'Queens'
  WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten
  Island' ELSE 'UNKNOWN' END AS borough,

  -- ZIP cleaning (simpler version than 311) CASE WHEN zip_code IS NULL THEN
  NULL WHEN LENGTH(CAST(zip_code AS STRING)) = 5 THEN CAST(zip_code AS STRING)
  WHEN LENGTH(CAST(zip_code AS STRING)) = 10 AND REGEXP_CONTAINS(CAST(zip_code
  AS STRING), r'^\d{5}-\d{4}') THEN CAST(zip_code AS STRING) ELSE NULL END AS
  zip_code,

  -- Metadata CURRENT_TIMESTAMP() AS _stg_loaded_at

  FROM source

  -- Light filtering (LESS than 311, as professor said) WHERE objectid IS NOT
  NULL AND time_of_submission IS NOT NULL

  -- Deduplication (optional but recommended) QUALIFY ROW_NUMBER() OVER (
  PARTITION BY objectid ORDER BY time_of_submission DESC ) = 1

  )

  SELECT * FROM cleaned
