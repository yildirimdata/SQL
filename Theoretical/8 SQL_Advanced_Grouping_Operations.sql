
---SQL 8 : ADVANCED GROUPING OPERATIONS: HAVING-GROUPING SETS-PIVOT-ROLLUP-CUBE

/*
HAVING clause is used to filter on the new column that will create as a result of the aggregate operation.

Its intended use is very similar to WHERE. Both are used for filtering results. However, HAVING and WHERE differ from 
each other in terms of usage and reasons for use.

WHERE is taken into account at an earlier stage of a query execution, filtering the rows read from the tables. 
Using WHERE, the fields to be grouped over the filtered rows are determined and a new field is created with the 
aggregate operation. And then HAVING is used if you want to filter the newly created field within the same query. 

The GROUP BY clause groups rows into summary rows or groups. The HAVING clause filters groups on a specified condition. 
You have to use the HAVING clause with the GROUP BY. Otherwise, you will get an error. The HAVING clause is applied after 
the GROUP BY. Also, if you want to sort the output, you should use the ORDER BY clause after the HAVING clause. 

The syntax is:

SELECT column_1, aggregate_function(column_2)
FROM table_name
GROUP BY column_1
HAVING search_condition;
*/

-- QUESTION: Find the departments where the average salary of the instructors is more than $50,000. 
-- We cannot use the WHERE clause here. Because the WHERE clause is for non-aggregate data. we have to include the HAVING clause.

SELECT dept_name, AVG(salary)
FROM dbo.department
GROUP BY dept_name
HAVING AVG(salary) > 50000;

-- IMPORTANT: HAVING and WHERE clauses can be in the same query.
-- HAVING is for aggregate data and WHERE is for non-aggregate data. The WHERE clause operates on the data before 
-- the aggregation and the HAVING clause operates on the data after the aggregation.


/*
GROUPING SETS & PIVOT & ROLLUP & CUBE

These methods are mostly used in periodical reporting. They ensure that different breakdowns of the data are obtained 
as a result of a single query. Different grouping options are returned in a single query, saving time and resources.

In addition, it enables decision-makers to evaluate the reported analysis from different directions at a single glance.

GROUPING SETS operator refers to groups of columns grouped in aggregation operations. Syntax of the GROUPING SETS clause:

SELECT
    column1,
    column2,
    aggregate_function (column3)
FROM
    table_name
GROUP BY
    GROUPING SETS (
        (column1, column2),
        (column1),
        (column2),
        ()
);

PIVOT operator allows the rows in the pivot table to be converted into fields in reporting operations. 
The aggregation process is repeated for each column included in the grouping and a separate field is created.

Here is the syntax of the PIVOT clause:

SELECT [column_name], [pivot_value1], [pivot_value2], ...[pivot_value_n]
FROM 
table_name
PIVOT 
(
 aggregate_function(aggregate_column)
 FOR pivot_column
 IN ([pivot_value1], [pivot_value2], ... [pivot_value_n])
) AS pivot_table_name;

ROLLUP operator creates a group for each combination of column expressions. It makes grouping combinations 
by subtracting one at a time from the column names written in parentheses, in the order from right to left. 
Therefore, the order in which the columns are written is important.

Here is the syntax of the ROLLUP clause:

SELECT
    d1,
    d2,
    d3,
    aggregate_function(c4)
FROM
    table_name
GROUP BY
    ROLLUP (d1, d2, d3);

Groups for ROLLUP:
d1, d2, d3
d1, d2, NULL
d1, NULL, NULL
NULL, NULL, NULL

CUBE operator makes all possible grouping combinations for all fields specified in the select operator. The order 
in which the columns are written is not important. Here is the syntax of the CUBE clause:
SELECT
    d1,
    d2,
    d3,
    aggregate_function (c4)
FROM
    table_name
GROUP BY
    CUBE (d1, d2, d3);

Groups for CUBE:
d1, d2, d3
d1, d2, NULL
d1, d3, NULL
d2, d3, NULL
d1, NULL, NULL
d2, NULL, NULL
d3, NULL, NULL
NULL, NULL, NULL
*/

-- ************************************************************************************************
-- ************************************************************************************************
-- Grouping Sets Example

SELECT
    seniority,
    graduation,
    AVG(Salary)
FROM
    dbo.department
GROUP BY
    GROUPING SETS (
        (seniority, graduation),
        (graduation)
        );


-- Please write a query to return only the order ids that have an average amount of more than $2000. 
-- Your result set should include order_id. Sort the order_id in ascending order.

SELECT order_id 
    FROM sale.order_item
    GROUP BY order_id
    HAVING AVG(list_price * quantity * (1-discount)) > 2000
    ORDER BY order_id ASC;

-- ************************************************************************************************
-- ************************************************************************************************
-- PIVOT Example

SELECT [seniority], [BSc], [MSc], [PhD]
FROM 
(
SELECT seniority, graduation, salary
FROM   dbo.department
) AS SourceTable
PIVOT 
(
 avg(salary)
 FOR graduation
 IN ([BSc], [MSc], [PhD])
) AS pivot_table;

-- The result is converted to pivot table format, making it easier to read. The average salaries of the instructors are 
-- presented in two different dimensions, by placing the seniority field on a vertical plane and the categories of the 
-- graduation field on a horizontal plane.

-- Question: Write a query that returns the count of orders of each day between '2020-01-19' and '2020-01-25'. 
-- Report the result using Pivot Table. Note: The column names should be day names (Sun, Mon, etc.).

SELECT * FROM(
    SELECT order_id, DATENAME(weekday, order_date) as day_name
    FROM sale.orders
    WHERE order_date BETWEEN '2020-01-19' and '2020-01-25'
) AS source_table
PIVOT (COUNT(order_id) FOR day_name IN ([Sunday], [Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday])) pvt



--GROUP BY DATENAME(WEEKDAY, order_date)
-- ORDER BY DATENAME(WEEKDAY, order_date);


-- ************************************************************************************************
-- ************************************************************************************************
-- ROLLUP Example

SELECT * FROM dbo.department

SELECT
    seniority,
    graduation,
    AVG(Salary)
FROM
    dbo.department
GROUP BY
    ROLLUP (seniority, graduation);

-- there are three different grouping models using ROLLUP in this example. One of them is applied according to both 
-- seniority and graduation. The second one is applied according to only seniority. The last one is applied with no group.

-- ************************************************************************************************
-- ************************************************************************************************
-- CUBE Example

SELECT
    seniority,
    graduation,
    AVG(Salary)
FROM
    dbo.department
GROUP BY
    CUBE (seniority, graduation);

-- As you see above, there was applied four different grouping models using CUBE. One of them was applied according to 
-- both seniority and graduation. The second one was applied according to only seniority. The third one was applied 
-- according to only graduation.The last one was applied with no group. 

