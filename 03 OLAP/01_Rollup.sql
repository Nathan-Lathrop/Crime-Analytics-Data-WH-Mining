SELECT
    d.year,

    CASE
        WHEN GROUPING(d.month) = 1
        THEN 'Year Total'
        ELSE d.month_name
    END AS period,

    COUNT(*) AS crime_records,
    COUNT(DISTINCT f.report_number) AS unique_reports

FROM crime_dw.fact_crime f

JOIN crime_dw.dim_date d
    ON f.occur_date_key = d.date_key

GROUP BY GROUPING SETS (
    (d.year),
    (d.year, d.month, d.month_name)
)

ORDER BY
    d.year,
    GROUPING(d.month) DESC,
    d.month;