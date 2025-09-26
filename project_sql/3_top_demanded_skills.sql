/*
Question: What are the most in-demand skills for data analysts?
- Join job postings to inner join table similar to query 2
- Identify the top 5 in-demand skills for a data analyst.
- Focus on all job postings.
- Why? Retrieves the top 5 skills with the highest demand in the job 
    market, providing insights into the most valuable skills for job 
    seekers. 
*/ 

-- Using CTEs
WITH top_skills AS(
    SELECT 
        sjd.skill_id,
        COUNT(*) AS skills_count
    FROM job_postings_fact jps
    JOIN skills_job_dim sjd
    ON jps.job_id = sjd.job_id
    WHERE 
        jps.job_title_short = 'Data Analyst'
    GROUP BY sjd.skill_id
    ORDER BY skills_count DESC
)
SELECT 
    ts.skill_id,
    sd.skills,
    ts.skills_count
FROM top_skills ts
JOIN skills_dim sd
ON ts.skill_id = sd.skill_id
GROUP BY sd.skills, ts.skill_id, ts.skills_count
ORDER BY ts.skills_count DESC
LIMIT 5;

-- Without using CTEs
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
GROUP BY sd.skill_id, sd.skills
ORDER BY demand_skills_count DESC
LIMIT 5;

