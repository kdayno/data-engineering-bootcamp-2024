
INSERT INTO hosts_cumulated
WITH yesterday AS (
    SELECT *
    FROM hosts_cumulated
    WHERE date = DATE('2022-12-31')
    ),

    today AS (
        SELECT
            host,
            DATE(CAST(event_time AS timestamp)) AS date_active
        FROM events
        WHERE CAST(CAST(event_time AS timestamp) AS date) = DATE('2023-01-01')
        GROUP BY host, DATE(CAST(event_time AS timestamp))
    )

    SELECT
        COALESCE(t.host, y.host) AS host,
        COALESCE(t.date_active, y.date) AS date,
        CASE
            WHEN y.host_activity_datelist IS NULL THEN ARRAY[t.date_active]
            WHEN t.date_active IS NULL THEN y.host_activity_datelist
            ELSE ARRAY[t.date_active] || y.host_activity_datelist
        END AS host_activity_datelist
    FROM today t
    FULL OUTER JOIN yesterday y ON t.host = y.host;
