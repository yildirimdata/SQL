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

CREATE TABLE departmentsss
(
	id BIGINT NOT NULL,  -- PK icin IDENTITY kullanmak daha iyi olur , kendi otomatik artirir sayiyi
	name VARCHAR(20) NULL,  -- 20 is not char number, it's byte. but each byte corresponds to 1 char.
	dept_name VARCHAR(20) NULL,
	seniority VARCHAR(20) NULL,  -- NOT NULL DEFAULT "Human Resources" dersek eger hicbirsey girilmezse Human Resources yazar
	graduation VARCHAR(20) NULL,  
	salary BIGINT NULL,
	hire_date DATE NULL,
        CONSTRAINT pk_1 PRIMARY KEY (id)
 ) ;

-- SQL'de cift tirnak olamz, tek istisnasi aliaslar...

-- Bir tabloda PRIMARY KEY'den başka bir alana, hatta birden fazla alana UNIQUE constrainti tanımlayabilirsin. (email vs. 
-- gibi Unique olmasını istediğin birden fazla alan olabilir) Fakat yalnız bir tane PRIMARY key olabilir. 

-- ALTER TABLE 

-- We can use ALTER TABLE statements to add and drop constraints.
-- ALTER TABLE allows columns to be removed.
-- When a constraint is added, all existing data are verified for violations.

ALTER TABLE dbo.departmentsss
ADD CONSTRAINT unique_id_constraint UNIQUE (id);

-- Varolan bir tabloya PRIMARY KEY tanımlamak için ise ALTER kullanıyoruz. Var olan tablolarda yapılacak her 
-- türlü değişiklik ALTER komutu ile yapılıyo

ALTER TABLE Calisanlar
ADD CONSTRAINT PK_CalisanID PRIMARY KEY (id);   

--  DROP TABLE
-- The DROP TABLE will remove a table from the database. Make sure you have the correct database selected.
-- Executing the below SQL DROP TABLE statement will remove the table departments from the database.

DROP TABLE departmentsss;

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
The SQL data manipulation language (DML) is used to query and modify database data. Main SQL DML command statements are:

SELECT – to query data in the database
INSERT – to insert data into a table
UPDATE – to update data in a table
DELETE – to delete data from a table

💡In the SQL DML statement:

- Each clause in a statement should begin on a new line.
- The beginning of each clause should line up with the beginning of other clauses.
- If a clause has several parts, they should appear on separate lines and be indented under the start of the 
		clause to show the relationship.
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

INSERT [INTO] Table_name | view name (column_list)
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

INSERT departmentsss (id, name, dept_name, seniority, graduation, salary, hire_date)  -- NOT NULL constrainti olan tum sutular yazılmalı
VALUES
-- IDENTITY olsaydi sayilari zaten otomatik verecegi icin ilk kismi yazmazdik
(10238,	'Eric'	   ,'Economics'	       ,'Experienced'	,'MSc' ,72000	,'2019-12-01'),
(13378,	'Karl'	   ,'Music'	       ,'Candidate'			,'BSc' ,42000	,'2022-01-01'),
(23493,	'Jason'	   ,'Philosophy'       ,'Candidate'		,'MSc' ,45000	,'2022-01-01'),
(30766,	'Jack'     ,'Economics'	       ,'Experienced'	,'BSc' ,68000	,'2020-06-04'),
(36299,	'Jane'	   ,'Computer Science' ,'Senior'		,'PhD' ,91000	,'2018-05-15'),
(40284,	'Mary'	   ,'Psychology'       ,'Experienced'	,'MSc' ,78000	,'2019-10-22'),
(43087,	'Brian'	   ,'Physics'	       ,'Senior'		,'PhD' ,93000	,'2017-08-18'),
(53695,	'Richard'  ,'Philosophy'       ,'Candidate'		,'PhD' ,54000	,'2021-12-17'),
(58248,	'Joseph'   ,'Political Science','Experienced'	,'BSc' ,58000	,'2021-09-25'),
(63172,	'David'	   ,'Art History'      ,'Experienced'	,'BSc' ,65000	,'2021-03-11'),
(64378,	'Elvis'	   ,'Physics'	       ,'Senior'		,'MSc' ,87000	,'2018-11-23'),
(96945,	'John'	   ,'Computer Science' ,'Experienced'	,'MSc' ,80000	,'2019-04-20'),
(99231,	'Santosh'  ,'Computer Science' ,'Experienced'	,'BSc' ,74000	,'2020-05-07');

-- SELECT
-- The SELECT statement is used to extract data from tables, based on specific criteria.

/*
Insert into an IDENTITY column

By default, data cannot be inserted directly into an IDENTITY column; however, if a row is accidentally 
deleted, or there are gaps in the IDENTITY column values, you can insert a row and specify the IDENTITY 
column value.

To allow an insert with a specific identity value, the IDENTITY_INSERT option should be used.

If the id column in the departments table was an IDENTITY column and it was desired to add an id to 
this column, it could be done as follows:*/

SET IDENTITY_INSERT departmentsss ON;
INSERT departmentsss (id, name, dept_name, seniority, graduation, salary, hire_date)
VALUES (44552,	'Edmond' ,'Economics'	,'Candidate','BSc' ,60000	,'2021-12-04')

SET IDENTITY_INSERT departmentsss OFF;

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
SELECT id, name, salary FROM departmentsss;

-- Or you can use the SELECT ... INTO ... FROM statement as follow:

SELECT id, name, salary 
INTO #salary
FROM departmentsss;

SELECT *
FROM #salary

/*
UPDATE

The UPDATE statement changes data in existing rows either by adding new data or modifying existing data.

This example uses the UPDATE statement to change the employee name in the name field to be Edward 
for the employee has 44552 id number in the departments table.
*/
UPDATE departmentsss
SET name = 'Edward'
WHERE id = 44552;

UPDATE dbo.departmentsss
SET name = 'Bakayoko'
Where id = 23493

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

Dikkat edilecek nokta WHERE ifadesi ile belli bir kayıt seçilip silinir.
Eğer WHERE ifadesini kullanmadan yaparsak tablodaki bütün kayıtları silmiş oluruz.
*/

DELETE FROM dbo.departmentsss WHERE id = 23493;

-- PK coklayamaz ama FK coklayabilir. amacı da o zaten PK degil de FK olmasinin. Category tablosunda PK unique iken order
-- tablosunda coklamasi gibi.


--- A DATABASE EXAMPLE

CREATE DATABASE LibraryDB
USE LibraryDB;
--create schemas
CREATE SCHEMA Book;
CREATE SCHEMA Person;


--Create Tables
--create Book.Book table
CREATE TABLE [Book].[Book](
	[Book_ID] INT PRIMARY KEY NOT NULL,
	[Book_Name] [nvarchar](100) NOT NULL,
	[Author_ID] INT NOT NULL,
	[Publisher_ID] INT NOT NULL);
--create Book.Author table
CREATE TABLE [Book].[Author](
	[Author_ID] INT,
	[Author_FirstName] NVARCHAR(50) NOT NULL,
	[Author_LastName] NVARCHAR(50) NOT NULL);
--create Book.Publisher Table
CREATE TABLE [Book].[Publisher](
	[Publisher_ID] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Publisher_Name] NVARCHAR(100) NULL);
--create Person.Person table
CREATE TABLE [Person].[Person](
	[SSN] BIGINT PRIMARY KEY CHECK(LEN(SSN)=11),
	--[SSN] BIGINT PRIMARY KEY CONSTRAINT ck_size CHECK(LEN(SSN)=11)
	[Person_FirstName] NVARCHAR(50) NULL,
	[Person_LastName] NVARCHAR(50) NULL);
--create Person.Loan table
CREATE TABLE [Person].[Loan](
	[SSN] BIGINT NOT NULL,
	[Book_ID] INT NOT NULL,
	PRIMARY KEY ([SSN], [Book_ID])); --composite key
--create Person.Person_Phone table
CREATE TABLE [Person].[Person_Phone](
	[Phone_Number] BIGINT PRIMARY KEY,
	[SSN] BIGINT NOT NULL REFERENCES [Person].[Person]);
--create Person.Person_Mail table
CREATE TABLE [Person].[Person_Mail](
	[Mail_ID] INT PRIMARY KEY IDENTITY(1,1),
	[Mail] NVARCHAR(MAX) NOT NULL,
	[SSN] BIGINT UNIQUE NOT NULL,
	CONSTRAINT FK_SSNum FOREIGN KEY (SSN) REFERENCES Person.Person(SSN));

	--- INSERT

SELECT * FROM Person.Person;

INSERT INTO Person.Person ([SSN], [Person_FirstName], [Person_LastName])
-- PK var ama IDENTITY olmadigi icin sutun ismi yazacagiz
-- kac sutun ayzarsak asagi o kadar deger yazmaliyiz yoksa error. girecegimiz degerler de o sıralamaya uygun olamlı
	VALUES (78695647362, 'Zehra', 'Tekin')

-- bunu ille tablodaki sutun sırasına yapmak zorunnda degiliz
INSERT INTO Person.Person ([Person_FirstName],[SSN],  [Person_LastName])
VALUES ('Eylem', 78695646543, 'Dogan')


INSERT INTO Person.Person ([SSN], [Person_FirstName])
-- last name null diye tanimlamistik
	VALUES (28695123456, 'Zehra' )  -- PK ikiyle basladigi ve int oldugu icin eklemeyi o siraya gore yapar PK'de

-- INTO kullanımı optional, ayrıca her defasında column names yazmak zorunda degiliz
INSERT Person.Person  -- sutun ismi yoksa sql ne kadar sutun varsa o kadar giris yapacagiz diye algilar, dolayısıyla sutun sayısı
-- kadar deger girmeliyiz.
	VALUES (34567123456, 'Kerim', 'Oztürk' )

INSERT Person.Person  -- NULL tanimladigimiz icin null da yazabiliriz
	VALUES (34569876543, 'Ali', NULL )

-- su pk'ya tekrar aynı sey girilecegi icin hata verir: PK Key Constraint
INSERT INTO Person.Person ([SSN], [Person_FirstName], [Person_LastName])
	VALUES (78695647362, 'Zehra', 'Tekin')

-- CHECK ERROR: SSN 11 karakter olsun demistik
INSERT INTO Person.Person ([SSN], [Person_FirstName], [Person_LastName])
	VALUES (78695647, 'Zehra', 'Tekin')  -- The INSERT statement conflicted with the CHECK constraint "CK__Person__SSN__29572725". The conflict occurred in database 
										-- "LibraryDB", table "Person.Person", column 'SSN'.

-- DATATYPES error: bunnu girer str'yi convert eder
INSERT INTO Person.Person ([SSN], [Person_FirstName], [Person_LastName])
	VALUES ('78695647657', 'Zehra', 'Tekin')

-- ama bu hata
INSERT INTO Person.Person ([SSN],[Person_FirstName],[Person_LastName]) --ERROR
	VALUES ('Zehra', 'Zehra', 'Tekin')  -- Error converting data type varchar to bigint.

-- toplu veri girisi
SELECT * FROM Person.Person_Mail
SELECT * FROM Person.Person

-- iki tane zehra tekin var, birisini silecegim
DELETE FROM Person.Person WHERE SSN = 78695647657;

-- -- FOREIGN KEy Constraint
INSERT INTO Person.Person_Mail (Mail, SSN) 
-- bu error verdi: The INSERT statement conflicted with the FOREIGN KEY constraint "FK_SSNum". The conflict 
-- occurred in database "LibraryDB", table "Person.Person", column 'SSN'.
	VALUES ('eylemdog@gmail.com', 12345678977),
		   ('zehrtek@hotmail.com', 78945612344),
		   ('kemözt@gmail.com', 55008479341)

		   
-- PK ve FK aynı olmalı her ikisinde:
INSERT INTO Person.Person_Mail (Mail, SSN) 
	VALUES ('eylemdog@gmail.com', 78695646543),
		   ('zehrtek@hotmail.com', 78695647362),
		   ('kemözt@gmail.com', 34567123456)
	
SELECT * FROM Person.Person_Mail

--foreign key constraint
SELECT * FROM Person.Person

INSERT INTO Person.Person_Mail (Mail, SSN) 
VALUES ('ahm@gmail.com', 11111111111)  --ERROR

--IDENTITY constraint
INSERT INTO Person.Person_Mail (Mail_ID, Mail, SSN) 
VALUES (10, 'takutlu@gmail.com', 46056688505) --ERROR
-- biz zaten 1,1 yazmistik. asagida Mail_ID yazıp 10 yazarsak error: IDENTITY_INSERT is set to off
-- bu set ile acilip kapanabilir gecici.

-- illa manuel giris yapmak zorunda degiliz. select ile alabiliriz
-- Insert with SELECT statement
-- 1. tablo olusturalim bos
CREATE TABLE Names ([Name] varchar(50))

-- 2 selectle alaım: baska bir databaseden de alabiliriz mumkun bu

SELECT * FROM Names;

INSERT [Names]  -- select oldugu icin values yazmaya gerek yok
SELECT first_name FROM [SampleRetail].sale.customer WHERE first_name LIKE '%M%';

-- SELECT INTO
--*************************************
-- table cretae etmeden yeni table olusturururz:
SELECT *  -- tum sutunları getir. nereye: INTO :
INTO Person.Person_2  -- yeni bir tabel olusturuyoruz bu isimde, schema kullanmazsak dbo olarak olusturur
FROM Person.Person  

SELECT * FROM Person.Person_2

-- different database
SELECT *  -- select ınto ile tablo tasiriz yeni tablo ismi yazarak
INTO Person.Person_3
FROM [SampleRetail].sale.customer  -- hangi tabloya gore olusturacagimiz
WHERE 1=0;  -- veriyi kendim girmek ama o tablonun sadece sutunlarını almak istiyorsak. where 1=0 sadece sutun ismi ve dtype tasir

SELECT * FROM Person.Person_3

-- DEFAULT constraint (insert default values)

-- yani hic veri girilmezse bizim belirledigimiz veriler girer, unknown, 0 etc
INSERT Book.Publisher
DEFAULT VALUES

SELECT * FROM Book.Publisher
-- IDentityi kendisi atadi, digeri de yukarda NULL tanımladigimiz icind efault NULL girdi


--****************************************************************************************************
---- UPDATE

-- koşul tanımlamak önemli. herhangi bir koşul tanımlamazsak tum tablıyu degistirir

SELECT * FROM Person.Person_2

UPDATE Person.Person_2  -- su tablyou update et
SET Person_FirstName = 'Tahsin' -- neyi ayarlayacaksak onu yazarız
-- wherre ile sart kosmazsak tum isimleri Tahsin yapar, tek satir istiyorsak belirlemeliyiz wher eile
-- PK ile where, o unique cunku
WHERE SSN= 28695123456;  -- tek zehrayı tahsin yaptik

-- bunu baska türlü nasıl yaparız:
-- UPDATE WITH JOIN
SELECT * FROM Person.Person

UPDATE Person.Person_2 SET Person_FirstName = B.Person_FirstName 
FROM Person.Person_2 A Inner Join Person.Person B ON A.SSN=B.SSN

SELECT * FROM Person.Person_2


-- bozulan tabloyu join ile veya subquery ile uodate ederiz

--- update with functions

UPDATE Person.Person_2
SET SSN = LEFT(SSN, 10); -- SSNleri 11 rakamdan 10 rakama dusurelim
-- nerde kullanırız: bazen guvenlik icin sona harf konur bir tane, tamamını kaldirmak icin
-- ya da iban nonun son 6sı hesap no, onu cekmek icin
SELECT * FROM Person.Person_2;

-- DELETE ****************************************************************

SELECT * FROM Book.Publisher;

INSERT Book.Publisher
VALUES ('Iletisim', 'Can Yayin', 'IS Bank')

DELETE FROM Book.Publisher

-- ici bosalir talblonun. ama publisher_id kaldigi yerden baslar. once 4 vardi sildik sifilandi, 
-- ama ilk ekleyecegimiz value 5ten başlar identity'de. eger truncate ile yapsaydık 1deen baslardi. truncate ve delete farki bu

-- WHERE ile tek veya toplu kayıt silimi

SELECT * FROM Person.Person_2;

-- sadece tek satır delete
DELETE FROM Person.Person_2
WHERE SSN = 2869512345;

-- fonknsiyonlarla kullanımı

DELETE FROM Person.Person_2
WHERE Person_LastName IS NULL;  -- last namei null olanalrı siler

--- FOREIGN KEY_REFERENCE CONSTRAINT: PK silersek bu baska yerde FK ise hata verir, 

-- DROP ******************************
-- databse objectsi tamamen ortadan kaldirir

-- ne sileceksek DROP table veya drop view vs diye belirtiriz

DROP TABLE [dbo].[Names];
DROP TABLE [Person].Person_2;

-- baska bir tabloya reference veren tablo dusurebilir miyiz
-- foreign key constraint
DROP TABLE Person.Person  -- pk'si ssn idi ve baska 2 tabloda bu ssn reference idi. bu düsmez error verir
-- Could not drop object 'Person.Person' because it is referenced by a FOREIGN KEY constraint.

-- TRUNCATE
-- tablo ici bosaltilir

TRUNCATE TABLE Person.Person_Mail;  -- artik tekrar giris yapinca pd 1den baslar
-- once constrainti drop eder sonra tabloyu silebiliriz ama


TRUNCATE TABLE Person.Person;  -- error


-- ALTER  ************************************************************
-- ************************************************************************************************************************

-- Alanlardaki kısıtları (constraints) kaldırma işlemi kısıt adları ile yapıyoruz.
-- Örnek syntax: ALTER TABLE tablo_adi DROP CONSTRAINT kisit_adi
-- Bu yüzden başta constraint verirken kısıt adı tanımlaması yapmakta fayda var.

-- ADD KEY CONSTRAINTS

ALTER TABLE Book.Book 
ADD CONSTRAINT FK_Author FOREIGN KEY (Author_ID) REFERENCES Book.Author (Author_ID)  --ERROR

ALTER TABLE Book.Author 
ADD CONSTRAINT pk_author PRIMARY KEY (Author_ID)  --ERROR

ALTER TABLE Book.Author 
ALTER COLUMN Author_ID INT NOT NULL

ALTER TABLE Book.Book 
ADD CONSTRAINT FK_Publisher FOREIGN KEY (Publisher_ID) REFERENCES Book.Publisher (Publisher_ID)

--Person.Loan Table

ALTER TABLE Person.Loan 
ADD CONSTRAINT FK_PERSON FOREIGN KEY (SSN) REFERENCES Person.Person (SSN)

ALTER TABLE Person.Loan 
ADD CONSTRAINT FK_book FOREIGN KEY (Book_ID) REFERENCES Book.Book (Book_ID)
--ON DELETE CASCADE / SET NULL / SET DEFAULT / NO ACTION --default
--ON UPDATE CASCADE / SET NULL / SET DEFAULT / NO ACTION --default

--ADD CHECK CONSTRAINTS
ALTER TABLE Person.Person_Phone 
ADD CONSTRAINT FK_Phone_check CHECK (Phone_Number BETWEEN 700000000 AND 9999999999)

SELECT * FROM Person.Person_Phone; 
SELECT * FROM Person.Person;

INSERT Person.Person_Phone VALUES(600000000, 12345678977)

--drop constraints
ALTER TABLE Person.Person_Phone
DROP CONSTRAINT FK_Phone_check;


/* Bir SQL tablosundaki bir alana NOT NULL ya da NULL constrainti eklemek istersek Syntax'i şu şekildedir:*/
ALTER TABLE tablo_adi 
ALTER COLUMN  alan_adi veri_turu [NOT NULL | NULL ]
-- örneğimizdeki alana NOT NULL kısıtı ekleyelim:
ALTER TABLE orders_dimen2
ALTER COLUMN Order_Date varchar NOT NULL
/* Bir SQL tablosundaki bir alana UNIQUE constrainti eklemek istersek Syntax'i şu şekildedir:
(Not: hata mesajı almamak için alandaki verilerin eşsiz olması yada tablonun boş olması gerekiyor.)*/
ALTER TABLE tablo_adi 
ADD CONSTRAINT kisit_adi UNIQUE(alan_adi)
-- örneğimizdeki alana UNIQUE kısıtı ekleyelim:
ALTER TABLE order_dimen2
ADD CONSTRAINT order_date_kisit UNIQUE (Order_Date)
/* Bir SQL tablosundaki bir alana PRIMARY KEY constrainti eklemek istersek Syntax'i şu şekildedir:
(Not: Kısıt isimleri önemlidir. Kaldırma işlemleri bu kısıt isimleri üzerinde yapılacaktır.*/
ALTER TABLE tablo_Adi 
ADD CONSTRAINT kisit_adi PRIMARY KEY (alan_adi)
/* örneğimizde bir alanı önce NOT NULL sonra da PRIMARY KEY yapalım:
(PRIMARY KEY için temel kurallardan biri boş geçilemez olmasıdır. 
Bu yüzden pek tabi ki öncelikle bu alanın NOT NULL olması gerekmektedir.)*/
ALTER TABLE order_dimens2 ALTER COLUMN Ord_id INT NOT NULL
ALTER TABLE order_dimens2 ADD CONSTRAINT PK_ord_id PRIMARY KEY (Ord_id)
