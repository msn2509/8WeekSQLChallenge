
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



--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select 
	customer_id
	, sum(change_flag) as pizza_with_changes
	, sum(case when change_flag=0 then 1 else 0 end ) as pizza_with_no_changes
from(
	select 
		customer_id, 
		pizza_id, 
		case when (exclusions not in ('', 'null') and exclusions is not NULL) or ( extras not in ('', 'null') and extras is not NULL) then 1 else 0 end as change_flag
	from customer_orders 
  )a
group by customer_id
order by customer_id

--Output

--| customer_id | pizza_with_changes | pizza_with_no_changes |
--| ----------- | ------------------ | --------------------- |
--| 101         | 0                  | 3                     |
--| 102         | 0                  | 3                     |
--| 103         | 4                  | 0                     |
--| 104         | 2                  | 1                     |
--| 105         | 1                  | 0                     |


--How many pizzas were delivered that had both exclusions and extras?

select 
	customer_id
	,sum(change_flag) as pizza_with_changes
from(
	select 
		customer_id, 
		pizza_id, 
		case when (exclusions not in ('', 'null') and exclusions is not NULL) and ( extras not in ('', 'null') and extras is not NULL) then 1 else 0 end as change_flag
	from customer_orders 
  )a
  group by customer_id
  order by customer_id
  
--Output
--| customer_id | pizza_with_changes |
--| ----------- | ------------------ |
--| 101         | 0                  |
--| 102         | 0                  |
--| 103         | 1                  |
--| 104         | 1                  |
--| 105         | 0                  |


--What was the total volume of pizzas ordered for each hour of the day?

with hour_cte as 
(select 1 as hour 
 union 
 select 2 as hour
  union 
 select 3 as hour
  union 
 select 4 as hour
  union 
 select 5 as hour
  union 
 select 6 as hour
  union 
 select 7 as hour
  union 
 select 8 as hour
  union 
 select 9 as hour
  union 
 select 10 as hour
  union 
 select 11 as hour
  union 
 select 12 as hour
  union 
 select 13 as hour
  union 
 select 14 as hour
  union 
 select 15 as hour
  union 
 select 16 as hour
  union 
 select 17 as hour
  union 
 select 18 as hour union 
 select 19 as hour union 
 select 20 as hour
  union 
 select 21 as hour union 
 select 22 as hour union 
 select 23 as hour union 
 select 00 as hour
 )


select h.hour as hour, count(order_id)
 from hour_cte h
left join customer_orders cus on h.hour = date_part('hour',order_time)
group by h.hour
order by h.hour

--Output
--| hour | count |
--| ---- | ----- |
--| 0    | 0     |
--| 1    | 0     |
--| 2    | 0     |
--| 3    | 0     |
--| 4    | 0     |
--| 5    | 0     |
--| 6    | 0     |
--| 7    | 0     |
--| 8    | 0     |
--| 9    | 0     |
--| 10   | 0     |
--| 11   | 1     |
--| 12   | 0     |
--| 13   | 3     |
--| 14   | 0     |
--| 15   | 0     |
--| 16   | 0     |
--| 17   | 0     |
--| 18   | 3     |
--| 19   | 1     |
--| 20   | 0     |
--| 21   | 3     |
--| 22   | 0     |
--| 23   | 3     |


-- What was the volume of orders for each day of the week?
-- The day of the week starts from a monday as per the function below. 

with dow_cte as 
(select 1 as dow 
 union 
 select 2 as dow
  union 
 select 3 as dow
  union 
 select 4 as dow
  union 
 select 5 as dow
  union 
 select 6 as dow
  union 
 select 0 as dow)

select dow, count(order_id) as total_orders
from dow_cte d 
left join customer_orders cus on d.dow=extract('dow' from order_time)
group by dow
order by dow




