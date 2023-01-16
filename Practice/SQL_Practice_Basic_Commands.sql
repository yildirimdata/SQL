-- SQL BASIC COMMANDS PRACTICE
-- AdventureWorks2017 Dataset

SELECT TOP (1000) [DepartmentID]
      ,[Name]
      ,[GroupName]
      ,[ModifiedDate]
  FROM [AdventureWorks2017].[HumanResources].[Department]

--SELECT * INTO SALES.STOREINFO
-- FROM [AdventureWorks2017].[SALES].vStoreWithDemographics;

SELECT * FROM SALES.STOREINFO
WHERE BusinessEntityID = 294;

SELECT * FROM SALES.STOREINFO
WHERE NAME LIKE '%Bo%';

SELECT * FROM SALES.STOREINFO
WHERE NAME LIKE '%bike%';

SELECT * FROM SALES.STOREINFO
WHERE YearOpened > 1990;

SELECT * FROM SALES.STOREINFO
WHERE YearOpened < 1990;

SELECT * FROM SALES.STOREINFO
WHERE YearOpened BETWEEN 1990 AND 1996;

SELECT * FROM SALES.STOREINFO
WHERE YearOpened = 1990 and Name LIKE 'B%';

SELECT * FROM SALES.STOREINFO
WHERE YearOpened = 1990 OR Name LIKE 'B%';

SELECT * FROM SALES.STOREINFO
WHERE Internet IN ('DSL', 'T1');

-- how to update
UPDATE SALES.STOREINFO SET ANNUALSALES = ANNUALSALES*2
WHERE BusinessEntityId = 304;

SELECT BusinessEntityId, AnnualSales FROM SALES.STOREINFO
WHERE BusinessEntityId = 304;

-- how to delete
DELETE FROM Sales.storeinfo WHERE BusinessEntityId = 304;

SELECT BusinessEntityId, AnnualSales FROM SALES.STOREINFO
WHERE BusinessEntityId = 304;

-- DISTINCT

SELECT DISTINCT CustomerID
FROM Sales.Customer;

SELECT DISTINCT BankName 
FROM SALES.STOREINFO;

SELECT DISTINCT YearOpened
FROM Sales.StoreInfo;

SELECT DISTINCT Specialty
FROM Sales.StoreInfo;

SELECT DISTINCT BankName, Specialty
FROM Sales.StoreInfo;

-- ORDER BY

SELECT TOP 10 AnnualSales as asa
FROM Sales.StoreInfo
WHERE AnnualSales BETWEEN 1000000 AND 2500000
ORDER BY asa DESC;

SELECT * FROM Sales.StoreInfo
WHERE Specialty = 'Mountain'
ORDER BY AnnualSales; 

SELECT * FROM Sales.StoreInfo
WHERE Specialty = 'Mountain'
ORDER BY AnnualSales DESC; 

SELECT * FROM Sales.StoreInfo
WHERE Specialty = 'Mountain' AND NumberEmployees Between 20 AND 50
ORDER BY YearOpened DESC, Name;

-- AGGREGATE FUNCTIONS and GROUP BY

SELECT COUNT(*) as total_mountain_business,
MIN(AnnualSales) as min_sales,
MAX(AnnualSales) as max_sales,
AVG(AnnualSales) as avg_sales,
SUM(AnnualSales) as total_sales,
AVG(AnnualRevenue) as avg_income,
SUM(AnnualRevenue) as total_income
FROM Sales.StoreInfo
WHERE Specialty = 'Mountain';

SELECT DISTINCT Specialty FROM Sales.StoreInfo;

SELECT COUNT(*) as total_road_business,
MIN(AnnualSales) as min_sales,
MAX(AnnualSales) as max_sales,
AVG(AnnualSales) as avg_sales,
SUM(AnnualSales) as total_sales,
AVG(AnnualRevenue) as avg_income,
SUM(AnnualRevenue) as total_income
FROM Sales.StoreInfo
WHERE Specialty = 'Road';

SELECT Specialty, 
BusinessType,
COUNT(*) as total_business,
MIN(AnnualSales) as min_sales,
MAX(AnnualSales) as max_sales,
AVG(AnnualSales) as avg_sales,
SUM(AnnualSales) as total_sales,
AVG(AnnualRevenue) as avg_income,
SUM(AnnualRevenue) as total_income
FROM Sales.StoreInfo
GROUP BY Specialty, BusinessType
-- For a conditional selection in case of a group by query, instead of where we use having
HAVING AVG(AnnualSales) > 1000000
-- we can't use HAVING with alias of the related column. Error : HAVING avg_sales > 1000000 
ORDER BY Specialty, total_income;

-- Which banks are preferred by the companeies with highest sales
SELECT TOP 20 Name, 
BankName, 
SUM(AnnualSales) as total_sales,
SUM(AnnualRevenue) as total_income
FROM Sales.StoreInfo
GROUP BY Name, BankName
ORDER BY total_sales DESC; 


-- Which banks are preferred most?
SELECT BankName, COUNT(*) as Store_Count 
FROM Sales.StoreInfo
GROUP BY BankName
Order BY COUNT(*);

SELECT BankName, 
SUM(AnnualSales) as Annual_Sales,
COUNT(Name) as Store_Count 
FROM Sales.StoreInfo
GROUP BY BankName
Order BY Store_Count;

-- how many stores are there with different business types and which is most profitable
SELECT BusinessType,
AVG(AnnualRevenue) as avg_revenue,
COUNT(*) as Store_Count
FROM Sales.StoreInfo
GROUP BY BusinessType
Order BY avg_revenue DESC;

-- distribution of business types according to banks

SELECT BusinessType, BankName,
COUNT(BankName) as Number_Banks
FROM Sales.StoreInfo
GROUP BY BankName, BusinessType
ORDER BY Number_Banks;

-- how many types of brands do the stores sell in terms of specialty

SELECT Specialty, Brands,
COUNT(NAME) as number_of_stores, 
SUM(AnnualSales) as Annual_Sales
FROM Sales.StoreInfo
GROUP BY Specialty, Brands
ORDER BY Specialty, number_of_stores DESC;