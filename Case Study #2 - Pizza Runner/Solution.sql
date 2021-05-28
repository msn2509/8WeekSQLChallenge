
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


--How many Vegetarian and Meatlovers were ordered by each customer?
select
	customer_id
	, pizza_name
	, count(*) as amount
from runner_orders run_ord 
left join customer_orders cust_ord on run_ord.order_id = cust_ord.order_id
left join pizza_names names on cust_ord.pizza_id = names.pizza_id
group by pizza_name, customer_id
order by customer_id, pizza_name

--Output

--| customer_id | pizza_name | amount |
--| ----------- | ---------- | ------ |
--| 101         | Meatlovers | 2      |
--| 101         | Vegetarian | 1      |
--| 102         | Meatlovers | 2      |
--| 102         | Vegetarian | 1      |
--| 103         | Meatlovers | 3      |
--| 103         | Vegetarian | 1      |
--| 104         | Meatlovers | 3      |
--| 105         | Vegetarian | 1      |



-- What was the maximum number of pizzas delivered in a single order?

select
	count(pizza_id) as no_pizza
from runner_orders run_ord
left join customer_orders cust_ord on run_ord.order_id = cust_ord.order_id
where lower(cancellation) not like '%cancellation%' or cancellation is null
group by run_ord.order_id
order by count(pizza_id) desc
limit 1

--Output 

--| no_pizza |
--| -------- |
--| 3        |


-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
