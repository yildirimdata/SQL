-- 13: SQL SERVER INDEXES

/*
Indexes are special data structures associated with tables or views that help speed up the query. 

Indexes are used to quickly locate data without having to search every row in a database table every 
time a database table is accessed. 

SQL Server has two types of indexes: clustered index and non-clustered index.

Clustered Indexes

A clustered index stores data rows in a sorted structure based on its key values. Each table has only one clustered index 
because data rows can be only sorted in one order. The table that has a clustered index is called a clustered table.

The syntax for creating a clustered index is:

CREATE CLUSTERED INDEX index_name ON schema_name.table_name (column_list);

A clustered index organizes data using a special structured so-called B-tree (or balanced tree) which enables searches, 
inserts, updates, and deletes in logarithmic amortized time.

In the B-Tree, the root node and intermediate level nodes contain index pages that hold index rows. The leaf nodes 
contain the data pages of the underlying table. The pages in each level of the index are linked using another structure 
called a doubly-linked list.

When you create a table with a primary key, SQL Server automatically creates a corresponding clustered index based 
on columns included in the primary key.

If you add a primary key constraint to an existing table that already has a clustered index, SQL Server will 
enforce the primary key using a non-clustered index.

Non-Clustered Indexes

A nonclustered index is a data structure that improves the speed of data retrieval from tables. Unlike a clustered index, 
a nonclustered index sorts and stores data separately from the data rows in the table. It is a copy of selected columns 
of data from a table with the links to the associated table. To create a non-clustered index, we use the CREATE INDEX 
statement:
CREATE [NONCLUSTERED] INDEX index_name ON table_name(column_list);

- Similar to a clustered index, a nonclustered index uses the B-tree structure to organize its data.
- A table may have one or more nonclustered indexes and each non-clustered index may include one or more columns of table.
- Besides storing the index key values, the leaf nodes also store row pointers to the data rows that contain 
the key values. These row pointers are also known as row locators.
- When you create a nonclustered index that consists of multiple columns, the order of the columns in the index is 
very important. You should place the columns that you often use to query data at the beginning of the column list.

-- CREATE INDEX
*Note: Note that to display the estimated execution plan in SQL Server Management Studio, we should first click 
the "Display Estimated Execution Plan button or select the query and press the keyboard shortcut Ctrl+L (Enable Actual
Plan on Azure)*/

-- example: Find customers located in Allen city in the sale.customer table of the SAMPLERETAIL database:

SELECT customer_id, city FROM sale.customer WHERE city = 'Allen';

-- If we display the estimated execution plan, we will see that the query optimizer scans the clustered index 
-- to find the row. This is because of the sale.customer table does not have an index for the city column.

-- To improve the speed of this query, we can create a new index named ix_customers_city for the city column:
CREATE INDEX ix_customers_city ON sale.customer(city);

-- Now, when we display the estimated execution plan of the above query again, we can see that the query optimizer 
-- uses the nonclustered index ix_customers_city:

SELECT customer_id, city FROM sale.customer WHERE city = 'Allen';

-- UNIQUE INDEX
/*
A unique index ensures the index key columns do not contain any duplicate values. 
A unique index can be clustered or non-clustered.
To create a unique index, you use the CREATE UNIQUE INDEX statement as follows:

CREATE UNIQUE INDEX index_name ON table_name(column_list);

SQL Server Unique Index and NULL
NULL is special. It is a marker that indicates the missing information or not applicable. SQL Server treats NULL values 
that if you create a unique index on a nullable column, you can only have only one NULL value in this column.

Unique Index vs. UNIQUE Constraint

Both unique index and UNIQUE constraint enforce the uniqueness of values in one or many columns. When you create a unique 
constraint, behind the scene, SQL Server creates a unique index associated with this constraint.

***********Disable Index Statements*********

You can disable unused indexes for a while before deleting them.  To disable an index, you use the ALTER INDEX statement 
as follows:

ALTER INDEX index_name ON table_name DISABLE;

To disable all indexes of a table, you use the following form of the ALTER INDEX statement:

ALTER INDEX ALL ON table_name DISABLE;

If you disable an index, the query optimizer will not consider that disabled index for creating query execution plans.
☝ Note:  If you disable a clustered index of a table, you cannot access the table data using data manipulation 
language such as SELECT, INSERT, UPDATE, and DELETE until you rebuild or drop the index.

***************Enable Indexes***********

Sometimes, you need to disable an index before doing a large update on a table. By disabling the index, you can speed 
up the update process by avoiding the index writing overhead.

☝ Note:  After completing the update to the table, you need to enable the index. Since the index was disabled, 
you can rebuild the index but cannot just simply enable it. Because after the update operation, the index needs to 
be rebuilt to reflect the new data in the table.

In SQL Server, you can rebuild an index by using the ALTER INDEX statement or DBCC DBREINDEX command. This statement 
uses the ALTER INDEX statement to “enable” or rebuild an index on a table:

ALTER INDEX index_name ON table_name REBUILD;

The following statement uses the ALTER INDEX statement to enable all disabled indexes on a table:

ALTER INDEX ALL ON table_name REBUILD;

****Enable indexes using DBCC DBREINDEX statement****

This statement uses the DBCC DBREINDEX to enable an index on a table:

DBCC DBREINDEX (table_name, index_name);

This statement uses the DBCC DBREINDEX to enable all indexes on a table:

DBCC DBREINDEX (table_name, " ");

************DROP INDEX************
The DROP INDEX statement removes one or more indexes from the current database. Syntax of the DROP INDEX statement:

DROP INDEX [IF EXISTS] index_name ON table_name;

☝ Note: DROP INDEX statement does not remove indexes created by PRIMARY KEY or UNIQUE constraints. To drop 
indexes associated with these constraints, you use the ALTER TABLE DROP CONSTRAINT statement:

ALTER TABLE table_name DROP CONSTRAINTS index_name 
*/

--creating a new table
---------------------------------------------------

create table website_visitor(
		visitor_id int,
		first_name varchar(50),
		last_name varchar(50),
		phone_number bigint,
		city varchar(50)
);


--inserting random values into the table
---------------------------------------------------

DECLARE @i int = 1
DECLARE @RAND AS INT
WHILE @i<200000
BEGIN
	SET @RAND = RAND()*81
	INSERT website_visitor
		SELECT 
			@i , 
			'visitor_name' + cast (@i as varchar(20)), 
			'visitor_surname' + cast (@i as varchar(20)),
			5326559632 + @i, 
			'city' + cast(@RAND as varchar(2))

	SET @i +=1
END;


SELECT TOP 100 *
FROM website_visitor


--STATISTICS
---------------------------------------------------

SET STATISTICS IO ON
--SET STATISTICS TIME ON



--without primary key/clustered index
---------------------------------------------------

SELECT *
FROM website_visitor
WHERE visitor_id=100  --SELECT 1879*8  --- 15032 kb

EXEC sp_spaceused website_visitor  ---15048 kb, 8 kb, TABLE SCAN	


--with primary key/clustered index
---------------------------------------------------

CREATE CLUSTERED INDEX cls_idx ON website_visitor(visitor_id)

SELECT visitor_id
FROM website_visitor
WHERE visitor_id=100  --SELECT 3*8  --- 24 kb


SELECT *
FROM website_visitor
WHERE visitor_id=100


EXEC sp_spaceused website_visitor  ---15688 kb, 136 kb, clustered index seek


--without nonclustered index
---------------------------------------------------

SELECT first_name
FROM website_visitor
WHERE first_name='visitor_name17'  --SELECT 1871*8  --- 14968 kb, clustered index scan


--with nonclustered index
---------------------------------------------------

CREATE NONCLUSTERED INDEX non_cls_idx_1 ON website_visitor(first_name);

SELECT first_name
FROM website_visitor
WHERE first_name='visitor_name17'  --SELECT 3*8  --- 24 kb, nonclustered index scan

EXEC sp_spaceused website_visitor  ---22800 kb, 6536 kb


--with nonclustered index and multiple columns
---------------------------------------------------

SELECT first_name, last_name
FROM website_visitor
WHERE first_name='visitor_name17' --SELECT 6*8  --- 48 kb, nonclustered index scan


CREATE NONCLUSTERED INDEX non_cls_idx_1 
ON website_visitor(first_name)
INCLUDE(last_name)
WITH(DROP_EXISTING=ON);

--Bir sorgunun en performansli hali idealde Sorgu costunun %100 Index Seek yontemi ile getiriliyor olmasidir!

SELECT first_name, last_name
FROM website_visitor
WHERE first_name='visitor_name17'


EXEC sp_spaceused website_visitor  ---27536 kb, 11424 kb


--filtering another column of nonclustered index
---------------------------------------------------

SELECT first_name, last_name
FROM website_visitor
WHERE last_name='visitor_surname17'
ORDER BY last_name;


SELECT *
FROM website_visitor
WHERE city='city78'
ORDER BY last_name;



------------------------------

CREATE NONCLUSTERED INDEX [xxxx]
ON [dbo].[website_visitor] ([city])
INCLUDE ([first_name],[last_name],[phone_number])


EXEC sp_spaceused website_visitor  ---42854 kb, 25856 kb

DROP INDEX cls_idx ON website_visitor
DROP INDEX non_cls_idx_1 ON website_visitor
DROP TABLE dbo.website_visitor