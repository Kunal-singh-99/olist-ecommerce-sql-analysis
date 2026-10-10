-- olist-ecommerce-sql-analysis | Q4 RFM segmentation
-- MySQL 8

-- Q4a: per customer_unique_id -> recency_days, frequency, monetary, then R/F/M scores (1-4)
with order_totals as (
    select order_id, sum(payment_value) as order_value
    from order_payments
    group by order_id
),
customer_base as (
    select c.customer_unique_id,
           max(o.order_purchase_timestamp) as last_order_date,
           count(distinct o.order_id)      as frequency,
           sum(ot.order_value)             as monetary
    from orders o
    join customers c on c.customer_id = o.customer_id
    join order_totals ot on ot.order_id = o.order_id
    where o.order_status not in ('canceled', 'unavailable')
    group by c.customer_unique_id
),
rfm as (
    select customer_unique_id,
           datediff((select max(last_order_date) from customer_base), last_order_date) as recency_days,
           frequency,
           round(monetary, 2) as monetary
    from customer_base
),
scored as (
    select *,
           ntile(4) over (order by recency_days desc) as r_score,
           case when frequency = 1 then 1
                when frequency = 2 then 2
                when frequency = 3 then 3
                else 4 end as f_score,
           ntile(4) over (order by monetary) as m_score
    from rfm
)
select * from scored
order by r_score desc, m_score desc
limit 10;

-- Q4b: classify into segments (VIPs, Loyal Repeat Buyers, New High-Value, New Customers, Churn Risks (High Value), Lost, Occasional) and count / revenue per segment
with order_totals as (
    select order_id, sum(payment_value) as order_value
    from order_payments
    group by order_id
),
customer_base as (
    select c.customer_unique_id,
           max(o.order_purchase_timestamp) as last_order_date,
           count(distinct o.order_id)      as frequency,
           sum(ot.order_value)             as monetary
    from orders o
    join customers c on c.customer_id = o.customer_id
    join order_totals ot on ot.order_id = o.order_id
    where o.order_status not in ('canceled', 'unavailable')
    group by c.customer_unique_id
),
rfm as (
    select customer_unique_id,
           datediff((select max(last_order_date) from customer_base), last_order_date) as recency_days,
           frequency,
           round(monetary, 2) as monetary
    from customer_base
),
scored as (
    select *,
           ntile(4) over (order by recency_days desc) as r_score,
           case when frequency = 1 then 1
                when frequency = 2 then 2
                when frequency = 3 then 3
                else 4 end as f_score,
           ntile(4) over (order by monetary) as m_score
    from rfm
)
select segment,
       count(*) as customers,
       round(100.0 * count(*) / sum(count(*)) over (), 2) as pct_of_customers,
       round(sum(monetary), 0) as total_revenue,
       round(100.0 * sum(monetary) / sum(sum(monetary)) over (), 2) as pct_of_revenue,
       round(avg(monetary), 2) as avg_spend
from (
    select *,
           case when f_score >= 2 and r_score >= 3 and m_score >= 3 then 'VIPs'
                when f_score >= 2 then 'Loyal Repeat Buyers'
                when r_score = 4 and m_score >= 3 then 'New High-Value'
                when r_score = 4 then 'New Customers'
                when r_score = 1 and m_score >= 3 then 'Churn Risks (High Value)'
                when r_score = 1 then 'Lost'
                else 'Occasional' end as segment
    from scored
) t
group by segment
order by total_revenue desc;
