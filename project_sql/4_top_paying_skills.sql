/*
Answer: What are the top skills based on salary?
- Look at the average salary associated with each skill for Data Analyst
    positions 
- Focuses on roles with specified salaries, regardless of location
- Why? It reveals how different skills impact salary levels for Data
    Analysts and helps identify the most financially rewarding skills
    to acquire or improve
*/

SELECT
    sd.skill_id,
    sd.skills,
    COUNT(*) AS demand_skills_count,
    ROUND(AVG(jpf.salary_year_avg), 0) as average_year_salary
FROM job_postings_fact jpf
JOIN skills_job_dim sjd
ON jpf.job_id = sjd.job_id
JOIN skills_dim sd
ON sjd.skill_id = sd.skill_id
WHERE
    jpf.job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND jpf.job_location LIKE '%Romania%'
GROUP BY sd.skill_id, sd.skills
ORDER BY average_year_salary DESC
LIMIT 25;