
--Pizza Metrics
--How many pizzas were ordered?
select 
  count(pizza_id) as no_pizzas
from customer_orders

--Output
--| no_pizzas |
--| --------- |
--| 14        |


--How many unique customer orders were made?
select 
	count(distinct order_id) as unique_cust_orders
from customer_orders ;

--Output
--| unique_cust_orders |
--| ------------------ |
--| 10                 |


-- How many successful orders were delivered by each runner?
select
	runner_id
	, count(distinct order_id) as successful_orders
from runner_orders
where lower(cancellation) not like '%cancellation%' or cancellation is null
group by runner_id

--Output
--| runner_id | successful_orders |
--| --------- | ----------------- |
--| 1         | 4                 |
--| 2         | 3                 |
--| 3         | 1                 |


--How many of each type of pizza was delivered?
select
	pizza_id
	, count(*) as amount
from runner_orders run_ord 
left join customer_orders cust_ord on run_ord.order_id = cust_ord.order_id
where lower(cancellation) not like '%cancellation%' or cancellation is null
group by pizza_id
order by pizza_id

--Output

--| pizza_id | amount |
--| -------- | ------ |
--| 1        | 9      |
--| 2        | 3      |

