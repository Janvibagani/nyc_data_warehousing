-- Seating type dimension for open restaurant seating applications

WITH seating_types AS (
   SELECT DISTINCT
       approved_for_sidewalk_seating AS seating_interest,

       CASE 
           WHEN LOWER(approved_for_sidewalk_seating) = 'yes' THEN TRUE
           ELSE FALSE
       END AS approved_for_sidewalk,

       CASE 
           WHEN LOWER(approved_for_roadway_seating) = 'yes' THEN TRUE
           ELSE FALSE
       END AS approved_for_roadway

   FROM {{ ref('stg_nyc_open_restaurant_apps') }}
   WHERE approved_for_sidewalk_seating IS NOT NULL
),

seating_dimension AS (
   SELECT
       {{ dbt_utils.generate_surrogate_key([
           'seating_interest',
           'approved_for_sidewalk',
           'approved_for_roadway'
       ]) }} AS seating_type_key,

       seating_interest,
       approved_for_sidewalk,
       approved_for_roadway

   FROM seating_types
)

SELECT * FROM seating_dimension