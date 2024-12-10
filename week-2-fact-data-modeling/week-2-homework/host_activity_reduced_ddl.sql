CREATE TABLE host_activity_reduced (
    host TEXT,
    month DATE,
    hit_array INTEGER[],
    unique_vistors_array INTEGER[],
    PRIMARY KEY (host, month)
);
