-- STRING FUNCTION PRACTICES

-- Q1
-- List the product names in ascending order where the part from the beginning 
-- to the first space character is "Samsung" in the product_name column.
SELECT product_name
FROM product.product
WHERE SUBSTRING(product_name, 1, CHARINDEX(' ', product_name)) = 'Samsung'
ORDER BY product_name;

-- we can also solve this question with patindex function:
SELECT product_name
FROM product.product
WHERE PATINDEX('%Samsung %', product_name) = 1
ORDER BY product_name;

-- Q2
-- Write a query that returns streets in ascending order. The streets have an integer character 
-- lower than 5 after the "#" character end of the street. (use sale.customer table)

-- solution with len-right-convert functions
SELECT street 
FROM sale.customer
WHERE LEFT(RIGHT(street, 2),1) = '#' AND CONVERT(int, RIGHT(RIGHT(street, 2),1)) <5
ORDER BY street;

-- we can also solve this q with cast-len-charindex.
SELECT street
FROM sale.customer
WHERE LEFT(RIGHT(street, 2),1) = '#' 
AND CAST(RIGHT(street, LEN(street) - CHARINDEX('#', street)) AS INT) < 5
ORDER BY street;

-- Q3
-- How many customers have yahoo mail?

SELECT email, PATINDEX('%yahoo%', email)  -- icinde yahoo olmayanları 0, olanların index no verdi.
FROM sale.customer;

-- filtreleyelim simdi
SELECT count(customer_id)  
FROM sale.customer
WHERE PATINDEX('%yahoo%', email) > 0;

-- Question 4: Write a query that returns the name of the streets where the third character of the street is numeric.

SELECT  street, SUBSTRING(street,3,1) as third_char
FROM sale.customer
WHERE ISNUMERIC(SUBSTRING(street,3,1)) = 1;

-- Question 5: Add a new column to the customers table that contains the customers' contact information. If the phone is not null, the phone information will be printed, if not, the email information will be printed.

SELECT phone, email, COALESCE(phone, email) as contact
FROM sale.customer;

-- Question 6: Split the email addresses into two parts from "@" and place them in separate columns.

SELECT email, 
        SUBSTRING(email,1,(CHARINDEX('@', email)-1)) as email_name,
        SUBSTRING(email,(CHARINDEX('@', email)+1), (LEN(email) - (CHARINDEX('@', email)))) as email_provider 
FROM sale.customer;

-- Q7
-- Write a query returns orders that are shipped more than 2 days after the order date
SELECT *, DATEDIFF(DAY, order_date, shipped_date) as shipping_duration
FROM sale.orders
WHERE DATEDIFF(DAY, order_date, shipped_date) > 2
ORDER BY shipping_duration DESC;

-- or and XOR: one or other but not both
-- Exclusive OR (XOR). Show the countries that are big by area (more than 3 million) or big by population
-- (more than 250 million) but not both. Show name, population and area.

SELECT name, population, area
FROM world
WHERE (population > 250000000 AND area < 3000000) 
OR (population < 250000000 AND area > 3000000); 

-- or we can solve it with XOR <>
SELECT name,
       population,
       area
  FROM world
 WHERE (area > 3000000) <> (population > 250000000)

-- Q8 
 -- Equatorial Guinea and Dominican Republic have all of the vowels (a e i o u) in the name. 
 -- They don't count because they have more than one word in the name.
-- Find the country that has all the vowels and no spaces in its name.

SELECT name
FROM world
WHERE name LIKE '%a%' AND
 name LIKE '%e%' AND
 name LIKE '%i%' AND
 name LIKE '%o%' AND
 name LIKE '%u%' AND
name NOT LIKE '% %';

-- Q9
-- The expression subject IN ('chemistry','physics') can be used as a value - it will be 0 or 1. Show the 1984 
-- winners and subject ordered by subject and winner name; but list chemistry and physics last.

SELECT winner, subject
  FROM nobel
 WHERE yr=1984
 ORDER BY subject IN ('physics','chemistry'), subject, winner;
 -- subject IN('physics','chemistry') returns 0 and 1, when we order by it, chemistry and physics, whiche are 1,
 -- come last. Question 14 https://sqlzoo.net/wiki/SELECT_from_Nobel_Tutorial