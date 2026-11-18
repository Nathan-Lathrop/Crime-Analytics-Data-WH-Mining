CREATE TABLE IF NOT EXISTS crime_dw.staging_crime (
    report_number  TEXT,
    report_date    TEXT,
    occur_date     TEXT,
    occur_time     TEXT,
    possible_date  TEXT,
    possible_time  TEXT,
    beat           TEXT,
    location       TEXT,
    ucr_literal    TEXT,
    neighborhood   TEXT,
    npu            TEXT,
    latitude       TEXT,
    longitude      TEXT,
    geometry       TEXT
);