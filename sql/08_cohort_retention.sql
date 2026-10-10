-- olist-ecommerce-sql-analysis | Q8 Cohort retention
-- MySQL 8

-- Q8: monthly cohort retention (cohort month, cohort size, % returning in month +1, +2, +3)
with customer_months as (
    select c.customer_unique_id,
           date_format(o.order_purchase_timestamp, '%Y-%m-01') as order_month
    from orders o
    join customers c on c.customer_id = o.customer_id
    where o.order_status not in ('canceled', 'unavailable')
    group by c.customer_unique_id, date_format(o.order_purchase_timestamp, '%Y-%m-01')
),
cohorts as (
    select customer_unique_id, min(order_month) as cohort_month
    from customer_months
    group by customer_unique_id
),
activity as (
    select co.cohort_month,
           co.customer_unique_id,
           timestampdiff(month, co.cohort_month, cm.order_month) as month_number
    from cohorts co
    join customer_months cm on cm.customer_unique_id = co.customer_unique_id
)
select date_format(cohort_month, '%Y-%m') as cohort,
       count(distinct customer_unique_id) as cohort_size,
       round(100.0 * count(distinct case when month_number = 1 then customer_unique_id end) / count(distinct customer_unique_id), 2) as month_1_pct,
       round(100.0 * count(distinct case when month_number = 2 then customer_unique_id end) / count(distinct customer_unique_id), 2) as month_2_pct,
       round(100.0 * count(distinct case when month_number = 3 then customer_unique_id end) / count(distinct customer_unique_id), 2) as month_3_pct
from activity
where cohort_month between '2017-01-01' and '2018-05-01'
group by cohort_month
order by cohort_month;
