WITH user_devices AS(
        SELECT *
        FROM user_devices_cumulated
        WHERE date = DATE('2023-01-03')
    ),

    series AS (
        SELECT *
        FROM generate_series(DATE('2023-01-01'), DATE('2023-01-31'), INTERVAL '1 day') AS series_date
    ),

    place_holder_ints AS (
        SELECT
            CASE
            WHEN device_activity_datelist @> ARRAY [DATE (series_date)] THEN CAST(POW(2, 32 - (date - DATE (series_date))) AS BIGINT)
            ELSE 0
            END AS placeholder_int_value,
            *
        FROM user_devices
        CROSS JOIN series
    )

    SELECT
        user_id,
        browser_type,
        CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32)) AS datelist_int,
        BIT_COUNT(CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32))) AS bit_count,
        BIT_COUNT(CAST(CAST(SUM(placeholder_int_value) AS BIGINT) AS BIT(32))) > 0 AS dim_is_monthly_active
    FROM place_holder_ints
    GROUP BY user_id, browser_type
    ORDER BY user_id, browser_type;
