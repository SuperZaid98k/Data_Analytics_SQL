-- Retrieve the total number of orders placed. 
SELECT 
    COUNT(*) AS Total_Orders
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.

SELECT 
    round(SUM(order_details.quantity * pizzas.price),2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- Identify the highest-priced pizza.

select max(price) from pizzas;

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC limit 1;


-- Identify the most common pizza size ordered.
-- select (pizzas.size) from pizzas join order_details on pizzas.pizza_id = order_details.pizza_id;
SELECT 
    pizzas.size, COUNT(order_details.order_details_id)
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size;



-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, sum(order_details.quantity) AS count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.name
ORDER BY count DESC
LIMIT 5;




-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category, SUM(order_details.quantity) AS count
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category
ORDER BY count DESC;



-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(time) AS hour, COUNT(order_id) AS count
FROM
    orders
GROUP BY HOUR(time);



-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS count
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizzas
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS quantity_table;
    
    
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;



-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.name,
    SUM((pizzas.price * order_details.quantity) / (SELECT 
            SUM(order_details.quantity * pizzas.price)
        FROM
            order_details
                JOIN
            pizzas ON order_details.pizza_id = pizzas.pizza_id
                JOIN
            pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id) * 100) AS revenue
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY revenue DESC;


-- Total revenue Sub-Query
-- SELECT 
--     SUM(order_details.quantity * pizzas.price)
-- FROM
--     order_details
--         JOIN
--     pizzas ON order_details.pizza_id = pizzas.pizza_id
--         JOIN
--     pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id;



-- Analyze the cumulative revenue generated over time.


select ordate,sum(revenue) over(order by date) as cum_revenue from
(SELECT 
    orders.date,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY orders.date) as rev_by_date;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select 
category,pizzas_rank,name,revenue
from 
(select 
category,name,revenue,
rank() over(partition by category order by revenue desc) as pizzas_rank 
from
(select 
pizza_types.category,
pizza_types.name,
sum(pizzas.price*order_details.quantity) as revenue 
from 
pizzas 
join 
pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id 
join 
order_details on order_details.pizza_id = pizzas.pizza_id 
group by pizza_types.category,pizza_types.name) as firdt_table) as b
where pizzas_rank <=3;