DROP TABLE IF EXISTS links;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS companies;

CREATE TABLE companies (
    id INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE jobs (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    company_id INTEGER NOT NULL,
    location VARCHAR(255),
    description TEXT,
    indeed_resume INTEGER NOT NULL,
    applied INTEGER NOT NULL,

    FOREIGN KEY (company_id) REFERENCES companies(id)
);

CREATE TABLE links (
    id INTEGER PRIMARY KEY,
    listing_link TEXT NOT NULL,
    apply_link TEXT NOT NULL,
    job_id INTEGER NOT NULL,

    FOREIGN KEY (job_id) REFERENCES jobs(id)
);
