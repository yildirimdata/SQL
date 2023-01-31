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

* Benefits of Using Stored Procedures
- Reduced server/client network traffic
- Stronger security
- Reuse of code
- Easier maintenance
- Improved performance

-- Türkçe'de "saklı yordam" adıyla bilinmekte olup veritabanında saklanan SQL ifadeleridir. Kısaca derlenmiş 
SQL cümleciği denebilir.
--İstenilen zamanda istediğiniz yerde çağırabileceğiniz, parametre alarak bir değer döndürebilen dinamik kod bloklarıdır.
--Veritabanlarında saklandığından dolayı daha hızlı çalışırlar. 
--SP'ler ilk çalıştırıldığında derlenirler ve hafızaya alınırlar, tekrar çalıştıklarında derlenmezler. 
Veritabanında derlenmiş bir "execution plan" halinde saklanırlar. Bu nedenle daha iyi performans sağlarlar.
--SQL komutu çağırıldığında ayrıştırma, derleme ve çalıştırma aşamalarından geçmektedir. SP'ler daha önceden 
derlendikleri için, normal kullanılan bir SQL sorgusundan çok daha performanslı olup ayrıca ağ trafiğini de yormazlar.
--Parametrelerle kullanılabiliyor olması veri temininde esneklik sağlar.


How to Create a Stored Procedure Using Transact-SQL

To create a procedure in Query Editor:

After opening a new Query window, you can use the following as the most basic syntax:*/

USE SampleRetail
GO

-- example 1

CREATE PROC sp_pro 
AS 
BEGIN 
SELECT list_price FROM product.product WHERE list_price > 500
END 
GO 

EXEC sp_pro
GO; 

-- example 2

CREATE PROCEDURE sp_FirstProc -- CREATE PROC da yeterli. sportprocedure(sp) ile baslarsak ne olduguna atifta bulunuruz
AS 
BEGIN 
	SELECT 'Welcome to procedural world.' AS message
END
-- Call the stored procedure as follows:
EXECUTE sp_FirstProc  -- we get the result below as a table.
GO;

-- EXECUTE yerine EXEC de diyebiliriz

CREATE PROC spProducts
AS
BEGIN
     SELECT
          product_name,
          model_year,
          list_price
     FROM
          product.product
     ORDER BY
          list_price
END
GO
-- programmability icinde stored procedures klasorune geldi SRetail altindaki

-- nasil calistiririz 1
EXECUTE spProducts;

-- 2
EXEC spProducts;

--- cok tercih edilmeyen 3.  kullanım

spProducts
GO;

-- alter sp_pro
ALTER PROC sp_pro
AS
BEGIN 
	SELECT 
		list_price
	FROM product.product
	WHERE 
		list_price < 500
END 
GO

EXEC sp_pro -- execute ile calismadi!!
GO; 
-- Degistirmek icin: list_pricei desc yapalım


ALTER PROC spProducts -- create yerine alter yapariz ve gerekli islemi (desc) icine
AS
BEGIN
     SELECT
          product_name,
          model_year,
          list_price
     FROM
          product.product
     ORDER BY
          list_price DESC
END
GO

EXEC spProducts
GO

-- Kaldırmak icin

DROP PROCEDURE spProducts
GO

DROP PROCEDURE dbo.sp_SecondProc
GO

DROP PROC sp_pro 
GO

-- using the ALTER PROCEDURE as below, you can change the query you wrote in the procedure.

ALTER PROCEDURE sp_FirstProc AS
BEGIN
	PRINT 'Welcome to procedural world.'
END
GO 
-- When you want to remove the stored procedure, you can use:

DROP PROCEDURE sp_FirstProc
GO;

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
The parameter values supplied with a procedure call must be constants or a variable.*/

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

-- another example

CREATE PROC sp_products
	(
		@model_year INT  -- parametreleri create ederkeen () icinde, @ ile ve dtype yazarak yapmaya dikkat
		,@prod_name VARCHAR(MAX)  -- sınırlamamak icin max
	)
AS
BEGIN  -- buraya kadar cte gibi olusturduk. simdi yukleme
	SELECT
		product_name
		,model_year
		,list_price
	FROM
		product.product
	WHERE
		model_year=@model_year  -- filtreleme kisminda parametreleri kullanırız
		AND product_name LIKE '%' + @prod_name + '%'  -- burası '%speaker%' yapacak
END


EXECUTE sp_products @model_year=2020, @prod_name='speaker'  -- model yılı 2020 olan ve prod_nameinde speaker gecenler call
GO

-- burada iki parametreyi de optional yapmadigimiz icin ikisini de yazmamiz gerekir. ama istersek birini optional da
-- yapabiliriz. = NULL dersek null dedigimizi yazmasak da olur EXEC'te, veya 2020 dersek birsey yazşlmadiginda
-- default 2020 getirir.

---optional parameters

ALTER PROC sp_products  -- degistirdigimiz icin ALTER, bastan tanimlarken create
	(
		@model_year INT = NULL  -- istersek 2021 yazarız, kullanıcı birsey girmezse 2021ler gelir
		,@prod_name VARCHAR(MAX)
	)
AS
BEGIN
	SELECT
		product_name
		,model_year
		,list_price
	FROM
		product.product
	WHERE
		(@model_year IS NULL OR model_year=@model_year)
		AND product_name LIKE '%' + @prod_name + '%'
END


EXECUTE sp_products @prod_name='speaker'
GO


--drop procedure

DROP PROCEDURE sp_products



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

DECLARE @number AS INT -- as optional
-- buna nasil deger atayacagiz, set ile:
SET @number= 10
SELECT @number;  -- declareden itibaren hepsini birlikte calistirirsak calisir deger dondurur

-- printle tablosuz goruruz
DECLARE @number INT -- as optional
SET @number= 10
PRINT @number
GO  -- go yazarak yukardaki kirmiziligi kaldiririz

---- multiple variables

DECLARE @num1 INT, @num2 INT, @SUM INT
-- asagidaki gibi heosine tek tek atayacagimiz gibi SET veya SELECT icinde yanyana hepsini bir den de atayabiliriz 
SET @num1 = 10  -- assign yolu 1
SELECT @num2 = 20  -- assign yolu 2
SELECT @SUM = @num1 + @num2 -- assign yolu 3 
SELECT @SUM  -- to call

---

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

-- Referring to a variable in a query

DECLARE @cust_id INT = 5  -- bu sekilde deger atama cok kullanlımayan bir yontem

SELECT * FROM sale.customer
WHERE customer_id = @cust_id  -- decalre kismini da birlikte calistirmazsak calismaz

-- Global variables

SELECT @@ROWCOUNT

SELECT @@ROWCOUNT FROM product.product

SELECT * FROM product.product
SELECT @@ROWCOUNT

SELECT @@VERSION
SELECT @@SERVERNAME
SELECT @@SERVICENAME

-- view ile paramtere kullanamayız, procedure ile kullanırız. view'dan daha hızlı. -- ozellikle 3-4 taloyu join edip vs bir
-- procedure olusturunca cok faydali. viewda her defasında filtreleme yapamayız burda yaparız vs vs.

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

-- exapmle

-- ordr_item tablosund satilan urunlerin eyaletleriyle ilgili bir ornek

DECLARE @prod_id INT, @total_quantity INT 
SET @prod_id = 20  -- 20 idli ürüne atadik 
SET @total_quantity = (SELECT SUM(quantity) FROM sale.order_item
WHERE product_id = @prod_id)

IF @total_quantity >= 50  -- 50 den büyükse eyaletlerini say
	BEGIN -- yukard tesk satır oldugu icin yazmamistik
		SELECT COUNT(DISTINCT c.state ) as total_states
		FROM sale.order_item a, sale.orders b, sale.customer c 
		WHERE a.order_id = b.order_id AND b.customer_id = c.customer_id
				AND a.product_id = @prod_id  -- yani 20
	END -- begin yazdiktan sonra hmen yaz end'i unutmamak icin

-- decalreden itibaren tumunu calistirmazsak calismaz.
ELSE IF @total_quantity < 50  -- eyalet isimlerini getir
BEGIN 
	SELECT STRING_AGG([state], ',')  -- isimleri yanyana getirir aynı satirda
		FROM(
		SELECT DISTINCT c.state FROM sale.order_item a, sale.orders b, sale.customer c 
		WHERE a.order_id = b.order_id AND b.customer_id = c.customer_id
				AND a.product_id = @prod_id) subq 
	END
ELSE
	PRINT 'This product has not been ordered yet.'


--- else ifi calistiralim
DECLARE @prod_id INT, @total_quantity INT 
SET @prod_id = 140  
SET @total_quantity = (SELECT SUM(quantity) FROM sale.order_item
WHERE product_id = @prod_id)

IF @total_quantity >= 50 
	BEGIN 
		SELECT COUNT(DISTINCT c.state ) as total_states
		FROM sale.order_item a, sale.orders b, sale.customer c 
		WHERE a.order_id = b.order_id AND b.customer_id = c.customer_id
				AND a.product_id = @prod_id  
	END 

ELSE IF @total_quantity < 50 
BEGIN 
	SELECT STRING_AGG([state], ',')  -- isimleri yanyana getirir aynı satirda
		FROM(
		SELECT DISTINCT c.state FROM sale.order_item a, sale.orders b, sale.customer c 
		WHERE a.order_id = b.order_id AND b.customer_id = c.customer_id
				AND a.product_id = @prod_id) subq 
	END
ELSE
	PRINT 'This product has not been ordered yet.'


--- else
DECLARE @prod_id INT, @total_quantity INT 
SET @prod_id = 540 

SET @total_quantity = (SELECT SUM(quantity) FROM sale.order_item
WHERE product_id = @prod_id)

IF @total_quantity >= 50  
	BEGIN 
		SELECT COUNT(DISTINCT c.state ) as total_states
		FROM sale.order_item a, sale.orders b, sale.customer c 
		WHERE a.order_id = b.order_id AND b.customer_id = c.customer_id
				AND a.product_id = @prod_id  -- veya 20
	END 

ELSE IF @total_quantity < 50 
BEGIN 
	SELECT STRING_AGG([state], ',') 
		FROM(
		SELECT DISTINCT c.state FROM sale.order_item a, sale.orders b, sale.customer c 
		WHERE a.order_id = b.order_id AND b.customer_id = c.customer_id
				AND a.product_id = @prod_id) subq 
	END
ELSE
	PRINT 'This product has not been ordered yet.'

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

-- Do not forget to use BEGIN-END. without begin-end it would be an infinite loop

DECLARE @num_of_iter INT, @counter INT 

SET @num_of_iter = 10 
SET @counter= 0 

WHILE @counter <= @num_of_iter 
		BEGIN
			PRINT @counter
			SET @counter += 1 -- bunu yazmazsak inf loop
		END
GO 

--- example: kac branda ait kac product var yazdıralım

DECLARE @counter INT, @max_brand_id INT, @total_products INT 
SET @counter = 1 -- brand_id 1den baslar
SET @max_brand_id = (SELECT MAX(brand_id) FROM product.brand)  -- () unutma

WHILE @counter <= @max_brand_id
	BEGIN 
			SET @total_products = (SELECT COUNT(product_id) FROM product.product WHERE brand_id = @counter)	
			-- ttoal productsı disarda da belirleyebiliriz burada da
			PRINT 'There are ' + CAST(@total_products AS VARCHAR(10)) 
								+ ' products belonging to brand_id ' 
								+ CAST(@counter AS VARCHAR (2))
			-- int istemistik, castle strye cevirmezsek error verir
			
			SET @counter +=1
	END 

--- Using break to exit loop: 
-- 20den alta dustugunde loopdan cik
DECLARE @counter INT, @max_brand_id INT, @total_products INT 

SET @counter = 1 -- brand_id 1den baslar
SET @max_brand_id = (SELECT MAX(brand_id) FROM product.brand)  -- () unutma

WHILE @counter <= @max_brand_id
	BEGIN 
			SET @total_products = (SELECT COUNT(product_id) FROM product.product WHERE brand_id = @counter)	
			
			IF @total_products <20 BREAK

			PRINT 'There are ' + CAST(@total_products AS VARCHAR(10)) 
								+ ' products belonging to brand_id ' 
								+ CAST(@counter AS VARCHAR (2))
			
			SET @counter +=1
	END 
GO

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

In the following batch, we create a user-defined scalar-valued function dbo.ufnGetAvgSalary(). The function gets an 
input parameter: @seniority. Then, calculates the average salary according to the value/object assigned 
to @seniority parameter. The variable @avg_salary, declared in the function, catches the result average salary. 
Finally, the function returns @avg_salary variable as a result.*/

-- procedurdaki execute yerine return ile kullanacgiz. tablo genelinde kullanacagiz.

CREATE FUNCTION dbo.ufnGetAvgSalary

		(
			@seniority VARCHAR(15)
		)  
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

-- join yapmamiza gerek kalmadan tablolar arası bilgi alisa imkan tanir. bu sadece function ile olur
-- db altinda programmability altinda functions klasorunde depolnair

-- aldigini upper yapan bir func tanimlayalim
CREATE FUNCTION fnc_uppertext  -- genelde fn veya fnc ile baslanir
	(
		@inputtext VARCHAR(MAX)
	) 
-- store proceduredan farkli olarak a'e gecmeden once returns 
RETURNS VARCHAR(MAX)
AS	
	BEGIN 
		RETURN UPPER(@inputtext)  -- aldigin pramaetreyi upper yap
	END

-- nasil cagiracagiz: select veya print ile

SELECT dbo.fnc_uppertext('galatasaray') -- parametredekinin aksine () icine yazarız inputu
-- schema ismiyle calistirinca gelir ancak, bu nedenle dbo basina

-- printle cagiralim
PRINT dbo.fnc_uppertext('galatasaray')

-- store proceduredan farkli olarak tablolarla kullanabiliriz.

SELECT first_name, dbo.fnc_uppertext(first_name) as upper_names FROM sale.customer;

-- deleting a function

DROP FUNCTION dbo.fnc_uppertext;  -- paramteresini yazmayız, sadece function ismi
 

-- example 2:

CREATE FUNCTION fnc_prod_quantity  
	(
		@prod_id INT
	) 

RETURNS INT  -- sayi dondurecek yine bu nedenle int 
AS	
	BEGIN 
		RETURN (SELECT SUM(quantity) FROM sale.order_item WHERE product_id = @prod_id)
	END
GO 

SELECT dbo.fnc_prod_quantity(20)  

-- sale.order_itemda olusturduj ama product_tablosunu yanına getirebiliriz
SELECT *, dbo.fnc_prod_quantity(product_id) FROM product.product


-- how to drop
DROP FUNCTION dbo.fnc_prod_quantity
GO

-- 

CREATE FUNCTION svf_delivery 
	(
		@order_id INT
	)
RETURNS VARCHAR(50)
AS
	BEGIN
			DECLARE @order_status VARCHAR(50)
			DECLARE @date_diff INT 

			SELECT @date_diff = DATEDIFF(day, required_date, shipped_date) 
			FROM sale.orders
			WHERE order_id = @order_id

			IF  @date_diff > 0
				SET @order_status = 'Late Delivery'
			ELSE IF  @date_diff < 0	
				SET @order_status = 'Early Delivery'
			ELSE IF  @date_diff = 0	
				SET @order_status = 'On Time Delivery'	
			ELSE 
				SET @order_status = 'Pending'	

			RETURN @order_status
	END 
GO 

PRINT dbo.svf_delivery(1)  -- 1 nolu siparise bakalım
PRINT dbo.svf_delivery(100)

-- tabloda kullanalım bunu
SELECT *, dbo.svf_delivery(order_id) FROM sale.orders;
GO

-- filtering with function: Where  
SELECT * FROM sale.orders WHERE dbo.svf_delivery(order_id) = 'Pending';


-- check constraintler icin function yazılır genelde
-- using scalar-valued functions with check constraint

CREATE TABLE ON_TIME_ORDER
	(
	Order_ID INT,
	Delivery_Status VARCHAR(50),
	CONSTRAINT check_status CHECK (dbo.svf_delivery(Order_ID) = 'On Time Delivery')
);
GO

SELECT * FROM ON_TIME_ORDER
GO

INSERT INTO  ON_TIME_ORDER (Order_ID, Delivery_Status) VALUES (7, 'On Time Delivery')
GO

DROP TABLE ON_TIME_ORDER
GO

--drop function

DROP FUNCTION dbo.svf_delivery
GO

/*
Table-Valued Function Example:

In the following batch, we create a user-defined table-valued function dbo.dept_of_employee(). The function gets an 
input parameter: @dept_name. In the RETURNS statement we specify the return type of the function. Finally, 
in the RETURN statement we specify what will return the function among the parentheses.*/

CREATE FUNCTION dbo.dept_of_employee 
		(
			@dept_name VARCHAR(15)
		)  
RETURNS TABLE  
AS  
RETURN   -- begin end yeribe return burda artik tvf icin
(  
	SELECT id, name, salary
	FROM dbo.department
	WHERE	dept_name=@dept_name
);  

-- call the function
SELECT * FROM dbo.dept_of_employee('Music');
GO
/*
Here is another example of table-valued function:

Table-valued function dbo.raised_salary() gets an input parameter @name. In the RETURNS statement we generate 
a table variable @raised_salary. Then, as the main process, insert the values we want to get as a result. A RETURN 
statement with a return value cannot be used in this context. Finally, writing the RETURN statement we mention that 
what will return the function among the parentheses.*/

CREATE FUNCTION dbo.raised_salary 
		(
			@name varchar(20)
		)  
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
END
GO 
-- call the function
SELECT * FROM dbo.raised_salary('Eric')
GO 


-- example 2


CREATE FUNCTION tvf_prod_info 
	(
		@prod_id INT
	)
RETURNS TABLE
AS
RETURN
	SELECT
		SUM(a.quantity) [sales_quantity],
		FORMAT(CAST(SUM(a.quantity * a.list_price * (1-a.discount)) AS DECIMAL(18,2)), 'C') [sales_amount],
		COUNT(DISTINCT customer_id) [num_of_cust],
		MAX(b.order_date) [last_order_date]
	FROM
		sale.order_item a
		INNER JOIN
		sale.orders b ON a.order_id=b.order_id
	WHERE
		product_id=@prod_id


SELECT * FROM tvf_prod_info(20)
GO

--CROSS APPLY

SELECT	
	*
FROM
	product.product
CROSS APPLY
	tvf_prod_info(product_id)
GO

--DROP FUNCTION

DROP FUNCTION tvf_prod_info
GO
