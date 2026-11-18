SELECT
    l.neighborhood,
    COUNT(*) FILTER (
        WHERE c.ucr_literal = 'LARCENY-NON VEHICLE'
    ) AS larceny_non_vehicle,

    COUNT(*) FILTER (
        WHERE c.ucr_literal = 'AUTO THEFT'
    ) AS auto_theft

FROM crime_dw.fact_crime f

JOIN crime_dw.dim_date d
    ON f.occur_date_key = d.date_key

JOIN crime_dw.dim_location l
    ON f.location_key = l.location_key

JOIN crime_dw.dim_crime_type c
    ON f.crime_type_key = c.crime_type_key

WHERE d.year = 2020
  AND l.neighborhood IN ('Downtown', 'Midtown')

GROUP BY l.neighborhood

ORDER BY l.neighborhood;