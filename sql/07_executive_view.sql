-- olist-ecommerce-sql-analysis | Q7 Executive dashboard view
-- MySQL 8

-- Q7a: create or replace view vw_executive_dashboard (flat table of delivered order items for BI tools)
create or replace view vw_executive_dashboard as
select o.order_id,
       oi.order_item_id,
       date(o.order_purchase_timestamp)                         as order_date,
       year(o.order_purchase_timestamp)                         as order_year,
       date_format(o.order_purchase_timestamp, '%Y-%m')         as order_month,
       c.customer_unique_id,
       c.customer_state,
       c.customer_city,
       oi.product_id,
       coalesce(t.product_category_name_english, p.product_category_name, 'unknown') as product_category,
       oi.seller_id,
       oi.price,
       oi.freight_value,
       oi.price + oi.freight_value                              as item_total,
       datediff(o.order_delivered_customer_date, o.order_purchase_timestamp) as delivery_days,
       case when date(o.order_delivered_customer_date) > date(o.order_estimated_delivery_date)
            then 1 else 0 end                                   as is_late
from orders o
join order_items oi on oi.order_id = o.order_id
join customers c on c.customer_id = o.customer_id
left join products p on p.product_id = oi.product_id
left join product_category_name_translation t on t.product_category_name = p.product_category_name
where o.order_status = 'delivered'
  and o.order_delivered_customer_date is not null;

select * from vw_executive_dashboard limit 10;
