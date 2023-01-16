-- SQL SESSION 2 : AGGREGATE FUNCTIONS and GROUPBY - 12.01.2023

--- COUNT: it counts the number of records
-- * can be used with only one agg function: COUNT
-- * if we use count with *, it also included NULLS, if we don't want the nulls to be counted, then
-- we should use Count with a specific column name.

/* Order of operations:
    
    1. FROM
    2. JOIN .... ON
    3. WHERE
    4. Group by
    5. HAVING
    6. SELECT
    7. DISTINCT
    8. ORDER BY
    9. TOP N
*/



-- howa many products are there in total?
SELECT COUNT(product_id) as total_products 
FROM product.product;

SELECT COUNT(*) as total_products 
FROM product.product;

-- null values
SELECT COUNT(phone) as phone_number
-- this doesn't count the nulls
FROM sale.customer;

SELECT COUNT(*)
-- this counts all the rows regardless of null or str or numeric values
FROM sale.customer;

-- if we want to count the number of null values in phone field.
SELECT COUNT(*) as phone_nulls
FROM sale.customer
WHERE phone IS NULL;

SELECT COUNT(phone)
-- ama bu 0 döndürür. sütun bazında sadece null olmayanları sayar cunku
FROM sale.customer
WHERE phone IS NULL;

-- How many customers are located in NY state?
SELECT COUNT(customer_id) as number_of_customers
FROM sale.customer
WHERE state= 'NY';

--- COUNT DISTINCT: it counts only the uniques.

SELECT COUNT(DISTINCT city) 
FROM sale.customer;
---- 2000 row icinde 48 unique sehir varmis

--- MIN Function
SELECT MIN(model_year) as newest_model,
MAX(model_year) as oldest_model 
FROM product.product;

-- what are the min and max list_prices in category 5
SELECT MIN(list_price) as min_price,
MAX(list_price) as max_price
FROM product.product
WHERE category_id = 5;

SELECT TOP 1 list_price as max_price
FROM product.product
WHERE category_id = 5
ORDER BY list_price DESC;

--- SUM Function: just for numeric fields. It doesn't include null values

-- total price of the products in category 6
SELECT SUM(list_price) as total_price
FROM product.product
Where category_id = 6;

-- how many product sold in order_id 45?
SELECT SUM(quantity) as total_sale
FROM sale.order_item
Where order_id = 45;

--- AVG FUnction: just for numeric fields... without null values
--- AVG ve SUM fonksiyonları int ile calisinca sonuc yine integer gelir.

-- what is the avg list price of the 2020 model products?
SELECT AVG(list_price) as avg_price
FROM product.product
WHERE model_year = 2020;

-- find the average order quantity for product 130.
SELECT AVG(quantity) as avg_quantity
FROM sale.order_item
Where product_id = 130;
-- aslında 4 sipariste toplam quantity 5, ama avg bize 1 verdi. int girdi int cikti.

-- bunu 1.25 getirmek icin float 1 ile carpabiliriz:
SELECT AVG(quantity*1.0) as avg_quantity
FROM sale.order_item
Where product_id = 130;


/*
WHERE’i Aggregate fonksiyonundan önce çalıştırır ki önce sınırlayıp, sınırlanmış veriye fonksiyon işlemi uygulansın. Böylece sistemi yormamış oluyor.
GROUP BY da WHERE’den sonra çalıştırılıyor. Aynı nedenden dolayı.
*/
---------------------------------------------------------------------
--- GROUP BY FUNCTION
--- returns only one result per group of data
-- always follows the WHERE clause
-- always precedes ORDER BY

-- group by > selecti kapsamalı. selectte olan groupby da olmalı. ama GB'da fazlası da olabilir
-- GROUP BY with COUNT function

SELECT DISTINCT model_year
FROM product.product;

-- bu yukardaki ve hemen asagidaki ayni zaten.
SELECT model_year
FROM product.product
GROUP BY model_year;

-- bu nedenle group by agg functionlar ile kullanılmalı

-- GROUP BY with COUNT

-- How many products are there in each model year?
SELECT model_year, COUNT(product_id)
FROM product.product
GROUP BY model_year;

-- Write a query that returns the number of products priced over $1000 by brands
SELECT brand_id, COUNT(product_id) luxury_products
FROM product.product
WHERE list_price > 1000
GROUP BY brand_id
ORDER BY luxury_products DESC;

-- COUNT DISTINCT
-- bir markanın kac farklı kategoride ürünü olduğunu gormek icin
SELECT brand_id, COUNT(DISTINCT category_id)
-- distinctsiz hali 520 satiri kategorilere ayırır. ama unique 16 kategori var, uniqueler icin distinct
FROM product.product
GROUP BY brand_id;

-- GROUP BY with MIN&MAX Functions

-- Find the first and last purchase dates for each customer
SELECT customer_id, 
    MIN(order_date) earliest_date,
    MAX(order_date) last_date
FROM sale.orders
GROUP BY customer_id;

-- Find min and max product prices of each brand.
SELECT brand_id, 
    MIN(list_price) as min_price,
    MAX(list_price) as max_price
FROM product.product
GROUP BY brand_id;    

--- GROUP BY with SUM and AVG Functions

-- find the total discount amount of each order

SELECT *
FROM sale.order_item;

SELECT order_id, 
    SUM(quantity * list_price * discount) as total_discount
FROM sale.order_item
GROUP BY order_id;

-- sadece birini almak istesek ornegin
SELECT order_id, list_price*2 as priceXquantity, 
    SUM(quantity * list_price * (1 - discount)) as total_paid,
    discount,
    SUM(quantity * list_price * discount) as total_discount
FROM sale.order_item
WHERE order_id = 1 AND product_id = 8
GROUP BY order_id, list_price, discount;

-- What is the average list price for each model year?

SELECT model_year, AVG(list_price) as avg_price
FROM product.product
GROUP BY model_year;


--------------------------------------------------------------------------

-- Interview Question 1
-- Write a query that returns the most repeated name in the customer table.
SELECT TOP 1 first_name, COUNT(first_name) as most_repeated_names
FROM sale.customer
GROUP BY first_name
ORDER BY most_repeated_names DESC;

-- Interview Question 2
-- Find the state where "yandex" is used the most? (with number of users)
SELECT TOP 1 state, COUNT(*) as most_yandex_user
FROM sale.customer
WHERE email LIKE '%@yandex%'
GROUP BY state
ORDER BY COUNT(*) DESC;