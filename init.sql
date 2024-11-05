DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'countdb') THEN
        PERFORM dblink_exec('dbname=postgres', 'CREATE DATABASE countdb');
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mary') THEN
        CREATE USER mary WITH PASSWORD '123456A!';
    END IF;
END $$;

GRANT ALL PRIVILEGES ON DATABASE countdb TO mary;

\c countdb

CREATE TABLE IF NOT EXISTS counter (
    id SERIAL PRIMARY KEY,
    count INT DEFAULT 0
);