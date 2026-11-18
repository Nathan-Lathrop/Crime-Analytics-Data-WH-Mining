SELECT
    d.year,
    l.neighborhood,
    c.ucr_literal AS crime_type,
    COUNT(*) AS crime_records

FROM crime_dw.fact_crime f

JOIN crime_dw.dim_date d
    ON f.occur_date_key = d.date_key

JOIN crime_dw.dim_location l
    ON f.location_key = l.location_key

JOIN crime_dw.dim_crime_type c
    ON f.crime_type_key = c.crime_type_key

WHERE d.year = 2020

  AND l.neighborhood IN ('Downtown', 'Midtown')

  AND c.ucr_literal IN (
      'LARCENY-NON VEHICLE',
      'AUTO THEFT'
  )

GROUP BY
    d.year,
    l.neighborhood,
    c.ucr_literal

ORDER BY
    l.neighborhood,
    crime_records DESC;