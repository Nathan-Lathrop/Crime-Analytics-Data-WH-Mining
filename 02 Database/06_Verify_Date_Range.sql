SELECT
    MIN(d.full_date) AS earliest_occurrence_date,
    MAX(d.full_date) AS latest_occurrence_date,
    COUNT(*) AS records_with_occurrence_dates
FROM crime_dw.fact_crime f
JOIN crime_dw.dim_date d
    ON f.occur_date_key = d.date_key;