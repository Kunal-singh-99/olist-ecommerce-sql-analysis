-- olist-ecommerce-sql-analysis | Q3 Reviews vs delivery
-- MySQL 8

-- Q3a: average days from order_purchase_timestamp to order_delivered_customer_date, by review_score

select 
    round(avg(case when review_score = 5 then timestampdiff(DAY, order_purchase_timestamp, order_delivered_customer_date) else null end),2) as five_star_days,
    round(avg(case when review_score = 1 then timestampdiff(DAY, order_purchase_timestamp, order_delivered_customer_date) else null end),2) as one_star_days
from orders 
join order_reviews using(order_id);

-- Q3b: Pearson correlation between delivery_days and review_score

with delivery_data as (
    select timestampdiff(day, o.order_purchase_timestamp, o.order_delivered_customer_date) as x,
           r.review_score as y
    from orders o
    join order_reviews r using (order_id)
    where o.order_delivered_customer_date is not null
)
select round(
    (sum(x * y) - count(*) * avg(x) * avg(y)) /
    (sqrt(sum(x * x) - count(*) * power(avg(x), 2)) *
     sqrt(sum(y * y) - count(*) * power(avg(y), 2))), 4) as correlation
from delivery_data;

-- Q3c: average review score for late vs on-time delivered orders

select case when date(o.order_delivered_customer_date) > date(o.order_estimated_delivery_date)
            then 'late' else 'on_time' end as delivery_status,
       count(*) as reviews,
       round(avg(r.review_score), 2) as avg_review_score
from orders o
join order_reviews r using (order_id)
where o.order_status = 'delivered'
  and o.order_delivered_customer_date is not null
group by delivery_status;
