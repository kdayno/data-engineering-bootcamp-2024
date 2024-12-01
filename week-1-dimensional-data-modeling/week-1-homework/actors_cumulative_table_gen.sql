
/*** Cumulative Table Design  ***/
-- INSERT INTO actors
WITH last_year AS (
    SELECT *
    FROM actors
    WHERE year = 1999
    ),

    current_year AS (
    SELECT
        actor,
        actorid,
        year,
        rating,
        ARRAY[ROW(film, votes, rating, filmid)::film_stats] AS film
    FROM actor_films
    WHERE year = 2000
    ),

    current_year_aggregated AS (
    SELECT
        actor,
        actorid,
        year,
        AVG(rating) AS average_rating,
        array_agg(film) AS films
    FROM current_year
    GROUP BY actor, actorid, year
    )

    SELECT
        COALESCE(cy.actor, ly.actor) AS actor_name,
        COALESCE(cy.actorid, ly.actorid) AS actor_id,
        COALESCE(cy.year, ly.year + 1) AS year,

        CASE
            WHEN ly.films IS NULL THEN cy.films
            WHEN cy.films IS NOT NULL THEN ly.films || cy.films
            ELSE ly.films
        END AS films,

        CASE
            WHEN cy.average_rating > 8 THEN 'star'
            WHEN cy.average_rating > 7 AND average_rating <= 8 THEN 'good'
            WHEN cy.average_rating > 6 AND average_rating <= 7 THEN 'average'
            ELSE'bad'
        END AS quality_class,

        CASE
            WHEN cy.year IS NOT NULL THEN TRUE
            ELSE FALSE
        END AS is_active

    FROM last_year ly
    FULL OUTER JOIN current_year_aggregated cy ON ly.actorid = cy.actorid;
