/*
Answer: What are the most optimal skills to learn (aka it's high demand
and a high-paying skill)?
- Identify skills in high demand and associated with a high average 
    salaries for Data Analyst roles
- Concentrates on remote and Romania positions with specified salaries
- Why? Targets skills that offer job security (high demand) and financial
    benefits (high salaries), offering strategic insights for career
    development in data analysis
*/

WITH skills_demand AS (
    SELECT
        sd.skill_id,
        sd.skills,
        COUNT(*) as demand_skills_count
    FROM job_postings_fact jpf
    JOIN skills_job_dim sjd
    ON jpf.job_id = sjd.job_id
    JOIN skills_dim sd
    ON sjd.skill_id = sd.skill_id
    WHERE
        jpf.job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL 
        AND (jpf.job_location LIKE '%Romania%' OR 
        jpf.job_location = 'Anywhere')
    GROUP BY sd.skill_id

), average_salary AS (
    SELECT
        sd.skill_id,
        sd.skills,
        ROUND(AVG(jpf.salary_year_avg), 0) as average_year_salary
    FROM job_postings_fact jpf
    JOIN skills_job_dim sjd
    ON jpf.job_id = sjd.job_id
    JOIN skills_dim sd
    ON sjd.skill_id = sd.skill_id
    WHERE
        jpf.job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
    GROUP BY sd.skill_id

)

SELECT 
    sd.skill_id,
    sd.skills,
    sd.demand_skills_count,
    asa.average_year_salary
FROM skills_demand sd
JOIN average_salary asa
ON sd.skill_id = asa.skill_id
WHERE 
    demand_skills_count > 10
ORDER BY 
    demand_skills_count DESC, average_year_salary DESC
LIMIT 25