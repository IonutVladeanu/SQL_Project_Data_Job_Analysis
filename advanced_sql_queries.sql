-- January
CREATE TABLE january_jobs AS 
    SELECT *
    FROM job_postings_fact
    WHERE 
        EXTRACT(MONTH FROM job_posted_date) = 1;

-- February
CREATE TABLE february_jobs AS 
    SELECT *
    FROM job_postings_fact
    WHERE 
        EXTRACT(MONTH FROM job_posted_date) = 2;

-- March
CREATE TABLE march_jobs AS 
    SELECT *
    FROM job_postings_fact
    WHERE 
        EXTRACT(MONTH FROM job_posted_date) = 3;


SELECT job_posted_date
FROM january_jobs;


SELECT 
    job_title,
    job_location,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact;


SELECT 
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY location_category;


SELECT 
    COUNT(job_id) AS number_of_jobs,
    CASE 
        WHEN salary_year_avg > 240000 THEN 'High Salary'
        WHEN salary_year_avg > 120000 THEN 'Standard Salary'
        ELSE 'Low Salary'
    END AS salary_category
FROM job_postings_fact
WHERE 
    job_title_short = 'Data Analyst'
GROUP BY 
    salary_category
ORDER BY
    number_of_jobs DESC;


SELECT 
    C.name,
    JP.job_title,
    JP.job_location,
    COUNT(JP.job_id) AS number_of_jobs
FROM company_dim C JOIN job_postings_fact JP USING(company_id)
WHERE 
    JP.job_location LIKE '%Romania%'
    AND JP.job_title_short = 'Data Analyst'
GROUP BY 
    JP.job_location, C.name, JP.job_title
ORDER BY
    number_of_jobs DESC;


Select 
    C.name,
    JP.job_title,
    JP.job_location,
    JP.salary_year_avg
FROM job_postings_fact JP JOIN company_dim C USING(company_id)
WHERE
    salary_year_avg > 240000
    AND JP.job_title_short = 'Data Analyst';


SELECT *
FROM ( -- Subquery starts here 
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1 
) AS january_jobs;



WITH january_jobs AS ( -- CTE definition starts here
    SELECT * 
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) -- CTE definition ends here

SELECT *
FROM january_jobs;


SELECT 
    C.name,
    JP.job_title,
    JP.job_location,
    JP.salary_year_avg,
    JP.job_no_degree_mention
FROM 
    job_postings_fact JP JOIN company_dim C
    ON JP.company_id = C.company_id
WHERE 
    job_no_degree_mention = FALSE


SELECT
  c.name,
  jp.job_title,
  jp.job_location,
  jp.salary_year_avg,
  jp.job_no_degree_mention
FROM company_dim c
JOIN (
    SELECT 
        company_id, 
        job_title, 
        job_location,
        salary_year_avg, 
        job_no_degree_mention
    FROM job_postings_fact
    WHERE job_no_degree_mention = FALSE
) AS jp
  ON jp.company_id = c.company_id;


/*
Find the companies that have the most job openings.
- Get the total number of job postings per company id (job_posting_fact)
- Return the total number of jobs with the company name (company_dim)
*/
WITH company_job_count AS(
    SELECT 
        company_id,
        COUNT(*) AS total_jobs
    FROM 
        job_postings_fact
    GROUP BY 
        company_id
)

SELECT 
    company_dim.name AS company_name,
    company_job_count.total_jobs
FROM 
    company_dim
LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY 
    total_jobs DESC


-- Practice Problem 1 (Subqueries and CTEs)
/*
Identify the top 5 skills that are most frequently mentioned in job
postings. Use a subquery to find the skill IDs with the highest counts
in the highest counts in the 'skill_job_dim' table and then join this 
result with the 'skills_dim' table to get the skill names.
*/
WITH top_skills AS (
    SELECT
        skill_id,
        COUNT(*) AS jobs_requesting_skill
    FROM skills_job_dim
    GROUP BY skill_id
    ORDER BY jobs_requesting_skill DESC
    LIMIT 5
)

SELECT 
    sd.skills AS skill_name,
    ts.jobs_requesting_skill
FROM top_skills ts JOIN skills_dim sd
ON sd.skill_id = ts.skill_id 
ORDER BY ts.jobs_requesting_skill DESC;

-- Practice Problem 2 (Subqueries and CTEs)
/*
Determine the size category ('Small', 'Medium', or 'Large') for 
each company by first identifying the number of job postings they have. 
Use a subquery to calculate the total job postings per company. A company 
is considered 'Small' if it has less than 10 job postings, 'Medium' if the
number of job postings is between 10 and 50, and 'Large' if it has more 
than 50 job postings. Implement a subquery to aggregate job counts per
company before classifying them based on size.
*/
WITH job_counts AS (
  SELECT company_id, COUNT(*) AS job_count
  FROM job_postings_fact
  GROUP BY company_id
)
SELECT
  c.company_id,
  c.name AS company_name,
  COALESCE(jc.job_count, 0) AS total_job_postings,
  CASE
    WHEN COALESCE(jc.job_count, 0) < 10 THEN 'Small'
    WHEN COALESCE(jc.job_count, 0) BETWEEN 10 AND 50 THEN 'Medium'
    ELSE 'Large'
  END AS size_category
FROM company_dim c
LEFT JOIN job_counts jc
  ON jc.company_id = c.company_id
ORDER BY total_job_postings DESC, company_name;

/*
Find the count of the number of remote job postings per skill
    - Display the top 5 skills by their demand in remote jobs
    - Include skill ID, name, and count of postings requiring the skill
*/
SELECT 
    sd.skill_id,
    sd.skills AS skill_name,
    COUNT(*) AS skill_count
FROM job_postings_fact jpf 
JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
WHERE 
    jpf.job_work_from_home = TRUE
    AND jpf.job_title_short = 'Data Analyst'
GROUP BY sd.skills, sd.skill_id
ORDER BY skill_count DESC
LIMIT 5;

-- Same query but with CTEs
WITH remote_job_skills AS(
    SELECT 
        skill_id,
        COUNT(*) AS skill_count
    FROM job_postings_fact AS job_postings
    JOIN skills_job_dim AS skills_to_job
    ON job_postings.job_id = skills_to_job.job_id
    WHERE 
        job_postings.job_work_from_home = TRUE
        AND job_postings.job_title_short = 'Data Analyst'
    GROUP BY skill_id
)
SELECT  
    skills.skill_id,
    skills AS skill_name,
    skill_count
FROM remote_job_skills
INNER JOIN skills_dim AS skills 
ON skills.skill_id = remote_job_skills.skill_id
ORDER BY skill_count DESC
LIMIT 5;


-- UNIONS

-- Get jobs and companies from January
SELECT
    job_title_short,
    company_id,
    job_location 
FROM 
    january_jobs

UNION

-- Get jobs and companies from February
SELECT
    job_title_short,
    company_id,
    job_location
FROM 
    february_jobs

UNION

-- Get jobs and companies from March
SELECT
    job_title_short,
    company_id,
    job_location
FROM 
    march_jobs


-- Get jobs and companies from January
SELECT
    job_title_short,
    company_id,
    job_location 
FROM 
    january_jobs

UNION ALL

-- Get jobs and companies from February
SELECT
    job_title_short,
    company_id,
    job_location
FROM 
    february_jobs

UNION ALL

-- Get jobs and companies from March
SELECT
    job_title_short,
    company_id,
    job_location
FROM 
    march_jobs


-- UNION PRACTICE PROBLEM 
/*
- Get the corresponding skill and skill type for each job posting in Q1
- Includes those without any skills, too
- Why? Look at the skills and the type for each job in the first quarter
that has a salary > 70000 usd
*/
-- This way we get all the jobs with salaries over 70k usd 
-- whether or not they have a skill attached
WITH job_postings_Q1 AS(
    SELECT 
        jpf.job_id,
        jpf.job_title,
        jpf.salary_year_avg
    FROM job_postings_fact AS jpf
    WHERE 
        EXTRACT(QUARTER FROM jpf.job_posted_date) = 1
        AND jpf.salary_year_avg > 70000
)
SELECT 
    jp.job_title AS job_name,
    sd.skills AS skill,
    sd.type AS skill_type,
    jp.salary_year_avg AS yearly_salary
FROM job_postings_Q1 jp
LEFT JOIN skills_job_dim sjd 
ON jp.job_id = sjd.job_id
LEFT JOIN skills_dim sd 
ON sd.skill_id = sjd.skill_id
ORDER BY yearly_salary DESC;

-- without CTEs
SELECT 
    jpf.job_title AS job_name,
    sd.skills AS skill,
    sd.type AS skill_type,
    jpf.salary_year_avg AS yearly_salary
FROM job_postings_fact jpf
LEFT JOIN skills_job_dim sjd
ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim sd
ON sjd.skill_id = sd.skill_id
WHERE
    EXTRACT(QUARTER FROM jpf.job_posted_date) = 1
    AND jpf.salary_year_avg > 70000
ORDER BY yearly_salary DESC

/*
Find job postings from the first quarter that have a salary greater than 70k usd
- Combine job postings tables from the first quarter of 2023 (Jan-Mar)
- Gets job postings with an average yearly salary > $70,000
*/
WITH Q1 AS (
    SELECT * 
    FROM january_jobs

    UNION ALL

    SELECT * 
    FROM february_jobs

    UNION ALL

    SELECT *
    FROM march_jobs
)
SELECT 
    Q1.job_title AS job_name,
    Q1.job_location,
    Q1.job_via AS application_platform,
    Q1.job_posted_date::DATE,
    Q1.salary_year_avg AS yearly_salary
FROM Q1
WHERE
    Q1.salary_year_avg > 70000
    AND Q1.job_title_short = 'Data Analyst'
ORDER BY
    yearly_salary DESC

-- OR with a subquery in the FROM clause
SELECT 
    Q1.job_title as job_name,
    Q1.job_location,
    Q1.job_via AS application_platform,
    Q1.job_posted_date::DATE,
    Q1.salary_year_avg AS yearly_salary
FROM (
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT * 
    FROM february_jobs
    UNION ALL 
    SELECT *
    FROM march_jobs
) AS Q1
WHERE 
    Q1.salary_year_avg > 70000
    AND Q1.job_title_short = 'Data Analyst'
ORDER BY 
    yearly_salary DESC

    