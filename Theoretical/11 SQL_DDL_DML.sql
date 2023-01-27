-- SQL-11 : Data Definition Language (DDL)

/*
In a DBMS, the SQL database language is used to:

- Create the database and table structures
- Perform basic data management chores (add, delete and modify)
- Perform complex queries to transform raw data into useful information

Create Database

The SQL statement CREATE is used to create the database and table structures.
The major SQL DDL statements are CREATE DATABASE.
*/
CREATE DATABASE new_db;

/*
Create Table
Once the database is created, the next step is to create the database tables.

Table name is the name of the database table such as departments. Each field in the 
CREATE TABLE has three parts (see below):

- ColumnName
- Data type
- Optional Column Constraint
- Table Constraint 
The general format for the CREATE TABLE command is:*/

CREATE TABLE departments
(
	id BIGINT NOT NULL,
	name VARCHAR(20) NULL,
	dept_name VARCHAR(20) NULL,
	seniority VARCHAR(20) NULL,
	graduation VARCHAR(20) NULL,
	salary BIGINT NULL,
	hire_date DATE NULL,
        CONSTRAINT pk_1 PRIMARY KEY (id)
 ) ;

-- ALTER TABLE

-- We can use ALTER TABLE statements to add and drop constraints.
-- ALTER TABLE allows columns to be removed.
-- When a constraint is added, all existing data are verified for violations.

ALTER TABLE departments
ADD CONSTRAINT unique_id_constraint UNIQUE (id);

--  DROP TABLE
-- The DROP TABLE will remove a table from the database. Make sure you have the correct database selected.
-- Executing the below SQL DROP TABLE statement will remove the table departments from the database.

DROP TABLE departments;

/*
Key Terms

- DDL: abbreviation for data definition language
- DML: abbreviation for data manipulation language
- SEQUEL: acronym for Structured English Query Language; designed to manipulate and retrieve data 
        stored in IBM’s quasi-relational database management system, System R
- Structured Query Language(SQL): a database language designed for managing data held in a relational 
                                    database management system
*/


--- DATA MANIPULATION LANGUAGE (DML)

/*
The SQL data manipulation language (DML) is used to query and modify database data. 
Below we will describe how to use the SELECT, INSERT, UPDATE, and DELETE SQL DML command statements.

SELECT – to query data in the database
INSERT – to insert data into a table
UPDATE – to update data in a table
DELETE – to delete data from a table

💡In the SQL DML statement:

- Each clause in a statement should begin on a new line.
- The beginning of each clause should line up with the beginning of other clauses.
- If a clause has several parts, they should appear on separate lines and be indented under the start of the clause to show the relationship.
- Upper case letters are used to represent reserved words.
- Lower case letters are used to represent user-defined words.


INSERT
The INSERT statement adds rows to a table. In addition,

- INSERT specifies the table or view that data will be inserted into.
- Column_list lists columns that will be affected by the INSERT.
- If a column is omitted, each value must be provided.
- If you are including columns, they can be listed in any order.
- VALUES specifies the data that you want to insert into the table. VALUES is required.
- Columns with the IDENTITY property should not be explicitly listed in the column_list or values_clause.
Its syntax:

INSERT [INTO] Table_name | view name [column_list]
DEFAULT VALUES | values_list | select statement


When inserting rows with the INSERT statement, these rules apply:

Inserting an empty string (' ') into a varchar or text column inserts a single space.
All char columns are right-padded to the defined length.
All trailing spaces are removed from data inserted into varchar columns, except in strings that contain 
only spaces. These strings are truncated to a single space.
If an INSERT statement violates a constraint, default or rule, or if it is the wrong data type, 
the statement fails and SQL Server displays an error message.

When you specify values for only some of the columns in the column_list, one of three things can 
happen to the columns that have no values:

- A default value is entered if the column has a DEFAULT constraint, if a default is bound to the 
column, or if a default is bound to the underlying user-defined data type.
- NULL is entered if the column allows NULLs and no default value exists for the column.
- An error message is displayed and the row is rejected if the column is defined as NOT NULL and 
no default exists.

This example uses INSERT to add a record to the departments table we created before in the DDL topic.
*/

INSERT departments (id, name, dept_name, seniority, graduation, salary, hire_date)
VALUES
(10238,	'Eric'	   ,'Economics'	       ,'Experienced'	,'MSc' ,72000	,'2019-12-01'),
(13378,	'Karl'	   ,'Music'	       ,'Candidate'	,'BSc' ,42000	,'2022-01-01'),
(23493,	'Jason'	   ,'Philosophy'       ,'Candidate'	,'MSc' ,45000	,'2022-01-01'),
(30766,	'Jack'     ,'Economics'	       ,'Experienced'	,'BSc' ,68000	,'2020-06-04'),
(36299,	'Jane'	   ,'Computer Science' ,'Senior'	,'PhD' ,91000	,'2018-05-15'),
(40284,	'Mary'	   ,'Psychology'       ,'Experienced'	,'MSc' ,78000	,'2019-10-22'),
(43087,	'Brian'	   ,'Physics'	       ,'Senior'	,'PhD' ,93000	,'2017-08-18'),
(53695,	'Richard'  ,'Philosophy'       ,'Candidate'	,'PhD' ,54000	,'2021-12-17'),
(58248,	'Joseph'   ,'Political Science','Experienced'	,'BSc' ,58000	,'2021-09-25'),
(63172,	'David'	   ,'Art History'      ,'Experienced'	,'BSc' ,65000	,'2021-03-11'),
(64378,	'Elvis'	   ,'Physics'	       ,'Senior'	,'MSc' ,87000	,'2018-11-23'),
(96945,	'John'	   ,'Computer Science' ,'Experienced'	,'MSc' ,80000	,'2019-04-20'),
(99231,	'Santosh'  ,'Computer Science' ,'Experienced'	,'BSc' ,74000	,'2020-05-07');

-- SELECT
-- The SELECT statement, or command, allows the user to extract data from tables, based on specific 
-- criteria.

/*
Insert into an IDENTITY column
By default, data cannot be inserted directly into an IDENTITY column; however, if a row is accidentally 
deleted, or there are gaps in the IDENTITY column values, you can insert a row and specify the IDENTITY 
column value.

To allow an insert with a specific identity value, the IDENTITY_INSERT option should be used.

If the id column in the departments table was an IDENTITY column and it was desired to add an id to 
this column, it could be done as follows:*/

SET IDENTITY_INSERT departments ON;
INSERT departments (id, name, dept_name, seniority, graduation, salary, hire_date)
VALUES (44552,	'Edmond' ,'Economics'	,'Candidate','BSc' ,60000	,'2021-12-04')

SET IDENTITY_INSERT departments OFF;

/*
Insert with SELECT

We can sometimes create a small temporary table from a large table. For this, we can insert rows 
with a SELECT statement. When using this command, there is no validation for uniqueness. Consequently, 
there may be many rows with the same id in the example below.

This example creates a smaller temporary salary table using the CREATE TABLE statement. 
Then the INSERT with a SELECT statement is used to add records to this temporary salary table 
from the departments table. You should use # for creating a temporary table.*/

CREATE TABLE #salary (
id BIGINT NOT NULL,
name VARCHAR (40) NULL,
salary BIGINT NULL
);

INSERT #salary
SELECT id, name, salary FROM departments;

-- Or you can use the SELECT ... INTO ... FROM statement as follow:

SELECT id, name, salary 
INTO #salary
FROM departments;

SELECT *
FROM #salary

/*
UPDATE

The UPDATE statement changes data in existing rows either by adding new data or modifying existing data.


This example uses the UPDATE statement to change the employee name in the name field to be Edward 
for the employee has 44552 id number in the departments table.
*/
UPDATE departments
SET name = 'Edward'
WHERE id = 44552;

/*
DELETE
The DELETE statement removes rows from a record set. DELETE names the table or view that holds 
the rows that will be deleted and only one table or row may be listed at a time. WHERE is a 
standard WHERE clause that limits the deletion to select records.

The DELETE syntax looks like this.*/

DELETE [FROM] {table_name | view_name }
[WHERE clause];

/*
The rules for the DELETE statement are:

- If you omit a WHERE clause, all rows in the table are removed (except for indexes, the table, constraints).
- DELETE cannot be used with a view that has a FROM clause naming more than 
one table. (Delete can affect only one base table at a time.)

There are three different DELETE statements that can be used.

1. Deleting all rows from a table (Not recommended):

DELETE FROM departments;

2. Deleting selected rows:

DELETE FROM departments WHERE id = 44552;


*/