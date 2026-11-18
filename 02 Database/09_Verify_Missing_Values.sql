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