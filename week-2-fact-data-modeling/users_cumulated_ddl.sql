CREATE TABLE users_cumulated (
    user_id TEXT,
    dates_active DATE[], -- The list of dates in the past where the user was active
    date DATE, -- The current date for the user
    PRIMARY KEY (user_id, date)
);

DROP TABLE users_cumulated;