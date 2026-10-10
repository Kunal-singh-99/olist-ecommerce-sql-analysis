-- olist-ecommerce-sql-analysis | Q1 Delivery SLA
-- MySQL 8

-- Q1a: overall % of delivered orders that arrived after order_estimated_delivery_date
SELECT round( sum(case when date_format(order_delivered_customer_date, '%Y-%m-%d') > date_format(order_estimated_delivery_date, '%Y-%m-%d') 
     and order_status = 'delivered' then 1 else 0 end) *100 /
        sum(case when order_status = 'delivered' then 1 else 0 end),
2) as late_order_percentage
from orders;

-- Q1b: late-delivery rate by customer state

select c.customer_state,
       count(*) AS delivered_orders,
       sum(DATE(o.order_delivered_customer_date) > DATE(o.order_estimated_delivery_date)) as late_orders,
       round(100.0 * sum(DATE(o.order_delivered_customer_date) > DATE(o.order_estimated_delivery_date)) / count(*), 2) as late_order_percentage
from orders o
join customers c 
on c.customer_id = o.customer_id
where o.order_status = 'delivered'
  and o.order_delivered_customer_date IS NOT NULL
group by c.customer_state
order by late_order_percentage DESC ,delivered_orders DESC;
