
--If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
select 
  sum(case when pizza_name ='Meatlovers' then 12 
        when pizza_name = 'Vegetarian' then 10 
        else 0 end) as revenue
from runner_orders r 
left join customer_orders c on r.order_id = c.order_id
left join pizza_names n on c.pizza_id = n.pizza_id
where cancellation not like '%Cancellation%' or cancellation is null

-- Output 
--| revenue |
--| ------- |
--| 138     |



-- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
select 
  sum(case when pizza_name ='Meatlovers' then 12 
        when pizza_name = 'Vegetarian' then 10 
        else 0 end) +
sum(case when extras='null' then 0
      when array_length(string_to_array(extras, ','),1) is null then 0 
      else array_length(string_to_array(extras, ','),1) end) as extra_cost
from runner_orders r 
left join customer_orders c on r.order_id = c.order_id
left join pizza_names n on c.pizza_id = n.pizza_id
where cancellation not like '%Cancellation%' or cancellation is null

--Output

--| extra_cost |
--| ---------- |
--| 142        |


