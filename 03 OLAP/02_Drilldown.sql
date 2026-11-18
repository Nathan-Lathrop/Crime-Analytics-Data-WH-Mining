SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(*) AS crime_records

FROM crime_dw.fact_crime f

JOIN crime_dw.dim_date d
    ON f.occur_date_key = d.date_key

WHERE d.year = 2020

GROUP BY
    d.year,
    d.month,
    d.month_name

ORDER BY d.month;