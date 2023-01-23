-- SQL WINDOW FUNCTION PRACTICES

-- Source for this practice: https://www.youtube.com/watch?v=Ww71knvhQ-s&list=PLavw5C92dz9Ef4E-1Zi9KfCTXS_IN8gXZ&index=9




create table employee
( emp_ID int
, emp_NAME varchar(50)
, DEPT_NAME varchar(50)
, SALARY int);

insert into employee values(101, 'Mohan', 'Admin', 4000);
insert into employee values(102, 'Rajkumar', 'HR', 3000);
insert into employee values(103, 'Akbar', 'IT', 4000);
insert into employee values(104, 'Dorvin', 'Finance', 6500);
insert into employee values(105, 'Rohit', 'HR', 3000);
insert into employee values(106, 'Rajesh',  'Finance', 5000);
insert into employee values(107, 'Preet', 'HR', 7000);
insert into employee values(108, 'Maryam', 'Admin', 4000);
insert into employee values(109, 'Sanjay', 'IT', 6500);
insert into employee values(110, 'Vasudha', 'IT', 7000);
insert into employee values(111, 'Melinda', 'IT', 8000);
insert into employee values(112, 'Komal', 'IT', 10000);
insert into employee values(113, 'Gautham', 'Admin', 2000);
insert into employee values(114, 'Manisha', 'HR', 3000);
insert into employee values(115, 'Chandni', 'IT', 4500);
insert into employee values(116, 'Satya', 'Finance', 6500);
insert into employee values(117, 'Adarsh', 'HR', 3500);
insert into employee values(118, 'Tejaswi', 'Finance', 5500);
insert into employee values(119, 'Cory', 'HR', 8000);
insert into employee values(120, 'Monica', 'Admin', 5000);
insert into employee values(121, 'Rosalin', 'IT', 6000);
insert into employee values(122, 'Ibrahim', 'IT', 8000);
insert into employee values(123, 'Vikram', 'IT', 8000);
insert into employee values(124, 'Dheeraj', 'IT', 11000);
COMMIT;



select * from employee;

-- Using Aggregate function as Window Function
-- Without window function, SQL will reduce the no of records.
select dept_name, max(salary) from employee
group by dept_name;

-- with WF.. By using MAX as an window function, SQL will not reduce records but the 
-- result will be shown corresponding to each record.
SELECT *, 
	MAX(salary) OVER(PARTITION BY dept_name order by dept_name) as max_salary
	FROM dbo.employee;

-- to show the max_salary amount for each departments
SELECT DISTINCT dept_name, MAX(salary) OVER(PARTITION BY dept_name) as department_max_salary, MAX(salary) OVER() as company_max_salary
FROM dbo.employee;

-- row_number(), rank() and dense_rank()

SELECT *, 
	ROW_NUMBER() OVER(PARTITION BY dept_name ORDER BY dept_name) as row_no
	FROM dbo.employee;


-- QUESTION
-- Fetch the first 2 employees from each department to join the company.
-- solution with cte:

-- assumption: highly likely that the samller order_id corresponds to the employees who joined to the company earlier.
WITH cte AS (
SELECT *, 
		ROW_NUMBER() OVER(PARTITION BY dept_name ORDER BY emp_ID) as row_no
		FROM dbo.employee)
SELECT *
FROM cte
WHERE cte.row_no < 3;

-- QUESTION
-- Fetch top 3 employees who earn the max salary in each department 
WITH cte AS (
		SELECT *, 	
		RANK() OVER(PARTITION BY DEPT_NAME ORDER BY SALARY DESC) as rank_salaries
		FROM dbo.employee
			)
SELECT * 
	FROM cte
	WHERE cte.rank_salaries <4;

-- solution with a subquery
select * from (
	select e.*,
	rank() over(partition by dept_name order by salary desc) as rnk
	from employee e) x  -- don't forget to add alias when sq used with from
where x.rnk < 4;

-- as it can be seen from the question above, if there two people with the same salary level in a department, RANK()
-- ranks these both as 1,1 and then ranks the third wployeee as 3. So there will be no 2 in this case.
-- If we want to avoid this, then instead of rank we can use dense_rank().

WITH cte AS (
		SELECT *, 	
		RANK() OVER(PARTITION BY DEPT_NAME ORDER BY SALARY DESC) as rank_salaries,
		DENSE_RANK() OVER(PARTITION BY DEPT_NAME ORDER BY SALARY DESC) as denk_rank_salaries
		FROM dbo.employee
			)
SELECT * 
	FROM cte
	WHERE cte.rank_salaries <4;


-- Checking the difference between rank, dense_rnk and row_number window functions:
select e.*,
rank() over(partition by dept_name order by salary desc) as rnk,
dense_rank() over(partition by dept_name order by salary desc) as dense_rnk,
row_number() over(partition by dept_name order by salary desc) as rn
from employee e;

-- DIFFERENCES:
-- row_number() ranks all the rows in an ascending order, regardless the values are the same or not
-- RANK() ranks the same records with the same number and then passes to next 2 (1,1,3)
-- DENSE_RANK() ranks the same records with the same number and then passes to the next with 1 incredient (1,1,2)


-- lead and lag

-- QUESTION
-- fetch a query to display if the salary of an employee is higher, lower or equal to the previous employee.

-- STEP 1: to display the salary of previous employee in a new field next to the existing salary column

SELECT *,
		LAG(salary) OVER(PARTITION BY dept_name ORDER BY emp_ID) as previous_salary
	FROM dbo.employee;  -- if we want to check with the 2 previous; then LAG(salary, 2)..
	-- if we want to display 0 instead of null; then LAG(salary, 2,0)


-- STEP 2 : let's add a new field to show if şit's higher-lower than or equal to the previous salary

SELECT *,
		LAG(salary) OVER(PARTITION BY dept_name ORDER BY emp_ID) as previous_salary,
		CASE 
			WHEN LAG(salary) OVER(PARTITION BY dept_name ORDER BY emp_ID) > SALARY THEN 'Higher than previous employee'
			WHEN LAG(salary) OVER(PARTITION BY dept_name ORDER BY emp_ID) = SALARY THEN 'Equal to previous employee'
			WHEN LAG(salary) OVER(PARTITION BY dept_name ORDER BY emp_ID) < SALARY THEN 'Lower than previous employee'
			END AS comparison_salary
	FROM dbo.employee;


-- Similarly using lead function to see how it is different from lag.

SELECT *,
		LAG(salary) OVER(PARTITION BY dept_name ORDER BY emp_ID) as previous_salary,
		LEAD(SALARY) OVER(PARTITION BY DEPT_NAME ORDER BY emp_ID) as next_salary
	FROM dbo.employee;

-- to compare the salary of an employee with the next employee's salary

SELECT *, 
		LEAD(SALARY) OVER(PARTITION BY DEPT_NAME ORDER BY emp_ID) as next_salary,
		CASE 
			WHEN LEAD(SALARY) OVER(PARTITION BY DEPT_NAME ORDER BY emp_ID) > SALARY THEN 'Lower than next employee'
			WHEN LEAD(SALARY) OVER(PARTITION BY DEPT_NAME ORDER BY emp_ID) = SALARY THEN 'Equal to next employee'
			WHEN LEAD(SALARY) OVER(PARTITION BY DEPT_NAME ORDER BY emp_ID) < SALARY THEN 'Higher than next employee'
			END AS salary_comparison
FROM dbo.employee


drop table employee;