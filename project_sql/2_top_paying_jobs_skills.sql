/*
Question: What skills are required for the top-paying data analyst jobs?
- Use the top 10 highest-paying Data Analyst jobs from first query
- Add the specific skills required for these roles 
- Why? It provides a detailed look at which high-paying jobs demand 
    certain skills, helping job seekers understand which skills to 
    develop that allign with top salaries
*/

WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        cd.name AS company_name,
        salary_year_avg
    FROM job_postings_fact jpf
    LEFT JOIN company_dim cd 
    ON jpf.company_id = cd.company_id
    WHERE 
        job_title_short = 'Data Analyst'
        AND job_location = 'Anywhere'
        AND salary_year_avg IS NOT NULL
    ORDER BY salary_year_avg DESC
    LIMIT 10
)

SELECT
    tpj.*,
    sd.skills,
    sd.type
FROM top_paying_jobs tpj 
JOIN skills_job_dim sjd 
ON tpj.job_id = sjd.job_id
JOIN skills_dim sd
ON sjd.skill_id = sd.skill_id
ORDER BY
    tpj.salary_year_avg DESC