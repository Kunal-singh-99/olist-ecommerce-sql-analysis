-- olist-ecommerce-sql-analysis | Q2 Payment behaviour
-- MySQL 8

-- Q2a: average order value by payment type

select t.payment_type,
       count(*) AS orders,
       round(avg(o.order_total), 2) as avg_order_value
from (select DISTINCT order_id, payment_type FROM order_payments) t
join (select order_id, SUM(payment_value) as order_total
      from order_payments group by order_id) o ON o.order_id = t.order_id
where t.payment_type <> 'not_defined'
group by t.payment_type
order by avg_order_value DESC;

-- Q2b: average order value by installment bucket (credit card only)

select case WHEN inst = 1 THEN '1 (lump sum)'
            WHEN inst BETWEEN 2 AND 3 THEN '2-3'
            WHEN inst BETWEEN 4 AND 6 THEN '4-6'
            ELSE '7+' END AS installment_bucket,
       count(*) as orders,
       round(avg(order_total), 2) as avg_order_value
from (select order_id,
             max(payment_installments) as inst,
             sum(payment_value) as order_total
      from order_payments
      where payment_type = 'credit_card' and payment_installments >= 1
      group by order_id) t
group by installment_bucket
order by min(inst);
