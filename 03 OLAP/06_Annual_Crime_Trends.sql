SELECT
    d.year,
    COUNT(*) AS crime_records,
    COUNT(DISTINCT f.report_number) AS unique_reports
FROM crime_dw.fact_crime f
JOIN crime_dw.dim_date d
    ON f.occur_date_key = d.date_key
WHERE d.year BETWEEN 2009 AND 2021
GROUP BY d.year
ORDER BY d.year;