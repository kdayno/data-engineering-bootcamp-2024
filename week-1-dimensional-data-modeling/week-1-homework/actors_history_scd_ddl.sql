CREATE TABLE actors_history_scd (
    actor TEXT,
    quality_class TEXT,
    is_active BOOLEAN,
    start_date DATE,
    end_date DATE,
    PRIMARY KEY(actor, start_date)
);

CREATE TYPE scd_type AS (
    quality_class TEXT,
    is_active BOOLEAN,
    start_date DATE,
    end_date DATE
                    );