/* Cleaning Data using SQL*/
Select * from [SQL Data Cleaning].dbo.[Nashville Housing]

--Q1)  Populate Property Address Data
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) 
from [SQL Data Cleaning].dbo.[Nashville Housing] a
join dbo.[Nashville Housing] b on
a.ParcelID=b.ParcelID AND 
a.UniqueID <> b.UniqueID
where a.PropertyAddress is null 

UPDATE a 
set PropertyAddress =ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM [SQL Data Cleaning].dbo.[Nashville Housing] a
join dbo.[Nashville Housing] b on
a.ParcelID=b.ParcelID AND 
a.UniqueID <> b.UniqueID
where a.PropertyAddress is null 

-- Q2) Breaking out Address into Individual columns(Address,City,State)
 
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) ,
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from [SQL Data Cleaning].dbo.[Nashville Housing] 
 
ALTER TABLE[SQL Data Cleaning].dbo.[Nashville Housing]
ADD Owner_Address Nvarchar(255);

UPDATE [SQL Data Cleaning].dbo.[Nashville Housing]
SET Owner_Address =PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE[SQL Data Cleaning].dbo.[Nashville Housing]
ADD Owner_City Nvarchar(255);

UPDATE [SQL Data Cleaning].dbo.[Nashville Housing]
SET Owner_City =PARSENAME(REPLACE(OwnerAddress,',','.'),2) 

ALTER TABLE[SQL Data Cleaning].dbo.[Nashville Housing]
ADD Owner_State Nvarchar(255);

UPDATE [SQL Data Cleaning].dbo.[Nashville Housing]
SET Owner_State =PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
-----------------------------------------------------------------------------
-- Q3) Change 0 and 1 in SoldAsVacant column to Yes and No

 select SoldAsVacant ,
 CASE  WHEN SoldAsVacant =1 THEN 'Yes'
WHEN SoldAsVacant=0 THEN 'No'
END  as SoldAsVacant_1
FROM dbo.[Nashville Housing]

Alter table [Nashville Housing]
Add Sold_As_Vacant Nvarchar(255)

Update [Nashville Housing]
set Sold_As_Vacant=CASE  WHEN SoldAsVacant =1 THEN 'Yes'
WHEN SoldAsVacant=0 THEN 'No'
END 


select distinct(SoldAsVacant) from dbo.[Nashville Housing]
Select * from [SQL Data Cleaning].dbo.[Nashville Housing]
  

 
--Q4)  Remove Duplicates

WITH Row_Num AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [SQL Data Cleaning].dbo.[Nashville Housing]
 )
Select *
From Row_Num
Where row_num > 1
Order by PropertyAddress






---------------------------------------------------------------------------------------------------------

--Q5) Delete Unused Columns

ALTER TABLE [SQL Data Cleaning].dbo.[Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--Q6) Trim data -This function removes leading and trailing spaces from a string.
--Remove spaces from owner city
SELECT TRIM(Owner_City) AS Owner_city_trim
FROM [SQL Data Cleaning].dbo.[Nashville Housing]
;

--Q7) UPPER and LOWER- These functions convert a string to uppercase or lowercase, respectively.

SELECT LOWER( LandUse) as lower_land_use,UPPER(LandUse) as upper_land_use from [SQL Data Cleaning].dbo.[Nashville Housing]

--Q8) REPLACE - This function replaces all occurrences of a specified substring with another substring.
SELECT LandUse, REPLACE(LandUse,'SINGLE FAMILY', 'DUPLEX') AS  Updated_landuse
FROM  [SQL Data Cleaning].dbo.[Nashville Housing];

--Q9)COALESCE- This function returns the first non-NULL expression from a list of expressions.

 
SELECT LandValue,COALESCE(LandValue,0) as LandValue_updated,  
TotalValue,COALESCE(TotalValue,0) as TotalValue_updated,
YearBuilt,COALESCE(YearBuilt,0) as YearBuilt_updated,
 Bedrooms,COALESCE(Bedrooms,0) as Bedrooms_updated,
HalfBath,COALESCE(HalfBath,0) as HalfBath_updated,
FullBath,COALESCE(FullBath,0) as FullBath_updated

FROM  [SQL Data Cleaning].dbo.[Nashville Housing]
 ;

--Q8) LEN FUNCTION - 
 Select OwnerName from [SQL Data Cleaning].dbo.[Nashville Housing]
 where LEN (OwnerName)>10
 
 --Q9)  ROUND, CEILING, and FLOOR
 SELECT Acreage, ROUND(Acreage,2) AS rounded_Acreage ,
  CEILING(Acreage) AS ceiling_Acreage ,
  FLOOR(Acreage) AS Floor_Acreage FROM [SQL Data Cleaning].dbo.[Nashville Housing] 

  --Q10) CAST and CONVERT - The CAST and CONVERT functions are used to change the data type of a value or column.
SELECT UniqueID , Acreage, CAST(Acreage AS INTEGER) AS  Acreage_as_int
FROM  [SQL Data Cleaning].dbo.[Nashville Housing]  

-- In many ways, they both do the exact same thing in a SELECT statement or stored procedure, but the SQL Server CONVERT function has an extra parameter to express style.

--The syntax is as follows:

--CAST(expression AS datatype(length))

-- CONVERT(datatype(length), expression, style)

SELECT CONVERT(VARCHAR(30),GETDATE(),110);
SELECT CONVERT(VARCHAR(30),GETDATE(),23);
--The number 23 is the style and it tells SQL Server how we want the string to be formatted. For example, if we use 110 we get a completely different formatting:


--Handling Missing Data
---Q11) Filtering NULL values
--NULL values can be used to represent missing data in SQL. To filter out rows with missing data, use the IS NULL or IS NOT NULL operators.
SELECT * FROM [SQL Data Cleaning].dbo.[Nashville Housing] WHERE OwnerName IS NULL;
 
 --The result of this query will be a table containing all the columns and only the rows where the specified column has a NULL value.



SELECT * FROM [SQL Data Cleaning].dbo.[Nashville Housing]

--  Removing Duplicate Rows
-- Q12) SELECT DISTINCT
-- SELECT DISTINCT  OwnerName,Acreage: This specifies that the query should return only unique combinations of OwnerName and Acreage values. By using the DISTINCT keyword, any duplicate rows with the same OwnerName,Acreage values are eliminated from the result.
SELECT DISTINCT OwnerName,Acreage
FROM [SQL Data Cleaning].dbo.[Nashville Housing]