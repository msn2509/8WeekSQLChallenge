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
