INSERT INTO host_activity_reduced
WITH daily_aggregate AS (
    SELECT
        host,
        DATE(event_time) AS date,
        COUNT(*) AS num_site_hits,
        COUNT(DISTINCT user_id) AS unique_site_hits
    FROM events
    WHERE DATE(event_time) = DATE('2024-01-02')
    GROUP BY host, DATE(event_time)
    ),

    yesterday_array AS (
        SELECT *
        FROM host_activity_reduced
        WHERE month = DATE('2024-01-01')
    )

    SELECT
        COALESCE(da.host, ya.host) AS host,
        COALESCE(ya.month,  DATE_TRUNC('month', da.date)) AS month,

        CASE
            -- When the previous days has hits, then concat with today's hits count to extend the array
            WHEN ya.hit_array IS NOT NULL THEN ya.hit_array || ARRAY[COALESCE(da.num_site_hits, 0)]
            -- When the previous days has no hits, then concat an array of 0's with today's hits count to extend the array
            WHEN ya.hit_array IS NULL THEN ARRAY_FILL(0, ARRAY[COALESCE(date - DATE(DATE_TRUNC('month', date)), 0)]) || ARRAY[COALESCE(da.num_site_hits, 0)]
        END AS hit_array,

        CASE
            -- When the previous days has unique hits, then concat with today's unique hits count to extend the array
            WHEN ya.unique_vistors_array IS NOT NULL THEN ya.unique_vistors_array || ARRAY[COALESCE(da.unique_site_hits, 0)]
            -- When the previous days has no unique hits, then concat an array of 0's with today's unique hits count to extend the array
            WHEN ya.unique_vistors_array IS NULL THEN ARRAY_FILL(0, ARRAY[COALESCE(date - DATE(DATE_TRUNC('month', date)), 0)]) || ARRAY[COALESCE(da.unique_site_hits, 0)]
        END AS unique_vistors_array

    FROM daily_aggregate da
    FULL OUTER JOIN yesterday_array ya ON da.host = ya.host
    ON CONFLICT(host, month)
    DO
        UPDATE SET hit_array = EXCLUDED.hit_array,  unique_vistors_array = EXCLUDED.unique_vistors_array;