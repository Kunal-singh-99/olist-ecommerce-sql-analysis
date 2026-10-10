-- olist-ecommerce-sql-analysis | Row counts after loading
-- MySQL 8

-- row counts: quick sanity check after loading the CSVs
SELECT 'orders' AS tbl, COUNT(*) AS row_count FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'geolocation', COUNT(*) FROM geolocation;
