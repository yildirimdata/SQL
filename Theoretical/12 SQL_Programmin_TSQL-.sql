--- SQL PROGRAMMING BASICS

--- SQL PROGRAMMING with T-SQL

/*
Stored Procedure Basics

A stored procedure in SQL Server is a group of one or more Transact-SQL statements or a reference to 
a Microsoft .NET Framework common runtime language (CLR) method. Procedures resemble constructs in other programming 
languages because they can:

- Accept input parameters and return multiple values in the form of output parameters to the calling program.
- Contain programming statements that perform operations in the database. These include calling other procedures.
- Return a status value to a calling program to indicate success or failure (and the reason for failure).
- Benefits of Using Stored Procedures
- Reduced server/client network traffic
- Stronger security
- Reuse of code
- Easier maintenance
- Improved performance

How to Create a Stored Procedure Using Transact-SQL

To create a procedure in Query Editor:

After opening a new Query window, you can use the following as the most basic syntax:*/

CREATE PROCEDURE sp_FirstProc AS
BEGIN
	SELECT 'Welcome to procedural world.' AS message
END
-- Call the stored procedure as follows:
EXECUTE sp_FirstProc;  -- we get the result below as a table.

-- using the ALTER PROCEDURE as below, you can change the query you wrote in the procedure.

ALTER PROCEDURE sp_FirstProc AS
BEGIN
	PRINT 'Welcome to procedural world.'
END
GO 
-- When you want to remove the stored procedure, you can use:

DROP PROCEDURE sp_FirstProc;

/*  Note: When a procedure is executed for the first time, it is compiled to determine an optimal access plan 
to retrieve the data. Subsequent executions of the procedure may reuse the plan already generated if it still 
remains in the plan cache of the Database Engine. */

/* ************************************************************
Stored Procedure Parameters

In this section, we demonstrate how to use input and output parameters to pass values to and from a stored procedure.

Parameters are used to exchange data between stored procedures and functions and the application or tool that called 
the stored procedure or function:

- Input parameters allow the caller to pass a data value to the stored procedure or function.
- Output parameters allow the stored procedure to pass a data value or a cursor variable back to the caller. 

Every stored procedure returns an integer return code to the caller. If the stored procedure does not explicitly set 
a value for the return code, the return code is 0.

☝ Note: 
A procedure can have a maximum of 2100 parameters; each assigned a name, data type, and direction. Optionally, parameters 
can be assigned default values.
The parameter values supplied with a procedure call must be constants or a variable.
Here is an example with the explicit comments:*/

-- CREATE A PROCEDURE that takes one input parameter and returns one output parameter and a return code.

CREATE PROCEDURE sp_SecondProc @name varchar(20), @salary INT OUTPUT
AS
BEGIN
-- Set a value in the output parameter by using input parameter.
SELECT @salary = salary
FROM dbo.department
WHERE name = @name
-- Returns salary of @name
RETURN @salary
END
GO

-- CALL/EXECUTE THE PROCEDURE

-- Declare the variables for the output salary.
DECLARE @salary_output INT

-- Execute the stored procedure and specify which variable are to receive the output parameter.
EXEC sp_SecondProc @name = 'Eric', @salary = @salary_output OUTPUT

-- Show the values returned.
PRINT CAST(@salary_output AS VARCHAR(10)) + '$'
GO
--run all of these together

-- You can assign a default value for the parameters. If any value that is used as a parameter value is NULL, then 
-- the procedure continues with the default parameter.

-- Let's modify the procedure "sp_SecondProc":

ALTER PROCEDURE sp_SecondProc @name varchar(20) = 'Jack', @salary INT OUTPUT
AS
BEGIN

-- Set a value in the output parameter by using input parameter.
SELECT @salary = salary
FROM dbo.department
WHERE name = @name

-- Returns salary of @name
RETURN @salary
END
GO

/*
VARIABLES

Using variables allows you to give your SQL procedures a memory. You can store a value in a variable and 
then retrieve and reuse that value at any point later in the same procedure.

A Transact-SQL local variable is an object that can hold a single data value of a specific type. Variables in 
batches and scripts are typically used:
- Declare : to declare and create a variable
- Set: to assign a value into it

DECLARING A VARIABLE

The DECLARE statement initializes a variable by:
- Assigning a name. The name must have a single @ as the first character.
- Assigning a system-supplied or user-defined data type and a length. For numeric variables, precision and scale are 
also assigned.
- Setting the value to NULL.
For example, the following DECLARE statement creates a local variable named @myfirstvar with an int data type.*/

DECLARE @myfirstvar INT

-- The following DECLARE statement creates three local variables named @LastName, @FirstName and 
-- @StateProvince, and initializes each to NULL:

DECLARE @LastName NVARCHAR(20), @FirstName NVARCHAR(20), @State NCHAR(2);



/* ☝ Note: 
- The names of some Transact-SQL system functions begin with two at signs (@@). Although the @@functions are referred to as 
global variables in earlier versions of SQL Server, @@functions aren't variables, and they don't have the same behaviors 
as variables. The @@functions are system functions, and their syntax usage follows the rules for functions.

- You can't use variables in a view.
- Changes to variables aren't affected by the rollback of a transaction.

SETTING A VALUE INTO A VARIABLE

When a variable is first declared, its value is set to NULL. To assign a value to a variable, use the SET statement.

This is the preferred method of assigning a value to a variable. A variable can also have a value assigned by being 
referenced in the select list of a SELECT statement.

To assign a variable a value by using the SET statement, include the variable name and the value to assign to the variable. 
This is the preferred method of assigning a value to a variable.
Here is an example of how to use a variable:*/

--Declare a variable
DECLARE @Var1 VARCHAR(5)
DECLARE @Var2 VARCHAR(20)
--Set a value to the variable with "SET"
SET @Var1 = 'MSc'
--Set a value to the variable with "SELECT"
SELECT @Var2 = 'Computer Science'
FROM dbo.department
--Get a result by using variable value
SELECT *
FROM dbo.department
WHERE graduation = @Var1
AND dept_name = @Var2;
-- run all of them together

-- ☝ Note: If a SELECT statement returns more than one row and the variable references a non-scalar expression, 
-- the variable is set to the value returned for the expression in the last row of the result set.

-- For example, in the following batch @Var1 is set to the ID value of the last row returned, which is 99231:

--Declare a variable
DECLARE @Var1 BIGINT
--Set a value to the variable with "SELECT"
SELECT @Var1 = id
FROM dbo.department
--Call the variable
SELECT @var1 AS last_id;

/*
IF STATEMENTS

IF statements in SQL allow you to check if a condition has been met and, if so, to perform a sequence of actions.  

The SQL statement that follows an IF keyword and its condition is executed if the condition is satisfied: 
the Boolean expression returns TRUE. 
The optional ELSE keyword introduces another SQL statement that is executed when the IF condition is not satisfied: 
the Boolean expression returns FALSE.

Here is the syntax of IF...ELSE*/
IF Boolean_expression   
     { sql_statement | statement_block }   
[ ELSE   
     { sql_statement | statement_block } ] 

/*
Arguments:
Boolean_expression:  Is an expression that returns TRUE or FALSE. If the Boolean expression contains a SELECT statement, 
the SELECT statement must be enclosed in parentheses.

{ sql_statement | statement_block }:  Unless a statement block is used, the IF or ELSE condition can affect the performance 
of only one SQL statement. To define a statement block, use the control-of-flow keywords BEGIN and END.

☝ Note: 
An IF...ELSE construct can be used in batches, in stored procedures, and in ad hoc queries. When this construct is 
used in a stored procedure, it is frequently used to test for the existence of some parameter.
IF tests can be nested after another IF or following an ELSE. The limit to the number of nested levels depends on 
available memory.
*/

-- Example 1
IF DATENAME(weekday, GETDATE()) IN (N'Saturday', N'Sunday')
       SELECT 'Weekend' AS day_of_week;
ELSE 
       SELECT 'Weekday' AS day_of_week;

-- 2
IF 1 = 1 PRINT 'Boolean_expression is true.'  
ELSE PRINT 'Boolean_expression is false.' ;

/*
WHILE LOOPS

In SQL Server there is only one type of loop: a WHILE loop. 
The statements are executed repeatedly as long as the specified condition is true. The execution of statements in the 
WHILE loop can be controlled from inside the loop with the BREAK and CONTINUE keywords.*/

WHILE Boolean_expression   
     { sql_statement | statement_block | BREAK | CONTINUE } 

/*
ARGUMENTS:
Boolean_expression:  Is an expression that returns TRUE or FALSE. If the Boolean expression contains a 
                    SELECT statement, the SELECT statement must be enclosed in parentheses.

{sql_statement | statement_block}:  Is any SQL statement or statement grouping as defined with a statement block. 
                                    To define a statement block, use the control-of-flow keywords BEGIN and END.

BREAK: Causes an exit from the innermost WHILE loop. Any statements that appear after the END keyword, 
        marking the end of the loop, are executed.

CONTINUE: Causes the WHILE loop to restart, ignoring any statements after the CONTINUE keyword.

☝ Note:  If two or more WHILE loops are nested, the inner BREAK exits to the next outermost loop. All the statements 
        after the end of the inner loop run first, and then the next outermost loop restarts.*/

-- Ex 1
SELECT CAST(4599.999999 AS numeric(5,1)) AS col

-- In the following query, we'll generate a while loop. We'll give a limit for the while loop, and we want to break the 
-- loop when the variable divisible by 3. In this example we use WHILE, IF, BREAK and CONTINUE statements together.

-- Declaring a @count variable to delimited the while loop.
DECLARE @count as int
--Setting a starting value to the @count variable
SET @count=1
--Generating the while loop
WHILE  @count < 30 -- while loop condition
BEGIN  	 	
	SELECT @count, @count + (@count * 0.20) -- Result that is returned end of the statement.
	SET @count +=1 -- the variable value raised one by one to continue the loop.
	IF @count % 3 = 0 -- this is the condition to break the loop.
		BREAK -- If the condition is met, the loop will stop.
	ELSE
		CONTINUE -- If the condition isn't met, the loop will continue.
END;

/*
USER DEFINED FUNCTIONS

Like functions in programming languages, SQL Server user-defined functions are routines that accept parameters, perform 
an action, such as a complex calculation, and return the result of that action as a value. The return value can 
either be a single scalar value or a result set.

💡Why use user-defined functions (UDFs)?

- They allow modular programming. 
- You can create the function once, store it in the database, and call it any number of times in your program. 
                User-defined functions can be modified independently of the program source code.
- They allow faster execution: Similar to stored procedures, user-defined functions reduce the compilation cost of the 
                code by caching the plans and reusing them for repeated executions.
- They can reduce network traffic: An operation that filters data based on some complex constraint that cannot be 
                expressed in a single scalar expression can be expressed as a function. The function can 
                then be invoked in the WHERE clause to reduce the number of rows sent to the client.

Types of Functions
1. Scalar-valued Functions
Scalar-valued functions return a single data value of the type defined in the RETURNS clause. For an inline scalar 
function, the returned scalar value is the result of a single statement. For a multistatement scalar function, 
the function body can contain a series of Transact-SQL statements that return the single value.

2. Table-Valued Functions
User-defined table-valued functions return a table data type. For an inline table-valued function, there is no 
function body; the table is the result set of a single SELECT statement.

Scalar-Valued Function Example:

In the following batch, we create an user-defined scalar-valued function dbo.ufnGetAvgSalary(). The function gets an 
input parameter: @seniority. Then, calculates the average salary according to the value/object assigned 
to @seniority parameter. The variable @avg_salary, declared in the function, catches the result average salary. 
Finally, the function returns @avg_salary variable as a result.*/

CREATE FUNCTION dbo.ufnGetAvgSalary(@seniority VARCHAR(15))  
RETURNS BIGINT   
AS   
-- Returns the stock level for the product.  
BEGIN  
    DECLARE @avg_salary BIGINT
	
    SELECT @avg_salary = AVG(salary)
    FROM dbo.department   
    WHERE seniority = @seniority   
 
    RETURN @avg_salary  
END;

-- to call the function
SELECT dbo.ufnGetAvgSalary('Senior') as avg_salary

/*
Table-Valued Function Example:

In the following batch, we create an user-defined table-valued function dbo.dept_of_employee(). The function gets an 
input parameter: @dept_name. In the RETURNS statement we specify the return type of the function. Finally, 
in the RETURN statement we specify what will return the function among the parentheses.*/

CREATE FUNCTION dbo.dept_of_employee (@dept_name VARCHAR(15))  
RETURNS TABLE  
AS  
RETURN   
(  
	SELECT id, name, salary
	FROM dbo.department
	WHERE	dept_name=@dept_name
);  

-- call the function
SELECT * FROM dbo.dept_of_employee('Music');

/*
Here is another example of table-valued function:

Table-valued function dbo.raised_salary() gets an input parameter @name. In the RETURNS statement we generate 
a table variable @raised_salary. Then, as the main process, insert the values we want to get as a result. A RETURN 
statement with a return value cannot be used in this context. Finally, writing the RETURN statement we mention that 
what will return the function among the parentheses.*/

CREATE FUNCTION dbo.raised_salary (@name varchar(20))  
RETURNS @raised_salary TABLE   
(  
    id BIGINT,  
    name NVARCHAR(20),  
    raised_salary BIGINT 
)  
AS  
BEGIN  
	INSERT @raised_salary
	SELECT id, name, salary + (salary * 0.20)
	FROM dbo.department
	WHERE name = @name
RETURN
END;

-- call the function
SELECT * FROM dbo.raised_salary('Eric');

