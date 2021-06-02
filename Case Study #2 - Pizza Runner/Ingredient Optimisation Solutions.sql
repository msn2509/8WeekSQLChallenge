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




-- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--  For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

with pk_cte as (
  SELECT
    row_number() over () as row_nbr
    , * 
  from customer_orders)

, topping_total as (
  select 
    row_nbr
    , pk.pizza_id
    ,unnest(string_to_array(toppings,',') ) as toppings
  from pk_cte pk
  left join pizza_recipes r on pk.pizza_id = r.pizza_id

  union all

  select 
    row_nbr
    , pizza_id
    ,unnest(case 
              when extras is not null and  extras!='null' and extras!='' then string_to_array(extras,',') 
              else (array[null])::text[]  end) as extras
  from pk_cte 

  union all 
  select 
    row_nbr
    , pizza_id
    , unnest(case 
             when exclusions is not null and  exclusions!='null' and exclusions!='' then string_to_array(exclusions,',') 
             else (array[null])::text[]  end) as exclusions
  from pk_cte
)
, desc_finder as (
  select 
    row_nbr
    , pizza_id
    , toppings
    , topping_name
    , count(*) as x_factor 
  from topping_total t
  left join pizza_toppings top on cast(t.toppings as int) = top.topping_id           
  group by row_nbr, toppings, topping_name, pizza_id
),
            
final_data as (            
  select 
    row_nbr
    , pizza_name
    ,toppings
    , case 
      when cast(string_agg(x_factor::text, '') as int) > 1 and toppings is not null then concat(string_agg(x_factor::text, ''),'x',string_agg(topping_name::text, ',')) 
      else string_agg(topping_name::text, '') end as final_toppings
  from desc_finder des
  left join  pizza_names pnames on des.pizza_id = pnames.pizza_id                                           
  group by row_nbr, pizza_name, toppings        
 )

select 
  concat(pizza_name,' : ',string_agg(final_toppings::text, ','))  as ingredients_list                                       
from final_data 
group by row_nbr, pizza_name


--Output

--| ingredients_list                                                                            |
--| ------------------------------------------------------------------------------------------- |
--| Meatlovers : Salami,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Bacon                 |
--| Meatlovers : Salami,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Bacon                 |
--| Meatlovers : Salami,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Bacon                 |
--| Vegetarian : Tomatoes,Tomato Sauce,Mushrooms,Onions,Peppers,Cheese                          |
--| Meatlovers : Salami,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Bacon,Cheese          |
--| Meatlovers : Salami,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Bacon,Cheese          |
--| Vegetarian : Tomatoes,Tomato Sauce,Mushrooms,Onions,Peppers,2xCheese                        |
--| Meatlovers : Salami,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,2xBacon               |
--| Vegetarian : Tomatoes,Tomato Sauce,Mushrooms,Onions,Peppers,Cheese                          |
--| Vegetarian : Tomatoes,Tomato Sauce,Mushrooms,Onions,Peppers,Bacon,Cheese                    |
--| Meatlovers : Salami,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Bacon                 |
--| Meatlovers : Salami,BBQ Sauce,Beef,Cheese,2xChicken,Mushrooms,Pepperoni,2xBacon,Cheese      |
--| Meatlovers : Salami,BBQ Sauce,Beef,Cheese,Chicken,Mushrooms,Pepperoni,Bacon                 |
--| Meatlovers : Salami,BBQ Sauce,Beef,2xCheese,Chicken,2xMushrooms,Pepperoni,2xBacon,BBQ Sauce |


            
            







