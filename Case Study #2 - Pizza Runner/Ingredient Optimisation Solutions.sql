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



-- Generate an order item for each record in the customers_orders table in the format of one of the following:
--    Meat Lovers
--    Meat Lovers - Exclude Beef
--    Meat Lovers - Extra Bacon
--    Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers:

-- Assign a row number as ther is no column uniquely identifying each row in the customer_orders table
with pk_cte as (
  SELECT
    row_number() over () as row_nbr,
    * 
  from customer_orders
)

-- Convert comma separated extras and exclusions into separate rows
, unnest_cte as (
  select 
    row_nbr
    , pizza_name
    , unnest(case 
             when extras is not null and  extras!='null' and extras!='' then string_to_array(extras,',') 
             else (array[null])::text[]  end) as extras
    , unnest(case
              when exclusions is not null and  exclusions!='null' and exclusions!='' then string_to_array(exclusions,',') 
              else (array[null])::text[]  end) as exclusions 
  from pk_cte orders
  left join pizza_names pnames on orders.pizza_id = pnames.pizza_id
 )

-- Lookup the extras and exclusions id for their actual names. Prepare different concat statements depending on the order 
select 
  case 
    when string_agg(top1.topping_name::text, '') is null and string_agg(top2.topping_name::text, '') is null then string_agg(pizza_name::text, ' ')
    when string_agg(top1.topping_name::text, '') is not null and string_agg(top2.topping_name::text, '') is null then concat(string_agg(pizza_name::text, ' '),' - Extra ',string_agg(top1.topping_name::text, ','))
    when string_agg(top1.topping_name::text, '') is null and string_agg(top2.topping_name::text, '') is not null then concat(string_agg(pizza_name::text, ' '),' - Exclude ',string_agg(top2.topping_name::text, ','))
    when string_agg(top1.topping_name::text, '') is not null and string_agg(top2.topping_name::text, '') is not null then concat(string_agg(pizza_name::text, ' '),' - Extra ',string_agg(top1.topping_name::text, ','), ' - Exclude ',string_agg(top2.topping_name::text, ','))
  end as order_item
from unnest_cte u
left join pizza_toppings top1 on cast(u.extras as int) = top1.topping_id
left join pizza_toppings top2 on cast(u.exclusions as int) = top2.topping_id
group by row_nbr
order by row_nbr;
                                                                                                                

    
-- Output

--| order_item                                                               |
--| ------------------------------------------------------------------------ |
--| Meatlovers                                                               |
--| Meatlovers                                                               |
--| Meatlovers                                                               |
--| Vegetarian                                                               |
--| Meatlovers - Exclude Cheese                                              |
--| Meatlovers - Exclude Cheese                                              |
--| Vegetarian - Exclude Cheese                                              |
--| Meatlovers - Extra Bacon                                                 |
--| Vegetarian                                                               |
--| Vegetarian - Extra Bacon                                                 |
--| Meatlovers                                                               |
--| Meatlovers Meatlovers - Extra Bacon,Chicken - Exclude Cheese             |
--| Meatlovers                                                               |
--| Meatlovers Meatlovers - Extra Bacon,Cheese - Exclude BBQ Sauce,Mushrooms |









