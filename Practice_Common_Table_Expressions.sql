
-- Common Table Expressions Practices

-- QUERY 1 :
drop table emp;
create table emp
( emp_ID int
, emp_NAME varchar(50)
, SALARY int);

insert into emp values(101, 'Mohan', 40000);
insert into emp values(102, 'James', 50000);
insert into emp values(103, 'Robin', 60000);
insert into emp values(104, 'Carol', 70000);
insert into emp values(105, 'Alice', 80000);
insert into emp values(106, 'Jimmy', 90000);

select * from emp;

-- Q: Fetch employees who earn more than avg salary of all employees

-- Solution 1 -- scalar subquery
SELECT *
	FROM emp
	WHERE salary > (
					SELECT avg(salary) FROM emp
					);

-- Solution with CTE
WITH cte AS
(
	SELECT CAST(AVG(SALARY) as INT) as avg_sal
	FROM emp
)
SELECT *
FROM emp e, cte 
WHERE e.salary > cte.avg_sal

-- QUERY 2 :
DrOP table sales2 ;
create table sales2
(
	store_id  		int,
	store_name  	varchar(50),
	product			varchar(50),
	quantity		int,
	cost			int
);
insert into sales2 values
(1, 'Apple Originals 1','iPhone 12 Pro', 1, 1000),
(1, 'Apple Originals 1','MacBook pro 13', 3, 2000),
(1, 'Apple Originals 1','AirPods Pro', 2, 280),
(2, 'Apple Originals 2','iPhone 12 Pro', 2, 1000),
(3, 'Apple Originals 3','iPhone 12 Pro', 1, 1000),
(3, 'Apple Originals 3','MacBook pro 13', 1, 2000),
(3, 'Apple Originals 3','MacBook Air', 4, 1100),
(3, 'Apple Originals 3','iPhone 12', 2, 1000),
(3, 'Apple Originals 3','AirPods Pro', 3, 280),
(4, 'Apple Originals 4','iPhone 12 Pro', 2, 1000),
(4, 'Apple Originals 4','MacBook pro 13', 1, 2500);

select * from sales2;


-- QUESTION: 
-- Find stores who's sales where better than the average sales accross all stores

-- 1. total sales of each store : total_sales
-- 2. find the avg sales with respect all the stores : avg_Sales
-- 3. 2 > 1

--1 total sales
SELECT store_id, SUM(quantity*cost) as total_sales 
FROM sales2
GROUP BY store_id;

-- 2 avg sales per store

select avg(total_sales) avg_sale_per_store
				from (SELECT store_id, SUM(quantity*cost) as total_sales 
							FROM sales2
							GROUP BY store_id) x 

-- 3. 
select *
from   (SELECT store_id, SUM(quantity*cost) as total_sales 
							FROM sales2
							GROUP BY store_id
	   ) total_sales
join   (select avg(total_sales) as avg_sale_per_store
				from (select s.store_id, sum(s.cost) as total_sales
		  	  		from sales2 s
			  			group by s.store_id) x
	   ) avg_sales
on total_sales.total_sales > avg_sales.avg_sale_per_store;



-- Using WITH clause
WITH total_sales as
		(select s.store_id, sum(s.cost) as total_sales_per_store
		from sales2 s
		group by s.store_id),
	avg_sales as
		(select cast(avg(total_sales_per_store) as int) avg_sale_per_store
		from total_sales)
select *
from   total_sales
join   avg_sales
on total_sales.total_sales_per_store > avg_sales.avg_sale_per_store;
