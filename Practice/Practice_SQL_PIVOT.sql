/*
QUESTION: Derive the output.
write a query to fetch the results into a desired format.

Solve the problem using PIVOT table.
Source: https://www.youtube.com/watch?v=4p-G7fGhqRk&list=PLavw5C92dz9Ef4E-1Zi9KfCTXS_IN8gXZ&index=13
*/

-- PostgreSQL & Oracle
drop table sales_data;
create table sales_data
    (
        sales_date      date,
        customer_id     varchar(30),
        amount          varchar(30)
    );
insert into sales_data values (CONVERT(DATETIME, '01-Jan-2021'), 'Cust-1', '50$');
insert into sales_data values (CONVERT(DATETIME,'02-Jan-2021'), 'Cust-1', '50$');
insert into sales_data values (CONVERT(DATETIME,'03-Jan-2021'), 'Cust-1', '50$');
insert into sales_data values (CONVERT(DATETIME,'01-Jan-2021'), 'Cust-2', '100$');
insert into sales_data values (CONVERT(DATETIME,'02-Jan-2021'), 'Cust-2', '100$');
insert into sales_data values (CONVERT(DATETIME,'03-Jan-2021'), 'Cust-2', '100$');
insert into sales_data values (CONVERT(DATETIME,'01-Feb-2021'), 'Cust-2', '-100$');
insert into sales_data values (CONVERT(DATETIME,'02-Feb-2021'), 'Cust-2', '-100$');
insert into sales_data values (CONVERT(DATETIME,'03-Feb-2021'), 'Cust-2', '-100$');
insert into sales_data values (CONVERT(DATETIME,'01-Mar-2021'), 'Cust-3', '1$');
insert into sales_data values (CONVERT(DATETIME,'01-Apr-2021'), 'Cust-3', '1$');
insert into sales_data values (CONVERT(DATETIME,'01-May-2021'), 'Cust-3', '1$');
insert into sales_data values (CONVERT(DATETIME,'01-Jun-2021'), 'Cust-3', '1$');
insert into sales_data values (CONVERT(DATETIME,'01-Jul-2021'), 'Cust-3', '-1$');
insert into sales_data values (CONVERT(DATETIME,'01-Aug-2021'), 'Cust-3', '-1$');
insert into sales_data values (CONVERT(DATETIME,'01-Sep-2021'), 'Cust-3', '-1$');
insert into sales_data values (CONVERT(DATETIME,'01-Oct-2021'), 'Cust-3', '-1$');
insert into sales_data values (CONVERT(DATETIME,'01-Nov-2021'), 'Cust-3', '-1$');
insert into sales_data values (CONVERT(DATETIME,'01-Dec-2021'), 'Cust-3', '-1$');

select * from sales_data;

-- or
-- insert into sales_data values (convert(datetime, '01-Jan-2021',105), 'Cust-1', '50$');
-- insert into sales_data values (convert(datetime, '02-Jan-2021',105), 'Cust-1', '50$');

-- solution map:

/*
1) Aggregate the sales amount for each customer per month:
    - Build the base SQL query:
        - Remove $ symbol
        - Transform sales_date to fetch only the month and year.
2) Aggregate the sales amount per month irrespective of the customer.
3) Aggregate the sales amount per each customer irrespective of the month.
4) Transform final output:
    - Replace negative sign with parenthesis.
    - Suffix amount with $ symbol.
*/

-- STEP 1: examining the dtypes and convert requirements
SELECT MONTH(sales_date), customer_id, SUM(amount)
    FROM dbo.sales_data 
    GROUP BY MONTH(sales_date), customer_id;

-- ERROR: Operand data type varchar is invalid for sum operator.

-- STEP 2: executing pivor function
SELECT *
    FROM ( 
SELECT 
        customer_id,
        FORMAT(sales_date, 'MMM-yy') AS sales_date,
        CAST(REPLACE(amount, '$', '') AS INT) AS amount
        FROM dbo.sales_data
    ) sales 
    PIVOT
    (
        SUM(amount) 
        FOR sales_date IN ([Jan-21],  -- quotename() below
                            [Feb-21],
                            [Mar-21],
                            [Apr-21],
                            [May-21],
                            [Jun-21],
                            [Jul-21],
                            [Aug-21],
                            [Sep-21],
                            [Oct-21],
                            [Nov-21],
                            [Dec-21])
    ) as pivot_table;


SELECT QUOTENAME(FORMAT(sales_date, 'MMM-yy')) + ','
    FROM dbo.sales_data;


-- aggregate & total amount for each month and each customers: UNION

SELECT *
    FROM ( 
SELECT 
        customer_id,
        FORMAT(sales_date, 'MMM-yy') AS sales_date,
        CAST(REPLACE(amount, '$', '') AS INT) AS amount
        FROM dbo.sales_data
    ) sales 
    PIVOT
    (
        SUM(amount) 
        FOR sales_date IN ([Jan-21],  -- quotename() below
                            [Feb-21],
                            [Mar-21],
                            [Apr-21],
                            [May-21],
                            [Jun-21],
                            [Jul-21],
                            [Aug-21],
                            [Sep-21],
                            [Oct-21],
                            [Nov-21],
                            [Dec-21])
    ) as pivot_table
UNION
SELECT *
    FROM ( 
SELECT 
        'Total' as customer,
        FORMAT(sales_date, 'MMM-yy') AS sales_date,
        CAST(REPLACE(amount, '$', '') AS INT) AS amount
        FROM dbo.sales_data
    ) sales 
    PIVOT
    (
        SUM(amount) 
        FOR sales_date IN ([Jan-21],  -- quotename() below
                            [Feb-21],
                            [Mar-21],
                            [Apr-21],
                            [May-21],
                            [Jun-21],
                            [Jul-21],
                            [Aug-21],
                            [Sep-21],
                            [Oct-21],
                            [Nov-21],
                            [Dec-21])
    ) as pivot_table

--STEP 4: summing up the amount for each customer and adding it as a total column

-- aggregate & total amount for each month and each customers: UNION
WITH sales AS
(
SELECT *
    FROM ( 
SELECT 
        customer_id as Customer,
        FORMAT(sales_date, 'MMM-yy') AS sales_date,
        CAST(REPLACE(amount, '$', '') AS INT) AS amount
        FROM dbo.sales_data
    ) as sales 
    PIVOT
    (
        SUM(amount) 
        FOR sales_date IN ([Jan-21],  -- quotename() below
                            [Feb-21],
                            [Mar-21],
                            [Apr-21],
                            [May-21],
                            [Jun-21],
                            [Jul-21],
                            [Aug-21],
                            [Sep-21],
                            [Oct-21],
                            [Nov-21],
                            [Dec-21])
    ) as pivot_table
UNION
SELECT *
    FROM ( 
SELECT 
        'Total' as Customer,
        FORMAT(sales_date, 'MMM-yy') AS sales_date,
        CAST(REPLACE(amount, '$', '') AS INT) AS amount
        FROM dbo.sales_data
    ) as sales 
    PIVOT
    (
        SUM(amount) 
        FOR sales_date IN ([Jan-21],  -- quotename() below
                            [Feb-21],
                            [Mar-21],
                            [Apr-21],
                            [May-21],
                            [Jun-21],
                            [Jul-21],
                            [Aug-21],
                            [Sep-21],
                            [Oct-21],
                            [Nov-21],
                            [Dec-21])
    ) as pivot_table), 
    final_data AS
    (SELECT Customer 
            , coalesce([Jan-21], 0) as Jan_21
            , coalesce([Feb-21], 0) as Feb_21
            , coalesce([Mar-21], 0) as Mar_21
            , coalesce([Apr-21], 0) as Apr_21
            , coalesce([May-21], 0) as May_21
            , coalesce([Jun-21], 0) as Jun_21
            , coalesce([Jul-21], 0) as Jul_21
            , coalesce([Aug-21], 0) as Aug_21
            , coalesce([Sep-21], 0) as Sep_21
            , coalesce([Oct-21], 0) as Oct_21
            , coalesce([Nov-21], 0) as Nov_21
            , coalesce([Dec-21], 0) as Dec_21
            FROM sales)
SELECT Customer
, case when Jan_21 < 0 then concat('(', Jan_21 * -1, ')$') else concat(Jan_21, '$') end as [Jan-21]
, case when Feb_21 < 0 then concat('(', Feb_21 * -1, ')$') else concat(Feb_21, '$') end as [Feb-21]
, case when Mar_21 < 0 then concat('(', Mar_21 * -1, ')$') else concat(Mar_21, '$') end as [Mar-21]
, case when Apr_21 < 0 then concat('(', Apr_21 * -1, ')$') else concat(Apr_21, '$') end as [Apr-21]
, case when May_21 < 0 then concat('(', May_21 * -1, ')$') else concat(May_21, '$') end as [May-21]
, case when Jun_21 < 0 then concat('(', Jun_21 * -1, ')$') else concat(Jun_21, '$') end as [Jun-21]
, case when Jul_21 < 0 then concat('(', Jul_21 * -1, ')$') else concat(Jul_21, '$') end as [Jul-21]
, case when Aug_21 < 0 then concat('(', Aug_21 * -1, ')$') else concat(Aug_21, '$') end as [Aug-21]
, case when Sep_21 < 0 then concat('(', Sep_21 * -1, ')$') else concat(Sep_21, '$') end as [Sep-21]
, case when Oct_21 < 0 then concat('(', Oct_21 * -1, ')$') else concat(Oct_21, '$') end as [Oct-21]
, case when Nov_21 < 0 then concat('(', Nov_21 * -1, ')$') else concat(Nov_21, '$') end as [Nov-21]
, case when Dec_21 < 0 then concat('(', Dec_21 * -1, ')$') else concat(Dec_21, '$') end as [Dec-21]
, case when Customer = 'Total' then null
       else case when (Jan_21 + Feb_21 + Mar_21 + Apr_21 + May_21 + Jun_21 + Jul_21 + Aug_21 + Sep_21 + Oct_21 + Nov_21 + Dec_21) < 0
                     then concat('(', (Jan_21 + Feb_21 + Mar_21 + Apr_21 + May_21 + Jun_21 + Jul_21 + Aug_21 + Sep_21 + Oct_21 + Nov_21 + Dec_21) * -1 , ')$')
                 else concat((Jan_21 + Feb_21 + Mar_21 + Apr_21 + May_21 + Jun_21 + Jul_21 + Aug_21 + Sep_21 + Oct_21 + Nov_21 + Dec_21), '$')
            end
  end as Total
FROM final_data;

