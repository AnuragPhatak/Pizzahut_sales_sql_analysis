create database pizzahut;
use pizzahut;

#1.Retrieve the total number of orders placed.
select count(order_id) from orders;

#2.Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;

#3.Identify the highest-priced pizza.
select name,price from pizza_types 
join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id
order by price desc limit 1
;

#4.Identify the most common pizza size ordered.
select size,count(quantity) from order_details 
join pizzas on
order_details.pizza_id = pizzas.pizza_id
group by size
;

#5.List the top 5 most ordered pizza types along with their quantities.
select name,sum(quantity) from pizza_types
join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by name
order by sum(quantity) desc limit 5;

#6.Join the necessary tables to find the total quantity of each pizza category ordered.
select category,sum(quantity) from pizza_types
join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by category;

#7.Determine the distribution of orders by hour of the day.
select hour(order_time),count(order_id) from orders
group by hour(order_time)
;

#8 Join relevant tables to find the category-wise distribution of pizzas
select category,count(name) from pizza_types
group by category;

#9 .Group the orders by date and calculate the average number of pizzas ordered per day.
select order_date,avg(quantity) from order_details
join orders on
order_details.order_id = orders.order_id
group by order_date ;

#10. Determine the top 3 most ordered pizza types based on revenue.
select name,sum((quantity*price)) as rev from pizza_types
join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by name
order by rev desc limit 3
;

#11Calculate the percentage contribution of each pizza type to total revenue.
select category,round((sum(quantity*price)/ (select sum(price*quantity) from pizza_types
join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
))*100,2) as per

 from pizza_types
join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by category
;

#12.Analyze the cumulative revenue generated over time.
select order_date , sum(rev) over(order by order_date) as cum_rev from 
(select order_date,sum(quantity*price) as rev from pizzas
join order_details
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by order_date
) as sales;

#13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select * from 
(
select name,category,sum(price*quantity),
rank() over(partition by category order by sum(price*quantity) desc) as ranking
from pizza_types
join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by name,category
) as t where ranking <= 3;
