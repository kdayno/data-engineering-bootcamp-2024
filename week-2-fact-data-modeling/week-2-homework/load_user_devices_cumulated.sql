
-- The "date" col in this query is actually the "current_date". This assumes that this is an incremental daily load.
INSERT INTO user_devices_cumulated
WITH yesterday AS (
    SELECT
        *
    FROM user_devices_cumulated
    WHERE date = DATE('2022-12-31')
    ),

    devices_deduped AS (
        SELECT *
            , ROW_NUMBER() OVER ( PARTITION BY device_id, browser_type, device_type, browser_version_major) AS row_num
        FROM devices
        ),

    today AS (
        SELECT
            e.user_id,
            d.browser_type,
            DATE(CAST(e.event_time AS TIMESTAMP)) AS date_active
        FROM events e
        INNER JOIN devices_deduped d ON e.device_id = d.device_id
        WHERE DATE(CAST(event_time AS TIMESTAMP)) = DATE ('2023-01-01')
            AND e.user_id IS NOT NULL
            AND d.row_num = 1
        GROUP BY e.user_id, d.browser_type, DATE(CAST(e.event_time AS TIMESTAMP))
        )

    SELECT
        COALESCE(t.user_id, y.user_id) AS user_id,
        COALESCE(t.browser_type, y.browser_type) AS browser_type,
        COALESCE(t.date_active, y.date + INTERVAL '1 day') AS date,
        CASE
            WHEN y.device_activity_datelist IS NULL THEN ARRAY[t.date_active]
            WHEN t.date_active IS NULL THEN y.device_activity_datelist
            ELSE ARRAY[t.date_active] || y.device_activity_datelist
            END AS device_activity_datelist
    FROM today t
    FULL OUTER JOIN yesterday y ON t.user_id = y.user_id AND t.browser_type = y.browser_type;
