
create table department
(
	dept_id		int ,
	dept_name	varchar(50) PRIMARY KEY,
	location	varchar(100)
);
insert into department values (1, 'Admin', 'Bangalore');
insert into department values (2, 'HR', 'Bangalore');
insert into department values (3, 'IT', 'Bangalore');
insert into department values (4, 'Finance', 'Mumbai');
insert into department values (5, 'Marketing', 'Bangalore');
insert into department values (6, 'Sales', 'Mumbai');


CREATE TABLE EMPLOYEE
(
    EMP_ID      INT PRIMARY KEY,
    EMP_NAME    VARCHAR(50) NOT NULL,
    DEPT_NAME   VARCHAR(50) NOT NULL,
    SALARY      INT,
    constraint fk_emp foreign key(dept_name) references department(dept_name)
);
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


CREATE TABLE employee_history
(
    emp_id      INT PRIMARY KEY,
    emp_name    VARCHAR(50) NOT NULL,
    dept_name   VARCHAR(50),
    salary      INT,
    location    VARCHAR(100),
    constraint fk_emp_hist_01 foreign key(dept_name) references department(dept_name),
    constraint fk_emp_hist_02 foreign key(emp_id) references employee(emp_id)
);

create table sales
(
	store_id  		int,
	store_name  	varchar(50),
	product_name	varchar(50),
	quantity		int,
	price	     	int
);
insert into sales values
(1, 'Apple Store 1','iPhone 13 Pro', 1, 1000),
(1, 'Apple Store 1','MacBook pro 14', 3, 6000),
(1, 'Apple Store 1','AirPods Pro', 2, 500),
(2, 'Apple Store 2','iPhone 13 Pro', 2, 2000),
(3, 'Apple Store 3','iPhone 12 Pro', 1, 750),
(3, 'Apple Store 3','MacBook pro 14', 1, 2000),
(3, 'Apple Store 3','MacBook Air', 4, 4400),
(3, 'Apple Store 3','iPhone 13', 2, 1800),
(3, 'Apple Store 3','AirPods Pro', 3, 750),
(4, 'Apple Store 4','iPhone 12 Pro', 2, 1500),
(4, 'Apple Store 4','MacBook pro 16', 1, 3500);


select * from employee;
select * from department;
select * from employee_history;
select * from sales;

-- /* QUESTION: Find the employees who's salary is more than the average salary earned by all employees. */


SELECT EMP_NAME, SALARY
    FROM dbo.EMPLOYEE
    WHERE SALARY > (
                SELECT AVG(salary) 
                FROM dbo.EMPLOYEE
                    )
    ORDER BY salary;

-- TYPES OF SUBQUERY
--------------------------------------------------------------------------------
/* < SCALAR SUBQUERY > */
/* QUESTION: Find the employees who earn more than the average salary earned by all employees. */
-- it return exactly 1 row and 1 column

SELECT EMP_ID, EMP_NAME, SALARY
    FROM dbo.EMPLOYEE
    WHERE SALARY > (
            SELECT AVG(SALARY) 
            FROM dbo.EMPLOYEE
            )
    ORDER BY SALARY;

-- How to show the difference:
SELECT *, e.SALARY - avg_sal.sal as salary_difference 
        FROM EMPLOYEE e
        JOIN (SELECT AVG(SALARY) as sal FROM EMPLOYEE) as avg_sal
            ON e.SALARY > avg_sal.sal
        ORDER BY salary_difference DESC;

/* < MULTIPLE ROW SUBQUERY > */
-- returns multiple column, multiple row or one column with multiple rows
/* QUESTION: Find the employees who earn the highest salary in each department. */

-- 1. squery
SELECT emp_name, dept_name, salary
FROM dbo.employee
WHERE (dept_name, salary) IN (
    SELECT dept_name, MAX(salary)
    FROM dbo.employee
    GROUP BY dept_name
);

-- 2. CTE 
WITH dept_max_salary AS (
    SELECT dept_name, MAX(salary) AS max_salary
    FROM employee e 
    GROUP BY dept_name
)
SELECT e.emp_name, e.dept_name, e.salary
FROM employee e 
JOIN dept_max_salary
ON e.dept_name = dept_max_salary.dept_name AND e.salary = dept_max_salary.max_salary;

-- 3. SELF JOIN

SELECT e1.emp_name, e1.dept_name, e1.salary
FROM employee e1
JOIN (
    SELECT dept_name, MAX(salary) AS max_salary
    FROM employee
    GROUP BY dept_name
) e2
ON e1.dept_name = e2.dept_name AND e1.salary = e2.max_salary;

-- Single column, multiple row subquery
/* QUESTION: Find department who do not have any employees */


-- 1. solution with subquery

SELECT DISTINCT dept_name
    FROM dbo.department
    WHERE dept_name NOT IN (
                    SELECT DISTINCT dept_name 
                    FROM EMPLOYEE);


-- 2. solution with set operators
SELECT dept_name 
    FROM dbo.department
    EXCEPT
    SELECT DISTINCT dept_name FROM EMPLOYEE

-- 3. solution with left join
SELECT d.dept_name
    FROM dbo.department d 
    LEFT JOIN EMPLOYEE e 
    ON d.dept_name = e.DEPT_NAME
    WHERE e.dept_name IS NULL

-- 4. solution with cte
WITH cte AS (
            SELECT DISTINCT dept_name
            FROM EMPLOYEE
            )
    SELECT DISTINCT d.dept_name as dept_without_emp
        FROM cte
        RIGHT JOIN dbo.department d 
        ON cte.DEPT_NAME = d.dept_name
        WHERE cte.DEPT_NAME IS NULL;

/* < CORRELATED SUBQUERY >
-- A subquery which is related to the Outer query
/* QUESTION: Find the employees in each department who earn more than the average salary in that department. */

SELECT *
    FROM dbo.EMPLOYEE e1
    WHERE SALARY >
            (
            SELECT AVG(SALARY)
            FROM dbo.EMPLOYEE e2
            WHERE e1.DEPT_NAME = e2.DEPT_NAME
            );

-- solution with self join
SELECT e1.emp_name, e1.dept_name, e1.salary
FROM employee e1
JOIN (
    SELECT dept_name, AVG(salary) AS avg_salary
    FROM employee
    GROUP BY dept_name
) e2
ON e1.dept_name = e2.dept_name AND e1.salary > e2.avg_salary;

-- /* QUESTION: Find department who do not have any employees */
-- Using correlated subquery

-- with NOT EXISTS
SELECT d1.dept_name
FROM dbo.department d1 
WHERE NOT EXISTS (SELECT 1
                        FROM dbo.EMPLOYEE e1
                        WHERE d1.dept_name = e1.dept_name)

-- WITH NOT IN
SELECT DISTINCT d1.DEPT_NAME
FROM dbo.department d1 
WHERE dept_name NOT IN (SELECT DISTINCT e1.dept_name
                        FROM dbo.EMPLOYEE e1
                        WHERE d1.dept_name = e1.dept_name)

/* < SUBQUERY inside SUBQUERY (NESTED Query/Subquery)> */
/* QUESTION: Find stores who's sales better than the average sales accross all stores */

SELECT *
FROM (SELECT store_name, SUM(price) AS total_sales
	 FROM sales
	 GROUP BY store_name) sales
JOIN (SELECT AVG(total_sales) AS avg_sales
	 FROM (SELECT store_name, SUM(price) AS total_sales
		  FROM sales
		  GROUP BY store_name) sales_2
	 ) avg_sales
ON sales.total_sales > avg_sales.avg_sales;

/* < USING SUBQUERY IN SELECT CLAUSE > */
-- Only subqueries which return 1 row and 1 column is allowed (scalar or correlated)
/* QUESTION: Fetch all employee details and add remarks to those employees who earn more than the average pay. */

select e.*
, case when e.salary > (select avg(salary) from employee)
			then 'Above average Salary'
	   else null
  end remarks
from employee e;

-- Alternative approach
select e.*
, case when e.salary > avg_sal.sal
			then 'Above average Salary'
	   else null
  end remarks
from employee e
cross join (select avg(salary) sal from employee) avg_sal;

/* < Using Subquery in HAVING clause > */
/* QUESTION: Find the stores who have sold more units than the average units sold by all stores. */

select store_name, sum(quantity) Items_sold
    from sales
    group by store_name
    having sum(quantity) > (
                            select avg(quantity) 
                            from sales
                            );



/* < Using Subquery with INSERT statement > */
/* QUESTION: Insert data to employee history table. Make sure not insert duplicate records. */
insert into employee_history
select e.emp_id, e.emp_name, d.dept_name, e.salary, d.location
from employee e
join department d on d.dept_name = e.dept_name
where not exists (select 1
				  from employee_history eh
				  where eh.emp_id = e.emp_id);


SELECT * FROM dbo.employee_history

/* < Using Subquery with UPDATE statement > */
/* QUESTION: Give 10% increment to all employees in Bangalore location based on the maximum
salary earned by an emp in each dept. Only consider employees in employee_history table. */


-- update employee e
set salary = (select max(salary) + (max(salary) * 0.1)
			  from employee_history eh
			  where eh.dept_name = e.dept_name)
where dept_name in (select dept_name
				   from department
				   where location = 'Bangalore')
and e.emp_id in (select emp_id from employee_history);

/* < Using Subquery with DELETE statement > */
/* QUESTION: Delete all departments who do not have any employees. */

-- delete from department d1
where dept_name in (select dept_name from department d2
				    where not exists (select 1 from employee e
									  where e.dept_name = d2.dept_name));
