/** Query to Execute Incremental Load into actors_history_scd (SCD2) **/
-- INSERT INTO actors_history_scd
WITH last_year_scd AS(
    SELECT *
    FROM actors_history_scd
    WHERE start_date = '2020-01-01'
        AND end_date = '2020-12-31'
    ),

    historical_scd AS (
        SELECT *
        FROM actors_history_scd
        WHERE end_date < '2020-01-01'

    ),

    this_year_data AS(
        SELECT
            *,
            to_date(year::varchar, 'yyyy') AS start_date,
            (to_date(year::varchar, 'yyyy') + interval '1 year' - interval  '1 day')::date AS end_date
        FROM actors
        WHERE year = '2021'
    ),

    unchanged_records AS (
        SELECT
            ty.actor,
            ty.quality_class, ty.is_active,
            ly.start_date,
            ty.end_date
        FROM this_year_data ty
        INNER JOIN last_year_scd ly ON ty.actor = ly.actor
        WHERE ty.quality_class = ly.quality_class
            AND ty.is_active = ly.is_active
    ),

    changed_records AS (
        SELECT
            ty.actor,
            unnest(
                ARRAY[
                    ROW(
                        ly.quality_class,
                        ly.is_active,
                        ly.start_date,
                        ly.end_date
                        )::scd_type,
                    ROW(
                        ty.quality_class,
                        ty.is_active,
                        ty.start_date,
                        ty.end_date
                        )::scd_type]) AS records
        FROM this_year_data ty
        INNER JOIN last_year_scd ly ON ty.actor = ly.actor
        WHERE (ty.quality_class <> ly.quality_class
            OR ty.is_active <> ly.is_active)
    ),

    unnested_changed_records AS (
        SELECT
            actor,
            (records::scd_type).quality_class,
            (records::scd_type).is_active,
            (records::scd_type).start_date,
            (records::scd_type).end_date
        FROM changed_records
    ),

    new_records AS (
        SELECT
            ty.actor,
            ty.quality_class,
            ty.is_active,
            ty.start_date,
            ty.end_date
        FROM this_year_data ty
        LEFT JOIN last_year_scd ly ON ty.actor = ly.actor
        WHERE ly.actor IS NULL
    )

    SELECT * FROM historical_scd

    UNION ALL

    SELECT * FROM unchanged_records

    UNION ALL

    SELECT * FROM unnested_changed_records

    UNION ALL

    SELECT * FROM new_records;



