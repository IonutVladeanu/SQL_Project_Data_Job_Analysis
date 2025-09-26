/* ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
Database Load Issues (follow if receiving permission denied when running SQL code below)

NOTE: If you are having issues with permissions. And you get error: 

'could not open file "[your file path]\job_postings_fact.csv" for reading: Permission denied.'

1. Open pgAdmin
2. In Object Explorer (left-hand pane), navigate to `sql_course` database
3. Right-click `sql_course` and select `PSQL Tool`
    - This opens a terminal window to write the following code
4. Get the absolute file path of your csv files
    1. Find path by right-clicking a CSV file in VS Code and selecting “Copy Path”
5. Paste the following into `PSQL Tool`, (with the CORRECT file path)

\copy company_dim FROM '[Insert File Path]/company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_dim FROM '[Insert File Path]/skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy job_postings_fact FROM '[Insert File Path]/job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_job_dim FROM '[Insert File Path]/skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

*/

-- NOTE: This has been updated from the video to fix issues with encoding

COPY company_dim
FROM 'D:\Data Science\Database_Course_YT_LUKE_BAROS\csv_files\company_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_dim
FROM 'D:\Data Science\Database_Course_YT_LUKE_BAROS\csv_files\skills_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY job_postings_fact
FROM 'D:\Data Science\Database_Course_YT_LUKE_BAROS\csv_files\job_postings_fact.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_job_dim
FROM 'D:\Data Science\Database_Course_YT_LUKE_BAROS\csv_files\skills_job_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');


SELECT * 
FROM job_postings_fact
LIMIT 100;


SELECT 
    job_title AS title, 
    job_location AS location,
    job_posted_date AS date_time
FROM 
    job_postings_fact
LIMIT 5;

SELECT 
    job_title AS title, 
    job_location AS location,
    job_posted_date::DATE AS date_time
FROM 
    job_postings_fact;


SELECT 
    job_title AS title, 
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date_time
FROM 
    job_postings_fact
LIMIT 5;



SELECT 
    job_title AS title, 
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date_time,
    EXTRACT(MONTH FROM job_posted_date) AS date_month,
    EXTRACT(YEAR FROM job_posted_date) AS date_year
FROM 
    job_postings_fact
LIMIT 5;


SELECT 
    COUNT(job_id) AS job_posted_count,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(YEAR FROM job_posted_date) AS year
FROM 
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY   
    month, year
ORDER BY 
    job_posted_count DESC;

-- Practice Problem 1
SELECT 
    AVG(salary_year_avg) AS average_salary,
    AVG(salary_hour_avg) AS average_hourly_pay
FROM 
    job_postings_fact
WHERE 
    job_title_short = 'Data Analyst'
    AND job_posted_date > '2023-06-01';

-- Practice Problem 2
SELECT
  EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'America/New_York') AS month,
  COUNT(*) AS job_postings
FROM job_postings_fact
WHERE EXTRACT(YEAR FROM job_posted_date AT TIME ZONE 'America/New_York') = 2023
GROUP BY month
ORDER BY month;

-- Prcatice Problem 3
SELECT 
    C.name AS company_name, 
    JP.job_title AS job_name,
    JP.job_health_insurance AS health_insurance,
    JP.job_location AS job_location,
    COUNT(*) AS number_of_jobs
FROM 
    job_postings_fact AS JP JOIN 
    company_dim AS C USING(company_id)
WHERE 
    EXTRACT(YEAR FROM JP.job_posted_date) = 2023
    AND EXTRACT(QUARTER FROM JP.job_posted_date) = 2
    AND JP.job_health_insurance = '1'
GROUP BY
    company_name, job_name, health_insurance, job_location
ORDER BY
    number_of_jobs DESC;