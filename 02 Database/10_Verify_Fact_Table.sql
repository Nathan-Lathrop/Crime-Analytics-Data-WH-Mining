SELECT
    c.ucr_literal,
    COUNT(*) AS crime_records,
    COUNT(DISTINCT f.report_number) AS unique_reports
FROM crime_dw.fact_crime f
JOIN crime_dw.dim_crime_type c
    ON f.crime_type_key = c.crime_type_key
GROUP BY c.ucr_literal
ORDER BY crime_records DESC;