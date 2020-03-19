--IMPORTING DATA

-- Import SARS data to PostgreSQL
CREATE TABLE sars (
  Country text,
  Confirmed_cases text,
  Deaths integer,
  Fatality_ratio double precision
);

-- Import COVID-19 data to PostgreSQL
CREATE TABLE corona (
  Serial_no integer,
  Date_post date ,
  Province text,
  Country text,
  Last_update date,
  Confirmed_cases integer,
  Deaths integer,
  Recovered integer
);


-- CLEANING/FORMATTING DATA

-- Replace references in the 'corona' table to 'Mainland China' with 'China'
-- so the two tables are consistent.
UPDATE corona
SET country = REPLACE(country, 'Mainland China', 'China');


-- Add a 'disease' column to the 'corona' table so the tables can be appended.
ALTER TABLE corona
ADD  disease text;
UPDATE corona
SET disease = 'COVID-19' WHERE disease IS NULL;

-- Add a 'disease' column to the 'sars' table so the tables can be appended.
ALTER TABLE sars
ADD  disease text;
UPDATE sars
SET disease = 'SARS' WHERE disease IS NULL;


-- ANALYSING DATA

-- Create a temporary table showing relevant COVID-19 data.
WITH t1 AS (SELECT disease,
 country,
 SUM(confirmed_cases) AS confirmed,
 SUM(deaths) AS deaths,
 ROUND((SUM(deaths)/SUM(confirmed_cases)) * 100.0) AS fatality_ratio
FROM corona
WHERE country IN ('China','Hong Kong', 'Macau', 'Taiwan') AND date_post = '2020-02-15'
GROUP BY 1, 2),

--Create a temporary table showing relevant SARS data.
t2 AS (
 SELECT disease,
 country AS country_SARS,
 confirmed_cases AS confirmed_SARS,
 deaths AS deaths_SARS,
 fatality_ratio AS fatality_ratio_SARS
FROM sars
WHERE country IN ('China', 'Hong Kong', 'Taiwan', 'Macau'))

-- Append both tables with 'UNION' so that we can feed relevant columns into
-- Tableau
SELECT *
FROM t1
UNION
SELECT *
FROM t2
ORDER BY 1, 2
