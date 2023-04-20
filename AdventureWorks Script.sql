
-- Cleansed DIM_Date Table --
SELECT 
  DateKey, 
  FullDateAlternateKey AS Date, 
  EnglishDayNameOfWeek AS Day, 
  EnglishMonthName AS Month, 
  Left(EnglishMonthName, 3) AS MonthShort,   
  MonthNumberOfYear AS MonthNo, 
  CalendarQuarter AS Quarter, 
  CalendarYear AS Year 
FROM 
 AdventureWorksDW2019.dbo.DimDate
WHERE 
  CalendarYear >= 2019


-- Cleansed DIM_Customers Table --
SELECT 
  c.customerkey AS CustomerKey, 
  c.firstname AS [First Name], 
  c.lastname AS [Last Name], 
  c.firstname + ' ' + lastname AS [Full Name], 
  CASE c.gender WHEN 'M' THEN 'Male' 
				WHEN 'F' THEN 'Female' 
				END AS Gender,
  c.datefirstpurchase AS DateFirstPurchase, 
  g.city AS [Customer City] -- Joined in Customer City from Geography Table
FROM 
  AdventureWorksDW2019.dbo.DimCustomer c
  LEFT JOIN dbo.dimgeography g 
  ON g.geographykey = c.geographykey 

-- Cleansed DIM_Products Table --

SELECT 
  p.ProductKey, 
  p.ProductAlternateKey AS ProductItemCode, 
  p.EnglishProductName AS [Product Name], 
  ps.EnglishProductSubcategoryName AS [Sub Category], -- Joined in from Sub Category Table
  pc.EnglishProductCategoryName AS [Product Category], -- Joined in from Category Table
  p.Color AS [Product Color], 
  p.Size AS [Product Size], 
  p.ProductLine AS [Product Line], 
  p.ModelName AS [Product Model Name], 
  p.EnglishDescription AS [Product Description], 
  ISNULL (p.Status, 'Outdated') AS [Product Status] 
FROM 
  AdventureWorksDW2019.dbo.DimProduct p
  LEFT JOIN dbo.DimProductSubcategory ps 
  ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey 
  LEFT JOIN dbo.DimProductCategory pc 
  ON ps.ProductCategoryKey = pc.ProductCategoryKey 
order by 
  p.ProductKey asc

  -- Cleansed FACT_InternetSales Table --
  -- This could have completed this in a few different ways but thought competency using CTE may be useful to see--

WITH [Total Revenue CTE] as (
SELECT SUM(((SalesAmount - TotalProductCost) - TaxAMT) - Freight) as TotalRevenue,
			SalesOrderNumber
FROM   AdventureWorksDW2019.dbo.FactInternetSales
GROUP BY SalesOrderNumber
),
[Cleansed Sales CTE] as (
SELECT 
  ProductKey, 
  SalesOrderNumber,
  OrderDateKey, 
  DueDateKey, 
  ShipDateKey, 
  CustomerKey,  
  SalesAmount
FROM 
  AdventureWorksDW2019.dbo.FactInternetSales
WHERE 
LEFT(OrderDateKey, 4) >= 2019 -- Ensures we always only bring up the last five years of date from extraction.
)
SELECT *
FROM [Cleansed Sales CTE] CS
JOIN [Total Revenue CTE] TR
ON CS.SalesOrderNumber = TR.SalesOrderNumber


