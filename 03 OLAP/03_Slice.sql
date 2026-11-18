SELECT
    c.ucr_literal AS crime_type,
    COUNT(*) AS crime_records,
    COUNT(DISTINCT f.report_number) AS unique_reports

FROM crime_dw.fact_crime f

JOIN crime_dw.dim_date d
    ON f.occur_date_key = d.date_key

JOIN crime_dw.dim_crime_type c
    ON f.crime_type_key = c.crime_type_key

WHERE d.year = 2020

GROUP BY c.ucr_literal

ORDER BY crime_records DESC;