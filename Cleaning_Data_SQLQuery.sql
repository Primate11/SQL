--Testing Data cleaning in SQL

--Part I : Standardize Date Format

Select SaleDate, CONVERT(date, SaleDate) as SaleDate_Adj 
From PortfolioProject.dbo.Housing_Data_Clean 
 
ALTER TABLE Housing_Data_Clean
Add SaleDate_Adj Date ;

UPDATE Housing_Data_Clean
SET SaleDate_Adj = CONVERT(Date,SaleDate)

Select SaleDate,  SaleDate_Adj
From PortfolioProject.dbo.Housing_Data_Clean
GO

--PART II: Null Value - Property address
--Populating missing values with existing values

--A. Check FOR Null
Select  A.ParcelID,  A.PropertyAddress, B.ParcelID, B.PropertyAddress 
 From PortfolioProject.dbo.Housing_Data_Clean A
 JOIN PortfolioProject.dbo.Housing_Data_Clean B
      ON A.ParcelID = B.ParcelID
	  AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL
GO

--B.Replacing the Null value with address of the same ID
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
 From PortfolioProject.dbo.Housing_Data_Clean as A
 JOIN PortfolioProject.dbo.Housing_Data_Clean as B
      ON A.ParcelID = B.ParcelID
	  AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL
GO

--PARTIE III 
--Dividing a full adress into individual columns.
--In a database, each column should carry only 1 info
-- For this, we should seperate city from state from country

--Removing commas (,) by indexing the comma and then removing it with the rest of the text
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as 'Address'
From PortfolioProject.dbo.Housing_Data_Clean
--Going to the commas (,) 
-- Removing it with all text before the comma. 
Select 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as 'Address_II'
From PortfolioProject.dbo.Housing_Data_Clean
--ORDER BY ParcelID,PropertyAddress

--Adding the new valriable to the table
ALTER TABLE PortfolioProject.dbo.Housing_Data_Clean
ADD ProperAddress Nvarchar(255);
UPDATE PortfolioProject.dbo.Housing_Data_Clean
SET ProperAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE PortfolioProject.dbo.Housing_Data_Clean
ADD ProperCity Nvarchar(255)
;
UPDATE PortfolioProject.dbo.Housing_Data_Clean
SET ProperCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

Select * 
From PortfolioProject.dbo.Housing_Data_Clean
GO

--PARTIE IV
--Splitting data using PARSENAME
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

From PortfolioProject.dbo.Housing_Data_Clean


--Adding the new valriable to the table
ALTER TABLE PortfolioProject.dbo.Housing_Data_Clean
ADD Owner_Address Nvarchar(255);

UPDATE PortfolioProject.dbo.Housing_Data_Clean
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject.dbo.Housing_Data_Clean
ADD Owner_City Nvarchar(255);

UPDATE PortfolioProject.dbo.Housing_Data_Clean
SET Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject.dbo.Housing_Data_Clean
ADD Owner_State Nvarchar(255);

UPDATE PortfolioProject.dbo.Housing_Data_Clean
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select * 
From PortfolioProject.dbo.Housing_Data_Clean
GO

--PARTIE V
-- Changing values in a column to become uniform

-- A. Checking the values to see what's in the column
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.Housing_Data_Clean
Group by SoldAsVacant
Order by 2

--B. Updating the values y to yes , n to no
UPDATE PortfolioProject.dbo.Housing_Data_Clean
SET SoldAsVacant =
 CASE  When SoldAsVacant = 'Y' then 'Yes'
       When SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
 END
 GO

 -- PARTIE VI: Removing Duplicates
 -- A. Finding and removing the duplicate value using CTE, using primary key
 
 WITH row_num_cte AS(
 SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
              ORDER BY
	          UniqueID
			  ) as row_num

FROM PortfolioProject.dbo.Housing_Data_Clean
)
--SELECT *,
DELETE
 FROM row_num_cte
 WHERE row_num > 1
 --ORDER BY ParcelID
 GO

 --PARTIE VII
 -- Delecting / Dropping columns that are not useful

 ALTER TABLE PortfolioProject.dbo.Housing_Data_Clean
DROP COLUMN [OwnerAddress],[TaxDistrict],[PropertyAddress],[SaleDate]

Select * 
From PortfolioProject.dbo.Housing_Data_Clean


 --PARTIE VII
 --A. To check for irregularities in the IDs.
 SELECT 
    [UniqueID ],ParcelID,
	LEN([UniqueID ]) AS Nr_Letters_UID,
	LEN(ParcelID) AS Letters_in_PID
 FROM Housing_Data_Clean
 ORDER BY ParcelID,[UniqueID ]

 --B. Create a Unique ID USING BOTH IDs

 SELECT
 CONCAT(UniqueID,'-',ParcelID) as One_ID
 FROM Housing_Data_Clean
 ORDER BY One_ID

 ALTER TABLE Housing_Data_Clean
 ADD One_ID Nvarchar(255); 

 UPDATE Housing_Data_Clean
 SET One_ID = CONCAT(UniqueID,'-',ParcelID)
 
  GO

  --C. Managing Nulls values
  --Filling null with value from another column
  SELECT 
       COALESCE(ProperCity,Owner_Address) As One_City
  FROM Housing_Data_Clean

  GO 

 
