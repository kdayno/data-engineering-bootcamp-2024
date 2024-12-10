CREATE TABLE hosts_cumulated (
    host TEXT,
    date DATE,
    host_activity_datelist DATE[],
    PRIMARY KEY (host, date)
);