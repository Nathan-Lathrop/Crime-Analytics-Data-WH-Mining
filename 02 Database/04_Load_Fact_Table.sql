WITH clean_source AS (
    SELECT DISTINCT
        report_number, report_date, occur_date, occur_time,
        possible_date, possible_time, beat, location,
        ucr_literal, neighborhood, npu, latitude, longitude, geometry
    FROM crime_dw.staging_crime
),
parsed AS (
    SELECT
        s.*,

        CASE
            WHEN NULLIF(TRIM(report_date), '') IS NOT NULL
            THEN TO_DATE(LEFT(report_date, 11), 'YYYY Mon DD')
        END AS report_dt,

        CASE
            WHEN NULLIF(TRIM(occur_date), '') IS NOT NULL
            THEN TO_DATE(LEFT(occur_date, 11), 'YYYY Mon DD')
        END AS occur_dt,

        CASE
            WHEN NULLIF(TRIM(possible_date), '') IS NOT NULL
            THEN TO_DATE(LEFT(possible_date, 11), 'YYYY Mon DD')
        END AS possible_dt,

        CASE
            WHEN TRIM(occur_time) ~ '^[0-9]{1,2}:[0-9]{2}$'
             AND SPLIT_PART(TRIM(occur_time), ':', 1)::INTEGER < 24
             AND SPLIT_PART(TRIM(occur_time), ':', 2)::INTEGER < 60
            THEN TRIM(occur_time)::TIME

            WHEN TRIM(occur_time) = '2400'
            THEN TIME '00:00'

            WHEN TRIM(occur_time) ~ '^[0-9]{1,4}$'
             AND LPAD(TRIM(occur_time), 4, '0')::INTEGER / 100 < 24
             AND LPAD(TRIM(occur_time), 4, '0')::INTEGER % 100 < 60
            THEN MAKE_TIME(
                LPAD(TRIM(occur_time), 4, '0')::INTEGER / 100,
                LPAD(TRIM(occur_time), 4, '0')::INTEGER % 100,
                0
            )
        END AS occur_tm,

        CASE
            WHEN TRIM(possible_time) ~ '^[0-9]{1,2}:[0-9]{2}$'
             AND SPLIT_PART(TRIM(possible_time), ':', 1)::INTEGER < 24
             AND SPLIT_PART(TRIM(possible_time), ':', 2)::INTEGER < 60
            THEN TRIM(possible_time)::TIME

            WHEN TRIM(possible_time) = '2400'
            THEN TIME '00:00'

            WHEN TRIM(possible_time) ~ '^[0-9]{1,4}$'
             AND LPAD(TRIM(possible_time), 4, '0')::INTEGER / 100 < 24
             AND LPAD(TRIM(possible_time), 4, '0')::INTEGER % 100 < 60
            THEN MAKE_TIME(
                LPAD(TRIM(possible_time), 4, '0')::INTEGER / 100,
                LPAD(TRIM(possible_time), 4, '0')::INTEGER % 100,
                0
            )
        END AS possible_tm,

        COALESCE(NULLIF(TRIM(location), ''), 'Unknown') AS loc,
        NULLIF(TRIM(beat), '') AS beat_clean,
        NULLIF(TRIM(neighborhood), '') AS neighborhood_clean,
        NULLIF(TRIM(npu), '') AS npu_clean,

        CASE
            WHEN TRIM(latitude) ~ '^-?[0-9]+(\.[0-9]+)?$'
            THEN TRIM(latitude)::NUMERIC(10,6)
        END AS lat,

        CASE
            WHEN TRIM(longitude) ~ '^-?[0-9]+(\.[0-9]+)?$'
            THEN TRIM(longitude)::NUMERIC(10,6)
        END AS lon

    FROM clean_source s
)
INSERT INTO crime_dw.fact_crime (
    report_number,
    report_date_key,
    occur_date_key,
    possible_date_key,
    occur_time_key,
    possible_time_key,
    location_key,
    crime_type_key,
    incident_count
)
SELECT
    p.report_number,
    rd.date_key,
    od.date_key,
    pd.date_key,
    ot.time_key,
    pt.time_key,
    l.location_key,
    c.crime_type_key,
    1

FROM parsed p

LEFT JOIN crime_dw.dim_date rd
    ON rd.full_date = p.report_dt

LEFT JOIN crime_dw.dim_date od
    ON od.full_date = p.occur_dt

LEFT JOIN crime_dw.dim_date pd
    ON pd.full_date = p.possible_dt

LEFT JOIN crime_dw.dim_time ot
    ON ot.time_value = p.occur_tm

LEFT JOIN crime_dw.dim_time pt
    ON pt.time_value = p.possible_tm

JOIN crime_dw.dim_location l
    ON l.location = p.loc
   AND l.beat IS NOT DISTINCT FROM p.beat_clean
   AND l.neighborhood IS NOT DISTINCT FROM p.neighborhood_clean
   AND l.npu IS NOT DISTINCT FROM p.npu_clean
   AND l.latitude IS NOT DISTINCT FROM p.lat
   AND l.longitude IS NOT DISTINCT FROM p.lon

JOIN crime_dw.dim_crime_type c
    ON c.ucr_literal = TRIM(p.ucr_literal)

-- Prevent a second full load into an already-populated fact table.
WHERE NOT EXISTS (
    SELECT 1
    FROM crime_dw.fact_crime
);