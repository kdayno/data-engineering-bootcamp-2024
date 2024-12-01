CREATE TYPE film_stats AS (
    film TEXT,
    votes INTEGER,
    rating REAL,
    filmid TEXT);


CREATE TABLE actors (
    actor TEXT,
    year INTEGER,
    films film_stats[],
    quality_class TEXT,
    is_active BOOLEAN,
    PRIMARY KEY (actor, year)
);