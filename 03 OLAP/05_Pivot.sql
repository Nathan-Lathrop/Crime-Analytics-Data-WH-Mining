SELECT
    c.ucr_literal AS crime_type,

    COUNT(*) FILTER (
        WHERE d.year = 2019
    ) AS year_2019,

    COUNT(*) FILTER (
        WHERE d.year = 2020
    ) AS year_2020,

    COUNT(*) FILTER (
        WHERE d.year = 2021
    ) AS year_2021

FROM crime_dw.fact_crime f

JOIN crime_dw.dim_date d
    ON f.occur_date_key = d.date_key

JOIN crime_dw.dim_crime_type c
    ON f.crime_type_key = c.crime_type_key

WHERE d.year IN (2019, 2020, 2021)

GROUP BY c.ucr_literal

ORDER BY crime_type;