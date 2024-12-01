
/** Query to Execute Full Load into actors_history_scd (SCD2) **/
-- INSERT INTO actors_history_scd
WITH with_previous AS (
    SELECT
        actor,
        to_date(year::varchar, 'yyyy') AS start_date,
        (to_date(year::varchar, 'yyyy') + interval '1 year' - interval  '1 day')::date AS end_date,
        quality_class,
        is_active,
        LAG(quality_class, 1) OVER (PARTITION BY actor ORDER BY year) AS previous_quality_class,
        LAG(is_active, 1) OVER (PARTITION BY actor ORDER BY year) AS previous_is_active

    FROM actors
    ),

    with_indicators AS (
    SELECT
        *,
        CASE
            WHEN quality_class <> previous_quality_class THEN 1
            WHEN is_active <> previous_is_active THEN 1
            ELSE 0
        END AS change_indicator
    FROM with_previous
    ),

    with_streaks AS (
    SELECT
        *,
        SUM(change_indicator) OVER (PARTITION BY actor ORDER BY start_date) AS streak_identifier
    FROM with_indicators
    )

SELECT
    actor,
    quality_class,
    is_active,
    MIN(start_date) AS start_date,
    MAX(end_date) AS end_date
FROM with_streaks
GROUP BY actor, streak_identifier, is_active, quality_class
ORDER BY actor, streak_identifier;
