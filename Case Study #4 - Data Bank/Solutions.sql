
--- A. Customer Nodes Exploration
-- How many unique nodes are there on the Data Bank system?
--**Schema (PostgreSQL v13)**

SELECT 
  COUNT(DISTINCT node_id) AS distinct_nodes 
FROM data_bank.customer_nodes;

-- Output 
--| distinct_nodes |
--| -------------- |
--| 5              |


-- What is the number of nodes per region?
-- The question does not specify if they need unique nodes. However, if we are interested in the number of nodes per region, then unique makes sense. 
-- Else, they would have just asked for number of customers per region

-- **Schema (PostgreSQL v13)**

SELECT 
  region_id
  , COUNT( DISTINCT node_id) AS nodes_no
FROM data_bank.customer_nodes
GROUP BY region_id;

-- Output 
--| region_id | nodes_no |
--| --------- | -------- |
--| 1         | 5        |
--| 2         | 5        |
--| 3         | 5        |
--| 4         | 5        |
--| 5         | 5        |


-- How many customers are allocated to each region?

SELECT 
  region_id
  , COUNT( DISTINCT customer_id) AS "#customer"
FROM data_bank.customer_nodes
GROUP BY region_id;

-- Output 
--| region_id | #customer |
--| --------- | --------- |
--| 1         | 110       |
--| 2         | 105       |
--| 3         | 102       |
--| 4         | 95        |
--| 5         | 88        |


-- How many days on average are customers reallocated to a different node?

SELECT 
  ROUND(AVG(end_date- start_date),2) AS avg_days
FROM data_bank.customer_nodes
WHERE end_date!=CAST('9999-12-31' AS date);

-- Output
--| avg_days |
--| -------- |
--| 14.63    |


--What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

WITH days_cte AS (
  SELECT 
    ROUND((end_date- start_date),2) AS days_diff
  FROM data_bank.customer_nodes
  WHERE end_date!=CAST('9999-12-31' AS date)
    )
    
SELECT 
  PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY days_diff ASC) AS percentile_50
  , PERCENTILE_CONT(0.80) WITHIN GROUP (ORDER BY days_diff ASC) AS percentile_80
  , PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY days_diff ASC) AS percentile_95
FROM days_cte;
    
-- Output

--| percentile_50 | percentile_80 | percentile_95 |
--| ------------- | ------------- | ------------- |
--| 15            | 23            | 28            |






