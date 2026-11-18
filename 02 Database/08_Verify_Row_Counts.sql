SELECT 'Staging' AS table_name,
       COUNT(*) AS total_rows
FROM crime_dw.staging_crime

UNION ALL

SELECT 'Date Dimension',
       COUNT(*)
FROM crime_dw.dim_date

UNION ALL

SELECT 'Time Dimension',
       COUNT(*)
FROM crime_dw.dim_time

UNION ALL

SELECT 'Location Dimension',
       COUNT(*)
FROM crime_dw.dim_location

UNION ALL

SELECT 'Crime Type Dimension',
       COUNT(*)
FROM crime_dw.dim_crime_type

UNION ALL

SELECT 'Fact Table',
       COUNT(*)
FROM crime_dw.fact_crime;