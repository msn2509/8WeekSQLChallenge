
-- 1. How many unique users exist in the logs dataset?
SELECT
COUNT(user_id) as unique_users
FROM(
SELECT DISTINCT id as user_id
FROM health.user_logs
)a;

-- for questions 2-8 we created a temporary table
DROP TABLE IF EXISTS user_measure_count;
CREATE TEMP TABLE user_measure_count as 
SELECT
    id,
    COUNT(*) AS measure_count,
    COUNT(DISTINCT measure) as unique_measures
  FROM health.user_logs
  GROUP BY 1; 

-- 2. How many total measurements do we have per user on average?
SELECT
  ROUND(avg(measure_count))
FROM user_measure_count;

-- 3. What about the median number of measurements per user?
SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY measure_count) AS median_value
FROM user_measure_count;


-- 4. How many users have 3 or more measurements?
SELECT
  COUNT(id)
FROM user_measure_count
WHERE measure_count >= 3;


-- 5. How many users have 1,000 or more measurements?
SELECT
  count(id)
FROM user_measure_count
WHERE measure_count >= 1000;



-- 6. Have logged blood glucose measurements?
SELECT
  COUNT (DISTINCT id)
FROM health.user_logs
WHERE measure = 'blood_glucose';


-- 7. Have at least 2 types of measurements?
SELECT
  COUNT(*)
FROM user_measure_count
WHERE unique_measures >= 2;



-- 8. Have all 3 measures - blood glucose, weight and blood pressure?
SELECT
  COUNT(*)
FROM user_measure_count
WHERE unique_measures = 3;


-- 9.  What is the median systolic/diastolic blood pressure values?
SELECT
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY systolic) AS median_systolic,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY diastolic) AS median_diastolic
FROM health.user_logs
WHERE measure = 'blood_pressure';
  

  
  
 
