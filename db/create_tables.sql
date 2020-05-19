DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS links;

CREATE TABLE companies (
    id INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    loc TEXT
);

CREATE TABLE jobs (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    company_id INTEGER NOT NULL,
    description TEXT,
    indeed_resume BOOLEAN,
    applied BOOLEAN,

    FOREIGN KEY company_id REFERENCES companies(id)
);

CREATE TABLE links (
    id INTEGER PRIMARY KEY,
    listing_link TEXT NOT NULL,
    apply_link TEXT NOT NULL,
    job_id INTEGER NOT NULL,

    FOREIGN KEY job_id REFERENCES jobs(id)
);