CREATE TABLE array_metrics(
    user_Id NUMERIC,
    month_start DATE,
    metric_name TEXT,
    metric_array REAL[],
    PRIMARY KEY (user_id, month_start, metric_name)
);