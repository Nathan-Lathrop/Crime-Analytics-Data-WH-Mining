-- ==========================================
-- CHECK TABLE ROW COUNTS
-- ==========================================

SELECT 'Staging' AS table_name, COUNT(*) AS total_rows
FROM crime_dw.staging_crime

UNION ALL

SELECT 'Date Dimension', COUNT(*)
FROM crime_dw.dim_date

UNION ALL

SELECT 'Time Dimension', COUNT(*)
FROM crime_dw.dim_time

UNION ALL

SELECT 'Location Dimension', COUNT(*)
FROM crime_dw.dim_location

UNION ALL

SELECT 'Crime Type Dimension', COUNT(*)
FROM crime_dw.dim_crime_type

UNION ALL

SELECT 'Fact Table', COUNT(*)
FROM crime_dw.fact_crime;


-- ==========================================
-- CHECK MISSING DATE AND TIME KEYS
-- ==========================================

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE report_date_key IS NULL
    ) AS missing_report_dates,

    COUNT(*) FILTER (
        WHERE occur_date_key IS NULL
    ) AS missing_occurrence_dates,

    COUNT(*) FILTER (
        WHERE possible_date_key IS NULL
    ) AS missing_possible_dates,

    COUNT(*) FILTER (
        WHERE occur_time_key IS NULL
    ) AS missing_occurrence_times,

    COUNT(*) FILTER (
        WHERE possible_time_key IS NULL
    ) AS missing_possible_times

FROM crime_dw.fact_crime;


-- ==========================================
-- CHECK DIMENSION REFERENCES
-- ==========================================

SELECT
    COUNT(*) AS total_fact_rows,

    COUNT(*) FILTER (
        WHERE l.location_key IS NULL
    ) AS invalid_location_references,

    COUNT(*) FILTER (
        WHERE c.crime_type_key IS NULL
    ) AS invalid_crime_type_references,

    COUNT(*) FILTER (
        WHERE f.report_date_key IS NOT NULL
          AND rd.date_key IS NULL
    ) AS invalid_report_date_references,

    COUNT(*) FILTER (
        WHERE f.occur_date_key IS NOT NULL
          AND od.date_key IS NULL
    ) AS invalid_occurrence_date_references,

    COUNT(*) FILTER (
        WHERE f.possible_date_key IS NOT NULL
          AND pd.date_key IS NULL
    ) AS invalid_possible_date_references,

    COUNT(*) FILTER (
        WHERE f.occur_time_key IS NOT NULL
          AND ot.time_key IS NULL
    ) AS invalid_occurrence_time_references,

    COUNT(*) FILTER (
        WHERE f.possible_time_key IS NOT NULL
          AND pt.time_key IS NULL
    ) AS invalid_possible_time_references

FROM crime_dw.fact_crime f

LEFT JOIN crime_dw.dim_location l
    ON f.location_key = l.location_key

LEFT JOIN crime_dw.dim_crime_type c
    ON f.crime_type_key = c.crime_type_key

LEFT JOIN crime_dw.dim_date rd
    ON f.report_date_key = rd.date_key

LEFT JOIN crime_dw.dim_date od
    ON f.occur_date_key = od.date_key

LEFT JOIN crime_dw.dim_date pd
    ON f.possible_date_key = pd.date_key

LEFT JOIN crime_dw.dim_time ot
    ON f.occur_time_key = ot.time_key

LEFT JOIN crime_dw.dim_time pt
    ON f.possible_time_key = pt.time_key;