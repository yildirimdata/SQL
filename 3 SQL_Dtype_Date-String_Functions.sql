--- SQL 3 DATA TYPES - Date Functions -- STRİNG Functions

-- DTYPES

/* String dtypes: 
1. char (0 ile 8000 arası chars-her char 1 byte)
2. varchar 0 8k chars arası. Char(5) e ALİ yazarsak + 2 karakterlik bosluk daha ayirir. 
varchar(5) ise ALİ icin 3 byte ayırır. TC kimlik gibi, A-B-C gibi fixed uzunlukta kategoriler icn
CHAr, sabit olmayanlar icin varchar kullanabilriz.
Eğer sınırlama yapmazsanız VARCHAR ın 65000 karakter sınırı var. 
CHAR kullanırsanız 255 karaktere kadar müsaade eder. 
VARCHAR'ı daha büyük doküman yazacaksanız tercih edebilirsiniz.
3. eger unicode karakter varsa (ülke dillerine mahsus) her 1 char icin 2 byte. 
onlar icin nchar ve nvarchar.
4. text ve ntext: bunlar artik kullanılmıyor.
*/
-- varchar - nvarchar (unicode / non-unicode)
SELECT 'القمر'; -- output: ?????
SELECT N'القمر'  -- output القمر

SELECT CONVERT(varchar, N'القمر') -- okuyamadı
SELECT CONVERT(Nvarchar, N'القمر')  -- okudu

-- emojiler icin de aynı sey

SELECT N'😀'

-- char-varchar farki
SELECT DATALENGTH(CONVERT(char(50), 'Galatasaray'))  -- output 50
SELECT DATALENGTH(CONVERT(varchar(50), 'Galatasaray'))  -- output 11


--- DATE DTYPES
/*
1. time hh:mm:ss[.nnnnnnn]
2. date YYYY-MM-DD 
3. smalldatetime  YYYY-MM-DD hh:mm:ss:[.nnn](1900e kadar geri gider)
4. datetime YYYY-MM-DD hh:mm:ss[.nnn] (1753 oncesi girilemez)
5. datetime2 YYYY-MM-DD hh:mm:ss[.nnnnnnn]
6. datetimeoffset YYYY-MM-DD hh:mm:ss[.nnnnnnn][+|-]hh:mm
*/



-- NUMERIC Dtypes
/*
1. Tinyint (0-255 arası - 1bytes)
2. Smallint (-32.000,32.000 arası, 2 bytes)
3. Int(-2 mr - 2 mr arası, 4 bytes)
4. Bigint (-+ 9,223,372,036,854,775,808 arası, 8 bytes)
5. Decimal(precision,sale) 5 to 17 bytes
6. Numeric - decimalle aynı tamamen
7. Money (-+ 9,223,372,036,854,775,808 arası, 8 bytes)
8. Smallmoney (-+ 214.478.3648 arası, 4 bytes)
9. Float (1 digit-38 digits arası, 4 bytes - cok kullanılmaz)
*/



-- DATE FUNCTIONS
-- The most used date functions:
•	GETDATE()
•	DATENAME(datepart, date)
•	DATEPART(datepart, date)
•	DAY(date)
•	MONTH(date)
•	YEAR(date)
•	DATEDIFF(datepart, startdate, enddate)
•	DATEADD(datepart, number, date)
•	EOMONTH(startdate [, month to add])
•	ISDATE(expression)

-- GETDATE() returns the current system date as datetime dtype
-- DATENAME str DATEPART ise int getirir. (January - 01 gibi)
SELECT GETDATE();  -- output 2023-01-14 08:27:11.567

-- we'll add a table to sample retail
CREATE TABLE t_date_time (
A_time [time],
A_date [date],
A_smalldatetime [smalldatetime],
A_datetime [datetime],
A_datetime2 [datetime2],
A_datetimeoffset [datetimeoffset]
);

SELECT * FROM t_date_time; -- su an ici bos

-- how to fill with getdate()
INSERT t_date_time
VALUES (GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE(),GETDATE())

SELECT * FROM t_date_time;  -- filled


SELECT A_date,
    DATENAME(DW, A_date) [weekday],   -- datename str döndürür: saturday Day of Week         
    DATEPART(DW, A_date) [weekday_2],   -- datepart rakam döndürür       
    DATENAME(M, A_date) [month],             
    DATEPART(month, A_date) [month_2],
    DAY (A_date) [day],
    MONTH(A_date) [month_3],
    YEAR (A_date) [year],
A_time,
    DATEPART (minute, A_time) [minute],
    DATEPART (NANOSECOND, A_time) [nanosecond]
FROM        t_date_time;

SELECT DATENAME(WEEKDAY, GETDATE()) as today;
SELECT DATENAME(WEEKDAY, '2021-10-11') as day; 
SELECT DATENAME(DAYOFYEAR, '2021-10-11') as day;
-- There are fourty datepart tips in SQL Server we can use. Such as: DAY, HOUR, MINUTE, WEEKDAY, YEAR, DAYOFYEAR, MONTH, etc.

SELECT DATEPART(MINUTE, GETDATE()) as minute_now;
SELECT DATEPART(ISO_WEEK, GETDATE()) as week;
SELECT DATEPART(MONTH, GETDATE()) as month; 
-- There are fourty datepart tips in SQL Server you can use. Such as: DAY, HOUR, MINUTE, WEEKDAY, YEAR, DAYOFYEAR, MONTH, etc.

/*
TARHLERİ nasıl Manipule ederiz: sunları cekerek:

YEAR / YYYY / YY
QUARTER / QQ / Q
MONTH / MM / M
DAYOFYEAR / DY / Y
WEEK / WW / WK
WEEKDAY / DW
DAY / DD / D
HOUR / HH
MINUTE / MI / N
SECOND / SS / S
MILLISECOND / MS
MICROSECOND / MCS
NANOSECOND / NS
*/
-- The DAY() function returns the day of the date in integer format.
SELECT DAY('2021-11-19') AS day;
-- The MONTH() function returns the month of the date in integer format.
SELECT MONTH('2021-11-19') AS month; 
-- The YEAR() function returns the year of the date in integer format.
SELECT YEAR('2021-11-19') AS year; 

-- DATEDIFF: iki tarih arasındaki farkı bulur. datediff(datepart, startdate, enddate). returns int.
-- datepart dedigi farki nasil getirmemizi istedigi.month, year, hour, day vs diyebiliriz. The datepart can be year, month, week, day, hour, minute, second, or milisecond. You then specify the start date in the startdate parameter and the end date in the enddate parameter for which you want to find the difference.

SELECT DATEDIFF(WEEK, '1981-08-15', GETDATE()) as my_life_weeks;

SELECT A_date,       
       A_datetime,
       GETDATE() AS [CurrentTime],
       DATEDIFF (DAY, '2020-11-30', A_date) Diff_day,
       DATEDIFF (MONTH, '2020-11-30', A_date) Diff_month,
       DATEDIFF (YEAR, '2020-11-30', A_date) Diff_year,
       DATEDIFF (HOUR, A_datetime, GETDATE()) Diff_Hour,
       DATEDIFF (MINUTE, A_datetime, GETDATE()) Diff_Min
FROM  t_date_time;

SELECT * FROM sale.orders;


SELECT       order_date, shipped_date,
DATEDIFF (DAY, order_date, shipped_date) day_diff,
DATEDIFF (DAY, shipped_date, order_date) day_diff  -- erken tarihi yazmak gerektigini gormek icin ekledim bunu
FROM        sale.orders
WHERE        order_id = 1;

SELECT DATEDIFF(YEAR, '1981-08-15', GETDATE())  -- yas hesaplamak icin

-- DATEADD(datepart, number, date). returns the data type of the date argument. The DATEADD() function enables us to add an interval to part of a specific date.

SELECT DATEADD(SECOND, 1, '2022-12-31 23:59:59') as new_year;

SELECT	order_date,
		DATEADD(YEAR, 5, order_date), 
		DATEADD(DAY, 5, order_date),
		DATEADD(DAY, -5, order_date)	-- eksi degerlerle de kullanılabilir	
FROM	sale.orders
-- where	order_id = 1
WHERE	order_id BETWEEN 1 AND 10;

SELECT GETDATE(), DATEADD(HOUR, 5, GETDATE())  -- su ana 5 saat ekleyelim

-- end of month function eomonth() 1 veya 2 paramtere alıp o tarihteki ay sonuna gider. altta 2sine de örnek

SELECT EOMONTH('2022-01-12') as EndOfJanuary;

SELECT	order_date, EOMONTH(order_date) end_of_month,
		EOMONTH(order_date, 2) eomonth_next_two_months  -- 2 ay sonraki ayın son gunu
FROM	sale.orders
WHERE order_id=1;

-- ISDATE() bir deger date mi degil mi kontrol ediyoruz. 1 date 0 degil.. --The ISDATE() returns 1 if the expression is a valid datetime value; otherwise, 0. If your system language is us_english, the date format is "mdy" (month, day, year) by default. The ISDATE() function checks the expression according to this format.
-- If you need, you can change the date format as below:
-- SET DATEFORMAT DMY

SELECT ISDATE('123');  -- 0 döner
SELECT ISDATE('20230114');   -- 1 döner

-- ek bilgi: dolaylı cevirme: sql dtypeları kendi cevirmeye calisir once farkli tiplerde islem yapinca
SELECT 1 + '1'  -- output 2

SELECT ISDATE('2021-12-02') --2021/12/02 ||| 2021.12.02 ||| 20211202
 
SELECT ISDATE('02/12/2022') --02-12-2022 ||| 02.12.2022

SELECT ISDATE('02122022');  -- 0 verir.

-- Write a query returns orders that are shipped more than 2 days after the order date
SELECT *, DATEDIFF(DAY, order_date, shipped_date) as date_diff
FROM sale.orders
WHERE DATEDIFF(DAY, order_date, shipped_date) > 2
ORDER BY date_diff DESC;
-- ilk tarih, önce gelen, ilk yazılır.

/* STRING FUNCTIONS

•	LEN(input string)
•	CHARINDEX(substring, string [, start location])
•	PATINDEX('%PATTERN%', input string)
•	LEFT(input string, number of characters)
•	RIGHT(input string, number of characters)
•	SUBSTRING(input string, start, length)
•	LOWER(input string)
•	UPPER(input string)
•	STRING_SPLIT(input string, seperator)
•	TRIM([removed characters, from] input string)
•	LTRIM(input string, seperator)
•	RTRIM(input string, seperator)
•	REPLACE(input string, seperator)
•	STR(input string, seperator)
String functions are used to manipulate string values. They are useful for data cleaning operations in data analysis */


-- LEN() bosluklari da sayar, ama karakter bittikten sonraki bosluklari ('ali  ') saymaz
-- CHARINDEX(substring, string, [, start_location]). index nosunu getirir substringin
-- PATINDEX('%pattern%, input_string). farki substr yerine pattern arar ve ilk gectigi yerin starting indexi verir

SELECT LEN('welcome');  -- 7
SELECT LEN('  welcome');  -- 9
SELECT LEN('  welcome     ');  -- 9

SELECT LEN(123456778); -- 9.. once str convert sonra len verir

-- If string is NULL value, the length function returns NULL. If the value specified inside the function is numeric, the LEN() function returns the length of a string representation of the value. That means the numeric value is converted into a string and then the number of characters of it is calculated. Such as:
SELECT LEN(NULL) AS col1, LEN(10) AS col2, LEN(10.5) AS col3; 


-- if there is a quote in the string: what is escape char

-- SELECT 'Jack's Phone' -- calismaz
SELECT 'Jack''s Phone'  -- calisir

----- CHARINDEX(substring, string [, start location])
-- CHARINDEX() function finds the first occurrence of substring and returns a value of integer type. If the substring is not found, CHARINDEX() function returns 0.
 
SELECT CHARINDEX('C', 'CHARACTER')  -- 1
 
SELECT CHARINDEX('C', 'CHARACTER', 2)  -- 6
 
SELECT CHARINDEX('CT', 'CHARACTER')  -- 2 karakter aratma : 6
 
SELECT CHARINDEX('ct', 'CHARACTER')  -- 6
SELECT CHARINDEX('saray', 'Fenerbahce 0 Galatasaray 3') AS start_position;
SELECT CHARINDEX('self', 'Reinvent yourself and myself') AS motto; -- it returns the 1st self
--  But the following query find second 'self' by using the optional parameter [start location] 
SELECT CHARINDEX('self', 'Reinvent yourself and myself', 15) AS motto; 

-- PATINDEX(%pattern%, input string)
 
 -- The PATINDEX() function returns the starting position of the first occurrence of a pattern in a specified expression, or zeros if the pattern is not found, on all valid text and character data types.

SELECT PATINDEX('%R', 'CHARACTER')  -- 9.. bitmesini istedigimiz icin ilk degil son r yi verdi
 
SELECT PATINDEX('R%', 'CHARACTER')  -- 0 r ile baslamiyor
 
SELECT PATINDEX('%[RC]%', 'CHARACTER') -- 1 :  [] sadece r ve c harfi demek. arada - olsa arasındaki tüm harfler
-- icinde mutlaka r veya c olsun.. ilk basta c var
 
SELECT PATINDEX('_H%' , 'CHARACTER')  -- 1... bir harf olsun sonrasında h gelsin. bu ilk c'de.

-- LEFT(str, number_of_characters) soldan o kadar numara chars alir. 2 yazarsak ikinci degil 2 tane chars demek
-- RIGHT (str, number_of_characters) sagdan o kadar numara chars alir
-- SUBSTRING(str, start, length) ornegin ('dddfd', 2,2) 2. harften basla 2 tane al demek. genelde
-- charindex ile index no bulunur ve sonra substring ile alinir... SUBSTRING(string, start_postion, [length])... If any argument is NULL, the SUBSTRING() function will return NULL.

-- left ve right

SELECT LEFT('CHARACTER', 5);  -- CHARA  
SELECT LEFT('  CHARACTER', 5);  --   CHA

SELECT RIGHT('CHARACTER', 5);  -- ACTER 
SELECT RIGHT('CHARACTER  ', 5);  --   TER

SELECT SUBSTRING('CHARACTER', 3, 5);  -- ARACT
SELECT SUBSTRING('CHARACTER', CHARINDEX('A', 'CHARACTER'), 5);  -- ARACT
SELECT UPPER (SUBSTRING('galatasaray champion', 0 , CHARINDEX(' ','galatasaray c'))); 

SELECT SUBSTRING('CHARACTER', 0, 5); -- normalde 1den baslar sql server. bu 4 döndürür, cunku olmayan index verdik
-- -1 yazsak 5ten düşer 2 eksik olarak 3 getirir.

SELECT SUBSTRING(88888888, 3, 5);  -- bu calismaz. numeric degerlerle olmuyor

-- LOWER

SELECT LOWER('CHARACTER');

-- UPPER

SELECT UPPER('character');

--   bas harfi büyük, digerleri kucuk icin indexleriz

SELECT UPPER(LEFT('character',1)) + LOWER(RIGHT('character', LEN('character')-1));


--- STRING_SPLIT(string, seperator) (it's not like the split() in python pandas with expand parameter. This splits a str into rows, not to the columns. So we can't use it for a case, such as splitting email addresses into two parts from @ symbol and displayin them in two columns.)

SELECT value from string_split('John,is,a,very,tall,boy.', ',');

-- (,, da bir row olarak gelir, to avoid, trim)

SELECT 
    value  
FROM 
    STRING_SPLIT('red,green,,blue', ',')
WHERE
    TRIM(value) <> '';


--------- TRIM,LTRIM, RTRIM

-- TRIM([removed_characters, from] input_string) : python strip() gibi sol ve sagdaki boslukları temizler
-- RTRIM sagdaki LTRIM soldaki boslukları
-- ama karakter de koyabiliriz yerlerine TRIM'de

SELECT TRIM('     CHARACTER     ');
-- arada bosluk olsaydı temizlemez.. kalirdi o bosluk

-- karakterleri kesmek icin de kullanabiliriz. ama bosluklar da belirtilmeli
SELECT TRIM('?, ' FROM '   ?SQL Server,') AS TrimmedString;  -- output SQL Server
SELECT TRIM('@' FROM '@@@galatasaray@@@@') AS new_string;
SELECT TRIM('ca' FROM 'cadillac') AS new_string; 


SELECT LTRIM('     CHARACTER     ');  -- sag bosluk kalir
SELECT RTRIM('     CHARACTER     ');  -- sol bosluk kalır

-- REPLACE(input_str, substring, new_substr) : replaces all occurences of a substring within a string with another string... REPLACE(string expression, string pattern, string replacement)

SELECT REPLACE('CHARACTER STRING', ' ', '/');
SELECT REPLACE (TRIM(' Reinvent $Yourself! '), '$', '');

-- numeric degelrlerle de kullanırız
SELECT REPLACE(123456, 2, 0);  -- 2'yi 0 ile degistirir. bilgi guvenligi icin ilk 5 rakam degistirlir mesela

--- STR(float expression [, length [, decimal]])
--Returns character data converted from numeric data. The character data is right-justified, with a specified length and decimal precision.

SELECT STR(list_price) as str_prices FROM product.product;
SELECT STR(123.45, 6, 1);
SELECT STR(123.45, 2, 2); 
SELECT STR(FLOOR (123.45), 8, 3) AS num_to_str; 

-- CAST(), CONVERT()

-- CAST ( expression AS data_type [ ( length ) ] ). It casts a value of one type to another. FE:  CAST(Phone AS int)
-- CONVERT ( data_type [ ( length ) ] , expression [ , style ] ). It converts a value of one type to another. FE: CONVERT(INT; Phone, [style: 1 ornegin])

-- ROUND(number, decimals, [operation]) : rounds a number to a specified number of decimal places.
-- round() dtype'a gore degisim yapar. 123,84573 round ederken 123,85000 yapar, silmez sondakileri

-- ISNULL(check expression, replacement value)Ç replaces null with the specified replacement value
-- COALESCE(Expression1, [E',---,En]): returns the first non-null argument

-- AdSoyad(varchar), Telefon(int), e-mail(varchar),adres(varchar) kolonlarına sahip olsun.  Kişiyle iletişime geçebilecek alanı çekmek istiyorsunuz fakat tablonuzda çok fazla eksikliklerin olduğunun farkındasınız. Bu örnekte coalesce fonksiyonunu kullanmanız gerekmektedir, yoksa içiçe isnull ya da nvl gibi fonksiyonlar kullanmanız gerekecekti;
-- COALESCE( Telefon , e-mail , adres , '-' )

-- NULLIF(Expression1, Expression2): returns NULL if 2 arguments are equal. otherwise it returns the 1st exp.
-- ISNUMERIC(Expression): determines whether an expression is a valid numeric type. numericse veya numerice dondurulebilecek bir cahr ise 1 yoksa 0 verir.

SELECT CAST(12345 AS CHAR);  -- ornegin rakamları str isimlerin yanına eklemek icin onnce castle str yapar snra ekleriz

SELECT CAST(123.95 AS INT);  -- output 123

SELECT CAST(123.95 AS DEC(3,0))  -- sadece 3 karakter olsun ve kesirli birsey olmasın.putput 124

SELECT 'customer' + '_' + CAST(1 AS VARCHAR(1)) AS customer_col;

---CONVERT
SELECT CONVERT(int, 30.60)  -- 30
SELECT CONVERT(VARCHAR(10), '2020-10-10') -- 2020-10-10 tarihi str'ye döndürdük
SELECT CONVERT(DATETIME, '2020-10-10')  -- date olarak istersek. output: 2020-10-10 00:00:00.000

SELECT CONVERT(varchar, '2017-08-25', 101);
SELECT CAST('2017-08-25' AS varchar);
-- date formatındaki bir veriyi char'a çevirdi.
SELECT CONVERT(datetime, '2017-08-25');
SELECT CAST('2017-08-25' AS datetime);
-- char formatındaki bir veriyi datetime'a çevirdi.
SELECT CONVERT(int, 25.65);
SELECT CAST(25.65 AS int);
-- decimal bir veriyi, integer'a (tam sayıya) çevirdi.
SELECT CONVERT(DECIMAL(5,2), 12) AS decimal_value;
SELECT CAST(12 AS DECIMAL(5,2) ) AS decimal_value;
-- integer bir veriyi 5 rakamdan oluşan ve bunun virgülden sonrası 2 rakam olan decimal'e çevirdi.
SELECT CONVERT(DECIMAL(7,2), ' 5800.79 ') AS decimal_value;
SELECT CAST(' 5800.79 ' AS DECIMAL (7,2)) AS decimal_value;
-- char (string) olan ama rakamdan oluşan veriyi decimal'e çevirdi.

-- CONCAT()

SELECT first_name + ' ' + last_name
FROM sale.customer;

SELECT CONCAT(first_name, ' ',last_name) as full_name
FROM sale.customer;

-- SQL SERVER DAtetime Formatting
-- Converting datetime to varchar

-- codelarla degitstirebiliyoruz. detailed info: https://www.mssqltips.com/sqlservertip/1145/date-and-time-conversions-using-sql-server/

SELECT CONVERT(VARCHAR, GETDATE(), 7)
SELECT CONVERT(NVARCHAR, GETDATE(), 100) --0 / 100
SELECT CONVERT(NVARCHAR, GETDATE(), 112)
SELECT CONVERT(NVARCHAR, GETDATE(), 113) --13 / 113
SELECT CAST('20201010' AS DATE)
SELECT CONVERT(NVARCHAR, CAST('20201010' AS DATE), 103)

-- ROUND(numeric_expression , length [ ,function ])

SELECT ROUND(123.4567, 2)  -- son 2 ondaligi sifir yapar oncesini yuvarlar
SELECT ROUND(123.4567, 2, 0)  -- son bir parametresi daha var, 
SELECT ROUND(123.4567, 2, 1)  -- son ikiyi 0 yapti ama ondalikli kisim olarak 2de kes, degistirme. 2de yuvarlama, kes direkt. yukardaki 46ya tamamlar, bu tamamlamaz

/*
Round 3 argüman alıyor:
ilki yuvarlayacağınız sayı
ikincisi ondalık kısımda kaç basamağa yuvarlamak istediğiniz
üçüncüsü opsiyonel, default' u 0.
default haliyle yuvarlama yaptığınızda yuvarlamayı yaptığınız son rakamın 5' ten büyük veya küçük olması durumuna göre aşağı veya yukarı yapar.
örn. round(888,786, 2) sonuç: 888,790
iki ondalık rakam alacağız ve 3. rakam 5' ten büyük. Bu durumda ikinci rakamı bir üst rakama yuvarlar.
opsiyonel argümanı 1 yaparsanız yuvarlama yapmadan istediğiniz rakam sayısı neyse o kadar ondalık rakamı döndürür.
Örn: round(888,786, 2, 1) sonuç: 888,780
*/

DECLARE @value decimal(10,2)
SET @value = 11.05
SELECT ROUND(@value, 1)  -- 11.10
SELECT ROUND(@value, -1) -- 10.00 
SELECT ROUND(@value, 2)  -- 11.05 
SELECT ROUND(@value, -2) -- 0.00 
SELECT ROUND(@value, 3)  -- 11.05
SELECT ROUND(@value, -3) -- 0.00
SELECT CEILING(@value)   -- 12 
SELECT FLOOR(@value)     -- 11 
GO

SELECT CONVERT(INT, 123.99999)  -- sonunda sifirlarla yuvarlama olsun istemiyorsak
SELECT CONVERT(DECIMAL(18,2), 123.4567)  --- 18 kismi tum rakamları ve decimaldeki rakamları sayar. 18 demek, virgul oncesi 18e kadar olabilir (garantiye almak icin), 2 ise virgul sonrasi 2 olsun

--  ISNUMERIC(expression): Returns 1 when the input expression evaluates to a valid numeric data type; otherwise it returns 0. Valid numeric data types are: bigint, int, smallint, tinyint, bit, decimal, numeric, float, real, money, smallmoney.

SELECT ISNUMERIC(1111111) -- 1
SELECT ISNUMERIC('1111111') -- 1
SELECT ISNUMERIC('ali') -- 0

SELECT ISNUMERIC(list_price) FROM sale.order_item;

-- COALESCE: ilk null olmayanı getirir

SELECT COALESCE(NULL, 'Hi', 'Hello', NULL) result;
SELECT COALESCE(NULL, NULL ,'Hi', 'Hello', NULL) result;
SELECT COALESCE(NULL, NULL ,'Hi', 'Hello', 100, NULL) result;
---This function doesn't limit the number of arguments, but they must all be of the same data type.
SELECT COALESCE(NULL, NULL) result;

-- ISNULL(): replaces NULL with a specified value

SELECT ISNULL(NULL, 1)
SELECT ISNULL(phone, 'no phone')
FROM sale.customer

---difference between coalesce and isnull
SELECT ISNULL(phone, 0)  -- bu str bir column. isnull 0'ı str olarak cevirdi ve islemi yapti
FROM sale.customer;

SELECT COALESCE(phone, 0) --ERROR. cunku 0 str degil farkli dtype. tüm columnu 0 ile degistirmek istedi
FROM sale.customer

-- NULLIF(expression, expression)
-- Returns a null value if the two specified expressions are equal. For example,

SELECT NULLIF(4,4) AS Same, NULLIF(5,7) AS Different;

-- We can use the NULLIF() function to find the product whose price does not change. 
SELECT NULLIF(10,10);  -- NULL
SELECT NULLIF('Hello', 'hi');  - Hello
SELECT NULLIF(2, '2');  -- kendi cevirdi ve NULL verdi

 ----- -------------PRACTICE
-- How many customers have yahoo mail?

SELECT email, PATINDEX('%yahoo%', email)  -- icinde yahoo olmayanları 0, olanların index no verdi.
FROM sale.customer;

-- filtreleyelim simdi
SELECT count(customer_id)  
FROM sale.customer
WHERE PATINDEX('%yahoo%', email) > 0;

-- Question 2: Write a query that returns the name of the streets where the third character of the street is numeric.

SELECT  street, SUBSTRING(street,3,1) as third_char
FROM sale.customer
WHERE ISNUMERIC(SUBSTRING(street,3,1)) = 1;

-- Question 3: Add a new column to the customers table that contains the customers' contact information. If the phone is not null, the phone information will be printed, if not, the email information will be printed.

SELECT phone, email, COALESCE(phone, email) as contact
FROM sale.customer;

-- Question 4: Split the email addresses into two parts from "@" and place them in separate columns.

SELECT email, 
        SUBSTRING(email,1,(CHARINDEX('@', email)-1)) as email_name,
        SUBSTRING(email,(CHARINDEX('@', email)+1), (LEN(email) - (CHARINDEX('@', email)))) as email_provider 
FROM sale.customer;
