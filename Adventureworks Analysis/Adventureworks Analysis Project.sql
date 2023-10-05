--Q1) Display all table names in the database

SELECT TABLE_NAME
FROM AdventureWorksDW2019.INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'

--Q2) Display total number of tables

SELECT count(TABLE_NAME) as Total_Tables
FROM AdventureWorksDW2019.INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'

--Q3) What is the total sales?
SELECT ROUND(SUM(SalesAmount), 2) AS [Total Sales]
FROM FactInternetSales

--Q4) What is the total profit?
SELECT ROUND((SUM(Salesamount) - SUM(totalproductcost)), 2) as [Total Profit]
FROM FactInternetSales

--Q5) What is the total cost amount?
SELECT ROUND(SUM(ProductStandardCost),2) [Cost Price]
FROM factinternetsales

--Q6) What is the sales per year?
SELECT CalendarYear AS Year, ROUND(SUM(SalesAmount), 2) AS [Total Sales]
FROM FactInternetSales  f
JOIN DimDate d ON d.DateKey = f.OrderDateKey
GROUP BY CalendarYear
ORDER BY [Total Sales] DESC

--Q7) What is the average sales per customers?
SELECT CONCAT(firstname,' ', LastName) AS [Customer Name], round(AVG(salesAmount),1) as AverageSales
FROM dimcustomer c
JOIN FactInternetSales s
ON c.CustomerKey = s.CustomerKey
GROUP BY CONCAT(firstname,' ', LastName)
ORDER BY [Customer Name]
 
--Q8) What is the number of products in each category?
SELECT Englishproductcategoryname [Product Category], COUNT( EnglishProductName) AS [Number of Products in Category]
FROM dimproductcategory c
  JOIN
 (SELECT EnglishProductName, productcategorykey
 FROM DimProduct p
 JOIN DimProductSubcategory ps
 ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
 GROUP BY EnglishProductName, ProductCategoryKey) ps
ON c.ProductCategoryKey = ps.ProductCategoryKey
GROUP BY  Englishproductcategoryname

--Q9) Show each country`s sales by customer age gap
WITH country_sales AS
(
select geo.EnglishCountryRegionName,DATEDIFF(month,BirthDate,OrderDate)/12 AS AGE,sale.SalesOrderNumber from AdventureWorksDW2019.dbo.FactInternetSales sale
JOIN AdventureWorksDW2019.dbo.DimCustomer cust 
ON sale.CustomerKey =cust.CustomerKey
JOIN AdventureWorksDW2019.dbo.DimGeography geo
ON cust.GeographyKey = geo.GeographyKey
)
SELECT  EnglishCountryRegionName,
       CASE WHEN AGE < 30 THEN 'a:Under 30'
	   WHEN AGE between 30 and 40 THEN 'b:30-40'
	   WHEN AGE between 40 and 50 THEN 'c:40-50'
	   WHEN AGE between 50 and 60 THEN 'd:50-60'
	   else 'OTHER'
	   END AS age_group,COUNT(SalesOrderNumber) as sales
	   from country_sales
	   group by  EnglishCountryRegionName,
       CASE WHEN AGE < 30 THEN 'a:Under 30'
	   WHEN AGE between 30 and 40 THEN 'b:30-40'
	   WHEN AGE between 40 and 50 THEN 'c:40-50'
	   WHEN AGE between 50 and 60 THEN 'd:50-60'
	   else 'OTHER'
	   END
	   ORDER BY EnglishCountryRegionName ,age_group

--Q10) Show each Product Sales by customer age gap
WITH country_sales AS
(
select  prod.EnglishProductName,sub.EnglishProductSubcategoryName,DATEDIFF(month,BirthDate,OrderDate)/12 AS AGE,sale.SalesOrderNumber from AdventureWorksDW2019.dbo.FactInternetSales sale
JOIN AdventureWorksDW2019.dbo.DimCustomer cust 
ON sale.CustomerKey =cust.CustomerKey
JOIN AdventureWorksDW2019.dbo.DimGeography geo
ON cust.GeographyKey = geo.GeographyKey
JOIN AdventureWorksDW2019.dbo.DimProduct prod
ON sale.ProductKey = prod.ProductKey
JOIN AdventureWorksDW2019.dbo.DimProductSubcategory sub
ON prod.ProductSubcategoryKey = sub.ProductCategoryKey

)
    SELECT   EnglishProductSubcategoryName as product_type,
       CASE WHEN AGE < 30 THEN 'a:Under 30'
	   WHEN AGE between 30 and 40 THEN 'b:30-40'
	   WHEN AGE between 40 and 50 THEN 'c:40-50'
	   WHEN AGE between 50 and 60 THEN 'd:50-60'
	   else 'OTHER'
	   END AS age_group,COUNT(SalesOrderNumber) as sales
	   from country_sales
	   group by EnglishProductSubcategoryName,
       CASE WHEN AGE < 30 THEN 'a:Under 30'
	   WHEN AGE between 30 and 40 THEN 'b:30-40'
	   WHEN AGE between 40 and 50 THEN 'c:40-50'
	   WHEN AGE between 50 and 60 THEN 'd:50-60'
	   else 'OTHER'
	   END
	   ORDER BY product_type ,age_group

--Q11) Show monthly sales for Australia and USA compared for the year 2012
select SUBSTRING(CAST(OrderDateKey AS char),1,6) as OrderDateKey,SalesOrderNumber,OrderDate,sale_terr.SalesTerritoryCountry
from AdventureWorksDW2019.dbo.FactInternetSales sale
JOIN  AdventureWorksDW2019.dbo.DimSalesTerritory sale_terr
ON sale.SalesTerritoryKey = sale_terr.SalesTerritoryKey
WHERE sale_terr.SalesTerritoryCountry in ('Australia',' United States')
AND SUBSTRING(CAST(OrderDateKey AS char),1,4) = '2012'

--Q12) Display each products first re-order date
WITH products as (
select [EnglishProductName],orderdatekey,[SafetyStockLevel] ,[ReorderPoint] ,SUM(sale.OrderQuantity) AS sales
from AdventureWorksDW2019.dbo.DimProduct prod
JOIN AdventureWorksDW2019.dbo.FactInternetSales sale
ON sale.ProductKey = prod.ProductKey
GROUP BY [EnglishProductName],[SafetyStockLevel] ,[ReorderPoint] ,orderdatekey
)
select *,sum(sales)OVER(PARTITION BY [EnglishProductName] ORDER BY Orderdatekey) as Running_total_sales
from products
group by [EnglishProductName],orderdatekey,[SafetyStockLevel] ,[ReorderPoint] ,sales

--Q13) Show all sales on promotion and add a column showing their new sales value if 25%  discount is applied

SELECT sale.OrderDate, s.SalesReasonName,sale.SalesOrderNumber,sale.SalesAmount ,round((SalesAmount*0.75),2) AS sales_amount_after_discount
FROM AdventureWorksDW2019.dbo.FactInternetSales sale 
JOIN AdventureWorksDW2019.dbo.FactInternetSalesReason sales_re
ON sale.SalesOrderNumber = sales_re.SalesOrderNumber
JOIN AdventureWorksDW2019.dbo.DimSalesReason s 
ON sales_re.SalesReasonKey = s.SalesReasonKey
WHERE SalesReasonName = 'On Promotion'

--Q14) Show each customerkey,the sales value of their first sale,and the sales value of their last sale.Also show difference between the two 
WITH first_purchase as(
SELECT CustomerKey,SalesAmount,OrderDate,
row_number()over(PARTITION BY CustomerKey ORDER BY OrderDate asc ) as purchase_num
from AdventureWorksDW2019.dbo.FactInternetSales),

last_purchase as(
SELECT CustomerKey,SalesAmount,OrderDate,
row_number()over(PARTITION BY CustomerKey ORDER BY OrderDate desc ) as purchase_num
from AdventureWorksDW2019.dbo.FactInternetSales
)
select customerkey,sum(first_purchase_value) as first_purchase_value ,sum(last_purchase_value) as last_purchase_value,(sum(last_purchase_value)-sum(first_purchase_value)) as change
from
(select customerkey,SalesAmount as first_purchase_value,null as last_purchase_value from first_purchase where purchase_num =1
union all 
select customerkey,null as first_purchase_value,SalesAmount as last_purchase_value  from last_purchase where purchase_num =1) main_sql
group by CustomerKey
having (sum(last_purchase_value)-sum(first_purchase_value)) <> 0
order by CustomerKey

--Q15) Top 10 Customers with the highest purchase
 
 SELECT TOP 10 firstname + ' ' + lastname AS [Customer Name], ROUND(SUM(SalesAmount), 2) as [Total Sales]
FROM DimCustomer d
JOIN FactInternetSales f ON f.CustomerKey = d.CustomerKey
GROUP BY firstname + ' ' + lastname
ORDER BY [Total Sales] DESC

--Q16) Top 10 Customers with the highest order
SELECT TOP 10 CONCAT(firstname, ' ',  lastname) as [Customer Name], SUM(orderquantity) as Orders
FROM FactInternetSales f
JOIN DimCustomer c ON c.CustomerKey = f.CustomerKey
GROUP BY CONCAT(firstname, ' ', lastname)
ORDER BY Orders DESC

--Q17) Top 10 Employees with the highest sale
SELECT TOP 10 FirstName + ' ' + LastName as [Empolyee Name], 
SalesTerritoryCountry AS [Sales Country], ROUND(SUM(salesamount), 2) as [Total Sales]
FROM FactInternetSales AS f
JOIN DimSalesTerritory AS t 
ON f.SalesTerritoryKey = t.SalesTerritoryKey
JOIN DimEmployee AS e 
ON e.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY SalesTerritoryCountry, FirstName + ' ' + LastName
ORDER BY [Total Sales] DESC

--Q10. Top 10 most sale products
SELECT TOP 10 EnglishProductName AS Product, EnglishProductCategoryName AS Category,
ps.EnglishProductSubcategoryName AS [Product Subcategory], 
ROUND(SUM(SalesAmount), 2) AS Sales
from FactInternetSales AS f
INNER JOIN DimProduct AS p ON f.ProductKey =p.ProductKey 
INNER JOIN DimProductSubcategory AS ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
INNER JOIN DimProductCategory pc ON pc.ProductCategoryKey = ps.ProductCategoryKey
GROUP BY EnglishProductName, EnglishProductCategoryName, EnglishProductSubcategoryName
ORDER BY  Sales DESC

 
