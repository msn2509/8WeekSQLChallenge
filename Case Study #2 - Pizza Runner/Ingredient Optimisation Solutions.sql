-- What are the standard ingredients for each pizza?

select 
  pizza_id 
  , topping_name 
from 
(
  select 
    pizza_id
    , unnest(string_to_array(toppings, ',')) as topping
  from pizza_recipes 
 ) p 
left join pizza_toppings t on cast(p.topping as int) = t.topping_id
order by pizza_id

--Output

--| pizza_id | topping_name |
--| -------- | ------------ |
--| 1        | BBQ Sauce    |
--| 1        | Pepperoni    |
--| 1        | Cheese       |
--| 1        | Salami       |
--| 1        | Chicken      |
--| 1        | Bacon        |
--| 1        | Mushrooms    |
--| 1        | Beef         |
--| 2        | Tomato Sauce |
--| 2        | Cheese       |
--| 2        | Mushrooms    |
--| 2        | Onions       |
--| 2        | Peppers      |
--| 2        | Tomatoes     |


-- What was the most commonly added extra?

with extra_cte as (
  select 
    unnest(string_to_array(extras, ',') ) as extras
    ,count(*) as count_extras
  from customer_orders
  where extras is not null and  extras!='null' and extras!=''
  group by unnest(string_to_array(extras, ',') )
)
 
select 
  topping_name as most_common_extra 
from (
  select *
    ,rank() over (order by count_extras desc) as order_extra
  from extra_cte cte 
  left join pizza_toppings t on cast(cte.extras as int) = t.topping_id
)a 
where order_extra=1

--Output

--| most_common_extra |
--| ----------------- |
--| Bacon             |


-- What was the most common exclusion?

with exclusions_cte as (
  select 
    unnest(string_to_array(exclusions, ',') ) as exclusions
    ,count(*) as count_exclusions
  from customer_orders
  where exclusions is not null and  exclusions!='null' and exclusions!=''
  group by unnest(string_to_array(exclusions, ',') )
  )
 
 select 
    topping_name as most_common_exclusions 
 from (
   select *
    , rank() over (order by count_exclusions desc) as order_exclusions
   from exclusions_cte cte 
   left join pizza_toppings t on cast(cte.exclusions as int) = t.topping_id
   )a 
where order_exclusions=1

-- Output

--| most_common_exclusions |
--| ---------------------- |
--| Cheese                 |











