
/** Query to Execute Full Load into actors table **/

-- INSERT INTO actors
WITH years AS (
        SELECT *
        FROM GENERATE_SERIES(1970,2021) AS year
    ),

    actors AS (
        SELECT
            actor,
            MIN(year) AS first_year
        FROM actor_films
        GROUP BY actor
    ),

    actors_and_years  AS (
        SELECT *
        FROM actors a
        JOIN years y ON a.first_year <= y.year
    ),

    windowed AS (
        SELECT
            ay.actor,
            ay.year,

            ARRAY_REMOVE(
                        ARRAY_AGG(
                        CASE WHEN af.year IS NOT NULL THEN ROW (film, votes, rating, filmid)::film_stats END)
                        OVER (PARTITION BY ay.actor ORDER BY COALESCE(ay.year, af.year)),
                        NULL
                    ) AS films,

            AVG(rating) OVER(PARTITION BY ay.actor, ay.year ORDER BY COALESCE(ay.year, af.year)) AS average_rating,

            CASE
                WHEN af.year IS NOT NULL THEN TRUE
                ELSE FALSE
            END AS is_active

        FROM actors_and_years ay
        LEFT JOIN actor_films af ON ay.year = af.year
            AND ay.actor = af.actor
        ORDER BY ay.actor, ay.year
        ),

    with_quality_class AS (
        SELECT
            *,
            CASE
                WHEN average_rating > 8 THEN 'star'
                WHEN average_rating > 7 AND average_rating <= 8 THEN 'good'
                WHEN average_rating > 6 AND average_rating <= 7 THEN 'average'
                ELSE'bad'
            END AS quality_class
        FROM windowed
    )

    SELECT
        actor,
        year,
        films,
        quality_class,
        is_active

    FROM with_quality_class
    GROUP BY  actor, year, films, quality_class, is_active
    ORDER BY actor, year;