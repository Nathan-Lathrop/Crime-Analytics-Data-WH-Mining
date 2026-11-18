-- ==========================================
-- LOAD DATE DIMENSION
-- ==========================================

WITH source_dates AS (
    SELECT report_date AS date_string
    FROM crime_dw.staging_crime

    UNION

    SELECT occur_date
    FROM crime_dw.staging_crime

    UNION

    SELECT possible_date
    FROM crime_dw.staging_crime
),
parsed_dates AS (
    SELECT DISTINCT
        TO_DATE(LEFT(TRIM(date_string), 11), 'YYYY Mon DD') AS full_date
    FROM source_dates
    WHERE NULLIF(TRIM(date_string), '') IS NOT NULL
)
INSERT INTO crime_dw.dim_date (
    date_key,
    full_date,
    year,
    quarter,
    month,
    month_name,
    day_of_month,
    day_of_week,
    day_name,
    is_weekend
)
SELECT
    TO_CHAR(full_date, 'YYYYMMDD')::INTEGER,
    full_date,
    EXTRACT(YEAR FROM full_date)::SMALLINT,
    EXTRACT(QUARTER FROM full_date)::SMALLINT,
    EXTRACT(MONTH FROM full_date)::SMALLINT,
    TO_CHAR(full_date, 'FMMonth'),
    EXTRACT(DAY FROM full_date)::SMALLINT,
    EXTRACT(DOW FROM full_date)::SMALLINT,
    TO_CHAR(full_date, 'FMDay'),
    EXTRACT(DOW FROM full_date) IN (0, 6)
FROM parsed_dates
ON CONFLICT (date_key) DO NOTHING;


-- ==========================================
-- LOAD TIME DIMENSION
-- ==========================================

INSERT INTO crime_dw.dim_time (
    time_key,
    time_value,
    hour,
    minute,
    time_period
)
SELECT
    h * 100 + m,
    MAKE_TIME(h, m, 0),
    h,
    m,
    CASE
        WHEN h >= 0 AND h < 5 THEN 'Night'
        WHEN h >= 5 AND h < 11 THEN 'Early Morning'
        WHEN h >= 11 AND h < 12 THEN 'Morning'
        WHEN h >= 12 AND h < 17 THEN 'Afternoon'
        WHEN h >= 17 AND h < 21 THEN 'Evening'
        ELSE 'Night'
    END
FROM GENERATE_SERIES(0, 23) AS hours(h)
CROSS JOIN GENERATE_SERIES(0, 59) AS minutes(m)
ON CONFLICT (time_key) DO NOTHING;


-- ==========================================
-- LOAD LOCATION DIMENSION
-- ==========================================

WITH cleaned_locations AS (
    SELECT DISTINCT
        COALESCE(NULLIF(TRIM(location), ''), 'Unknown') AS location,
        NULLIF(TRIM(beat), '') AS beat,
        NULLIF(TRIM(neighborhood), '') AS neighborhood,
        NULLIF(TRIM(npu), '') AS npu,

        CASE
            WHEN TRIM(latitude) ~ '^-?[0-9]+(\.[0-9]+)?$'
            THEN TRIM(latitude)::NUMERIC(10,6)
        END AS latitude,

        CASE
            WHEN TRIM(longitude) ~ '^-?[0-9]+(\.[0-9]+)?$'
            THEN TRIM(longitude)::NUMERIC(10,6)
        END AS longitude

    FROM crime_dw.staging_crime
)
INSERT INTO crime_dw.dim_location (
    location,
    beat,
    neighborhood,
    npu,
    latitude,
    longitude
)
SELECT
    location,
    beat,
    neighborhood,
    npu,
    latitude,
    longitude
FROM cleaned_locations
ON CONFLICT DO NOTHING;


-- ==========================================
-- LOAD CRIME TYPE DIMENSION
-- ==========================================

INSERT INTO crime_dw.dim_crime_type (ucr_literal)
SELECT DISTINCT TRIM(ucr_literal)
FROM crime_dw.staging_crime
WHERE NULLIF(TRIM(ucr_literal), '') IS NOT NULL
ON CONFLICT (ucr_literal) DO NOTHING;

SELECT
    time_period,
    MIN(time_value) AS first_time,
    MAX(time_value) AS last_time,
    COUNT(*) AS time_entries
FROM crime_dw.dim_time
GROUP BY time_period
ORDER BY MIN(time_value);