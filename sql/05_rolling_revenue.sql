-- olist-ecommerce-sql-analysis | Q5 Rolling revenue
-- MySQL 8

-- Q5: daily revenue + 7-day and 30-day rolling average (Jan 2017 - Aug 2018)
with recursive calendar as (
    select date('2017-01-05') as dt
    union all
    select dt + interval 1 day from calendar where dt < '2018-08-22'
),
order_totals as (
    select order_id, sum(payment_value) as order_value
    from order_payments
    group by order_id
),
daily_revenue as (
    select date(o.order_purchase_timestamp) as dt,
           sum(ot.order_value) as revenue
    from orders o
    join order_totals ot on ot.order_id = o.order_id
    where o.order_status not in ('canceled', 'unavailable')
    group by date(o.order_purchase_timestamp)
),
daily as (
    select c.dt, coalesce(d.revenue, 0) as revenue
    from calendar c
    left join daily_revenue d on d.dt = c.dt
),
rolling as (
    select dt,
           revenue,
           avg(revenue) over (order by dt rows between 6 preceding and current row)  as rolling_7d_avg,
           avg(revenue) over (order by dt rows between 29 preceding and current row) as rolling_30d_avg
    from daily
)
select dt,
       round(revenue, 2)         as daily_revenue,
       round(rolling_7d_avg, 2)  as rolling_7d_avg,
       round(rolling_30d_avg, 2) as rolling_30d_avg
from rolling
where dt >= '2017-02-03'   -- first day that has a full 30-day window
order by dt;
