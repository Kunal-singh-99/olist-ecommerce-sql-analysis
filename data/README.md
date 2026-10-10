# Data

The CSV files are not committed to this repo (size and licence). Download them and place them in this folder.

| Source | Files used |
|---|---|
| [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) | `orders`, `order_items`, `order_payments`, `order_reviews`, `customers`, `products`, `sellers`, `geolocation`, `product_category_name_translation` |
| [Marketing Funnel by Olist](https://www.kaggle.com/datasets/olistbr/marketing-funnel-olist) | `leads_qualified`, `leads_closed` |

That is 11 tables in total. Import each CSV into a MySQL database named `olist`, using the file name as the table name (for example `orders.csv` becomes the table `orders`). MySQL Workbench's Table Data Import Wizard or `load data local infile` both work.

Check the licence on each Kaggle page before reusing the data.
