--SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Portfolio project].[dbo].[Nashvillehousing]


  SELECT *
  FROM Nashvillehousing

  --Standardizing date format

  SELECT SaleDate1
  FROM Nashvillehousing


  ALTER TABLE  Nashvillehousing
  ADD SaleDate1 Date;

  UPDATE Nashvillehousing
  SET SaleDate1=CONVERT(Date,SaleDate)

  --Property address data

  SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
  FROM Nashvillehousing a
  JOIN  Nashvillehousing b
   on a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashvillehousing a
  JOIN  Nashvillehousing b
   on a.ParcelID=b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]

--Address in individual columns

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as address
  FROM Nashvillehousing
  ALTER TABLE  Nashvillehousing
  ADD PropertyAddress1 NVARCHAR(255);

  UPDATE Nashvillehousing
  SET PropertyAddress1=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

  ALTER TABLE  Nashvillehousing
  ADD City NVARCHAR(255);

  UPDATE Nashvillehousing
  SET City= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

  SELECT*
  FROM Nashvillehousing

  SELECT OwnerAddress
  FROM Nashvillehousing

  SELECT 
  PARSENAME(REPLACE(OwnerAddress,',','.'),3)
  ,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
  ,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
  From Nashvillehousing

   ALTER TABLE  Nashvillehousing
  ADD Ownersplitaddress NVARCHAR(255);

  UPDATE Nashvillehousing
  SET Ownersplitaddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)
   ALTER TABLE  Nashvillehousing
  ADD Ownersplitcity NVARCHAR(255);

  UPDATE Nashvillehousing
  SET Ownersplitcity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)
   ALTER TABLE  Nashvillehousing
  ADD Ownersplitstate NVARCHAR(255);

  UPDATE Nashvillehousing
  SET Ownersplitstate=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

  ---Yes/No

  SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
  From Nashvillehousing
  GROUP BY SoldAsVacant
  ORDER BY 2 DESC

  SELECT SoldAsVacant
  ,CASE WHEN SoldAsVacant='Y' THEN 'Yes'
        WHEN SoldAsVacant='N' THEN 'No'
		ELSE SoldAsVacant
		END
  FROM Nashvillehousing

  UPDATE Nashvillehousing
  SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
        WHEN SoldAsVacant='N' THEN 'No'
		ELSE SoldAsVacant
		END

	--Remove Duplicates
	WITH rownumcte as(
	 SELECT *,
	 ROW_NUMBER() OVER(
	 PARTITION BY ParcelID,
	 PropertyAddress,
	 SalePrice,
	 SaleDate,
	 LegalReference
	 ORDER BY 
	 UniqueID) row_number
  FROM Nashvillehousing)
  
  SELECT *
  FROM rownumcte
  WHERE row_number>1
  ORDER BY PropertyAddress

  DELETE
  FROM rownumcte
  WHERE row_number>1
  --ORDER BY PropertyAddress

  --DELETE UNUSED COLUMNS

ALTER TABLE Nashvillehousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

SELECT *
FROM Nashvillehousing