-- olist-ecommerce-sql-analysis | Q6 Top sellers by category
-- MySQL 8

-- Q6: top 3 sellers per product category by revenue, only sellers with avg review score >= 4.0
with order_reviews_avg as (
    select order_id, avg(review_score) as review_score
    from order_reviews
    group by order_id
),
valid_items as (
    select oi.order_id, oi.seller_id, oi.price,
           coalesce(t.product_category_name_english, p.product_category_name) as category
    from order_items oi
    join orders o on o.order_id = oi.order_id
    join products p on p.product_id = oi.product_id
    left join product_category_name_translation t on t.product_category_name = p.product_category_name
    where o.order_status not in ('canceled', 'unavailable')
      and p.product_category_name is not null
),
seller_rating as (
    select s.seller_id, avg(r.review_score) as avg_review
    from (select distinct order_id, seller_id from valid_items) s
    join order_reviews_avg r on r.order_id = s.order_id
    group by s.seller_id
),
category_revenue as (
    select category, seller_id, sum(price) as revenue
    from valid_items
    group by category, seller_id
),
ranked as (
    select cr.category,
           cr.seller_id,
           round(cr.revenue, 2) as revenue,
           round(sr.avg_review, 2) as avg_review,
           dense_rank() over (partition by cr.category order by cr.revenue desc) as revenue_rank
    from category_revenue cr
    join seller_rating sr on sr.seller_id = cr.seller_id
    where sr.avg_review >= 4.0
)
select category, revenue_rank, seller_id, revenue, avg_review
from ranked
where revenue_rank <= 3
order by category, revenue_rank;
