-- Restaurant dimension for open restaurant applications

WITH restaurant_data AS (
   SELECT DISTINCT
       restaurant_name,
       legal_business_name,
       doing_business_as_dba,
       business_address,
       borough,
       zip
   FROM {{ ref('stg_nyc_open_restaurant_apps') }}
   WHERE restaurant_name IS NOT NULL
),

restaurant_dimension AS (
   SELECT
       {{ dbt_utils.generate_surrogate_key([
           'restaurant_name',
           'legal_business_name',
           'doing_business_as_dba',
           'business_address',
           'borough',
           'zip'
       ]) }} AS restaurant_key,

       restaurant_name,
       legal_business_name,
       doing_business_as_dba,
       business_address,
       borough,
       zip

   FROM restaurant_data
)

SELECT * FROM restaurant_dimension