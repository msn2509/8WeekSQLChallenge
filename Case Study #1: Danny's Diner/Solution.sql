-- 1. What is the total amount each customer spent at the restaurant?


select 
	customer_id,
	sum(price) as cust_spending
from sales s
left join menu m on s.product_id = m.product_id
group by customer_id;

	
-- Output

--| customer_id | cust_spending |
--| ----------- | ------------- |
--| B           | 74            |
--| C           | 36            |
--| A           | 76            |


-- 2. How many days has each customer visited the restaurant?
select 
	customer_id,
	count(distinct order_date) as no_days
from sales
group by customer_id;

--Output

--| customer_id | no_days |
--| ----------- | ------- |
--| A           | 4       |
--| B           | 6       |
--| C           | 2       |



-- 3. What was the first item from the menu purchased by each customer?
select 
	distinct customer_id,
	product_name as first_product
from(
	select 
		customer_id,
		rank() over (partition by customer_id order by  order_date) as rank_order,
		product_name
	from sales s
	left join menu m on s.product_id = m.product_id
 )s
 where rank_order=1;
 

-- Output 
--| customer_id | first_product |
--| ----------- | ------------- |
--| A           | curry         |
--| A           | sushi         |
--| B           | curry         |
--| C           | ramen         |



-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

-- Note: I could have just printed the most purchased item and a cumulative purchase by all customers, but wanted to showcase how many times each customer purchased the item in question. This gives us an overview of the distribution of the purchased item, was it uniform or skewed just due to a few customers. 


select 
	product_name as most_purchased_item
	, customer_id
	, count(customer_id) as times_purchased
from sales s
left join menu m on m.product_id = s.product_id
where s.product_id in (
	select
		product_id
	from sales
	group by product_id
	order by count(customer_id) desc
	limit 1)
group by s.product_id, product_name, customer_id ;


-- Output

--| most_purchased_item | customer_id | times_purchased |
--| ------------------- | ----------- | --------------- |
--| ramen               | C           | 3               |
--| ramen               | A           | 3               |
--| ramen               | B           | 2               |




-- 5. Which item was the most popular for each customer?

with rank_product_cte as (
	select
		customer_id,
		product_name as most_popular_item,
		rank() over (partition by customer_id order by freq desc) as rank_product
	from (
		select 
			customer_id
			, product_id
			, count(product_id) as freq
		from sales
		group by customer_id, product_id
	)a
	left join menu p on a.product_id=p.product_id
  )

select 
	customer_id
	,most_popular_item 
from rank_product_cte 
where rank_product=1;

-- Output

--| customer_id | most_popular_item |
--| ----------- | ----------------- |
--| A           | ramen             |
--| B           | curry             |
--| B           | sushi             |
--| B           | ramen             |
--| C           | ramen             |



-- 6. Which item was purchased first by the customer after they became a member? - Do we consider on the day orders. A customer can eat and then become a member too.
select
	customer_id as member
    , product_name as first_item
from (
	select
		s.customer_id
		, order_date
		, product_id
		, rank() over (partition by s.customer_id order by order_date) as rank_order
	from sales s
	left join members m on s.customer_id = m.customer_id
	where order_date>join_date
 ) a
left join menu m on a.product_id = m.product_id
where rank_order=1;


--Output

--| member | first_item |
--| ------ | ---------- |
--| B      | sushi      |
--| A      | ramen      |



-- 7. Which item was purchased just before the customer became a member?
select
	customer_id as member
    , product_name as first_item
from (
	select
		s.customer_id
		, order_date
		, product_id
		, rank() over (partition by s.customer_id order by order_date desc) as rank_order
	from sales s
	left join members m on s.customer_id = m.customer_id
	where order_date<=join_date
 ) a
left join menu m on a.product_id = m.product_id
where rank_order=1;


--Output

--| member | first_item |
--| ------ | ---------- |
--| B      | sushi      |
--| A      | curry      |



-- 8. What is the total items and amount spent for each member before they became a member?


select
	s.customer_id
	, count(s.product_id) as total_items
	, sum(price) as amount_spent
from sales s
left join members me on s.customer_id = me.customer_id
left join menu m on s.product_id = m.product_id
where order_date < join_date
group by s.customer_id;


--Output

--| customer_id | total_items | amount_spent |
--| ----------- | ----------- | ------------ |
--| B           | 3           | 40           |
--| A           | 2           | 25           |



-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select
	customer_id,
	sum(case 
		when product_name ='sushi' then price*20 
		else price*10 end) as points
from sales s
left join menu m on s.product_id = m.product_id
group by customer_id;

-- Output

--| customer_id | points |
--| ----------- | ------ |
--| B           | 940    |
--| C           | 360    |
--| A           | 860    |



-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

select
	s.customer_id,
	sum(case 
		when product_name ='sushi' or order_date between join_date and join_date+7 then price*20 
		else price*10 end
	) as points
from sales s
left join menu m on s.product_id = m.product_id
left join members me on s.customer_id = me.customer_id
where s.customer_id in ('A', 'B') and order_date<='2021-01-31'
group by s.customer_id

--Output

--| customer_id | points |
--| ----------- | ------ |
--| A           | 1370   |
--| B           | 940    |



-- Bonus Questions: Creatng views
--The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

select 
	s.customer_id
    , s.order_date
    , m.product_name
    , m.price
    , case when me.customer_id is not null and s.order_date>=me.join_date then 'Y' else 'N' end as member
from sales s 
left join menu m on s.product_id = m.product_id 
left join members me on s.customer_id = me.customer_id 
order by s.customer_id, s.order_date;

--Output

--| customer_id | order_date | product_name | price | member |
--| ----------- | ---------- | ------------ | ----- | ------ |
--| A           | 2021-01-01 | sushi        | 10    | N      |
--| A           | 2021-01-01 | curry        | 15    | N      |
--| A           | 2021-01-07 | curry        | 15    | Y      |
--| A           | 2021-01-10 | ramen        | 12    | Y      |
--| A           | 2021-01-11 | ramen        | 12    | Y      |
--| A           | 2021-01-11 | ramen        | 12    | Y      |
--| B           | 2021-01-01 | curry        | 15    | N      |
--| B           | 2021-01-02 | curry        | 15    | N      |
--| B           | 2021-01-04 | sushi        | 10    | N      |
--| B           | 2021-01-11 | sushi        | 10    | Y      |
--| B           | 2021-01-16 | ramen        | 12    | Y      |
--| B           | 2021-02-01 | ramen        | 12    | Y      |
--| C           | 2021-01-01 | ramen        | 12    | N      |
--| C           | 2021-01-01 | ramen        | 12    | N      |
--| C           | 2021-01-07 | ramen        | 12    | N      |


--Danny also requires further information about the ranking of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

with main_view as 
(select 
	s.customer_id
    , s.order_date
    , m.product_name
    , m.price
    , case 
		when me.customer_id is not null and s.order_date>=me.join_date then 'Y' 
		else 'N' end as member
from sales s 
left join menu m on s.product_id = m.product_id 
left join members me on s.customer_id = me.customer_id 
order by s.customer_id, s.order_date
) 

select 
	customer_id
	,order_date
	,product_name
	, price
	, member
	, null as ranking  
from main_view 
where member='N'

union all

select 
	customer_id
	,order_date
	,product_name
	, price
	, member
	,  rank() over (partition by customer_id order by order_date, price) as ranking  
from main_view 
where member='Y'
order by customer_id


--Output

--| customer_id | order_date               | product_name | price | member | ranking |
--| ----------- | ------------------------ | ------------ | ----- | ------ | ------- |
--| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | N      |         |
--| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |         |
--| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | Y      | 1       |
--| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | Y      | 2       |
--| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      | 3       |
--| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | Y      | 3       |
--| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | Y      | 1       |
--| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | Y      | 2       |
--| B           | 2021-02-01T00:00:00.000Z | ramen        | 12    | Y      | 3       |
--| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | N      |         |
--| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | N      |         |
--| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | N      |         |
--| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |         |
--| C           | 2021-01-01T00:00:00.000Z | ramen        | 12    | N      |         |
--| C           | 2021-01-07T00:00:00.000Z | ramen        | 12    | N      |         |

