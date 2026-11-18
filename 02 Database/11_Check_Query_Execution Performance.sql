EXPLAIN ANALYZE
SELECT
    d.year,
    COUNT(*) AS crime_records
FROM crime_dw.fact_crime f
JOIN crime_dw.dim_date d
    ON f.occur_date_key = d.date_key
GROUP BY d.year
ORDER BY d.year;