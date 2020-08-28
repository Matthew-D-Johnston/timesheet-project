CREATE TABLE timesheet (
  id serial PRIMARY KEY,
  article_name text NOT NULL,
  url text NOT NULL,
  date_published date NOT NULL,
  word_count integer NOT NULL,
  cc_credit text NOT NULL,
  hours decimal(4, 2) NOT NULL,
  hourly_rate decimal(5, 2) NOT NULL,
  value decimal(6, 2) NOT NULL
);

ALTER SEQUENCE timesheet_id_seq RESTART WITH 4;

