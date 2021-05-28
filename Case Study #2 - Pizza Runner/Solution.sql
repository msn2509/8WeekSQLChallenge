
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





