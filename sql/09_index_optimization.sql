-- olist-ecommerce-sql-analysis | Q9 Index optimization
-- MySQL 8

-- re-running? drop the index first: drop index idx_reviews_order on order_reviews;

-- Q9b: explain analyze on the seller-performance query, before indexing
explain analyze
select oi.seller_id,
       count(*) as items_sold,
       round(sum(oi.price), 2) as revenue,
       round(avg(r.review_score), 2) as avg_review
from order_items oi
join order_reviews r on r.order_id = oi.order_id
where oi.seller_id = '4a3ca9315b744ce9f8e9374361493884'
group by oi.seller_id;

-- Q9c: index the join key order_reviews(order_id)
create index idx_reviews_order on order_reviews(order_id);

-- Q9d: explain analyze again, after indexing
explain analyze
select oi.seller_id,
       count(*) as items_sold,
       round(sum(oi.price), 2) as revenue,
       round(avg(r.review_score), 2) as avg_review
from order_items oi
join order_reviews r on r.order_id = oi.order_id
where oi.seller_id = '4a3ca9315b744ce9f8e9374361493884'
group by oi.seller_id;
