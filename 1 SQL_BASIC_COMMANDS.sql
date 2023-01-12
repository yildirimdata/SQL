-- SQL SESSION-1, 11.01.2023, SQL BASIC COMMANDS

-- SELECT

SELECT 1;
SELECT 'Martin' as name;
SELECT 1 as ID, 'Martin' as name;
-- or
SELECT 1 as 'ID', 'Martin' as 'name';  -- as First Name error... For two words we should use [], or '' [First Name]

-- FROM table
SELECT TOP 5 *
-- * for all columns
FROM sale.customer;

-- to retrieve specific columns/fields
SELECT email, first_name AS f_name, last_name FROM sale.customer;

-- WHERE: to filter the data 
SELECT first_name, last_name, street, city, state
FROM sale.customer
WHERE city = 'Atlanta';

-- people who don't live in Atlanta: WHERE NOT
SELECT first_name, last_name, street, city, state
FROM sale.customer
WHERE NOT city = 'Atlanta';

-- we don't have retrieve the field that we filter with WHERE. We can also retrieve other ingo related to these rows
SELECT customer_id
FROM sale.customer
WHERE city = 'Atlanta';

-- AND / OR
-- only people who live in Allen, TX
SELECT first_name, last_name, street, city, state
FROM sale.customer
WHERE state = 'TX' AND city = 'Allen';

-- or: either TX or Allen
SELECT first_name, last_name, street, city, state
FROM sale.customer
WHERE state = 'TX' OR city = 'Allen';

-- AND - OR together
SELECT first_name, last_name, street, city, state
FROM sale.customer
WHERE last_name = 'Chan'AND state= 'TX' OR state = 'NY';
-- this retrieves all the people with chan last name who live in Texas and all other people in who live in NY

-- we have use ()
SELECT first_name, last_name, street, city, state
FROM sale.customer
WHERE last_name = 'Chan' AND (state= 'TX' OR state = 'NY');

-- IN / NOT IN
-- people from TX who live in Allen or Austin
SELECT first_name, last_name, street, city, state
FROM sale.customer
WHERE state= 'TX' AND city IN ('allen', 'austin');

-- WHERE state= 'TX' AND city NOT IN ('allen', 'austin'); people in Texas but not in Allen or Austin

-- LIKE OPERATOR
-- There are two main wildcards: 1. '-' match any single character 2. % for a ceratin number of characters
SELECT *
FROM sale.customer
-- we want people with yahoo email
WHERE email LIKE '%yahoo%';

-- '%abc' ends with abc - 'abc%' starts with abc - 'B%c' starts with B and ends with c
-- underscore _
SELECT *
FROM sale.customer
WHERE first_name LIKE 'Di_ne';

-- []
SELECT *
FROM sale.customer
-- t veya z ile baslasin nasıl bittigi onemli degil
WHERE first_name LIKE '[TZ]%';

SELECT *
FROM sale.customer
-- t, z veya bunların arasındaki harflerden biri ile baslasin nasıl bittigi onemli degil
WHERE first_name LIKE '[T-Z]%';

-- BETWEEN operator
-- products that cost between 599-999: NOTE: 599 and 999 are inclusive
SELECT *
FROM product.product
WHERE list_price BETWEEN 599 AND 999;

-- between with dates
SELECT *
FROM sale.orders
-- date should be written among quotes
WHERE order_date 
    BETWEEN '2018-01-05' 
        AND '2018-01-08';

-- <,>,<=, >=, =, <> !=
SELECT *
FROM product.product
WHERE list_price < 1000;

-- IS NULL / IS NOT NULL operators
SELECT *
FROM sale.customer
WHERE phone IS NULL;

SELECT *
FROM sale.customer
-- IS NOT NULL
WHERE phone IS NOT NULL;

-- TOP n... it's used within SELECT clause.. retrieve the first n rows
SELECT TOP 5 *
FROM sale.orders;

SELECT TOP 10 customer_id, state
FROM sale.customer
WHERE state= 'TX';

-- ORDER BY - default Ascending (ASC)
SELECT TOP 10 *
FROM sale.orders
ORDER BY order_id DESC; 

SELECT model_year, list_price
FROM product.product
-- SELECTTEki birinci ve ikinciyi alir rakamlar
ORDER BY 1 ASC, 2 DESC;

-- order yaptigimiz sutunu selectte getirmek zorunda degiliz
SELECT first_name, last_name, city, state
FROM sale.customer
ORDER BY customer_id DESC;

-- DISTINCT: unique() in pandas
-- how many unique states are there?
SELECT DISTINCT state 
FROM sale.customer;

-- distinct with two fields
SELECT DISTINCT state, city
-- uniquelik bu iki column arasında olacak. state tekrarlayablir ama sehirler bir tane olacak 
FROM sale.customer;


SELECT DISTINCT *  -- to detect the duplicate rows.
-- customer id herkes icin uniqu oldugundan tum satirlar doner, yani duplicate yok
FROM sale.customer;

SELECT phone
FROM sale.customer
WHERE phone IS NULL;

SELECT *
FROM sale.customer
WHERE [customer_id] IS NULL OR [phone] IS NULL OR [last_name] IS NULL;