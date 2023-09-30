/*
Cleaning Data in Sql Queries
*/


USE PortfolioProject

SELECT *
FROM NashvilleHousing

------------------------------------------------------------------------------------------------------

--Standardize Date Format--

SELECT SaleDate, CONVERT(DATE, SaleDate) AS SaleDate
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate2 = CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDate2 Date

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

EXEC sp_rename 'NashvilleHousing.saleDate2', 'SaleDate', 'COLUMN'

------------------------------------------------------------------------------------------------------

--Populate Property Address date--

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT a.parcelID, a.propertyaddress, b.parcelID, b.PropertyAddress, 
ISNULL(a.propertyaddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.parcelID = b.parcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.propertyaddress is NULL


UPDATE a
SET a.Propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.parcelID = b.parcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.propertyaddress is NULL


---------------------------------------------------------------------------------------

--Breaking out Address into individual columns (Address, City, State)--

--Property Address--

SELECT *--Propertyaddress
FROM NashvilleHousing


SELECT SUBSTRING(Propertyaddress, 1, CHARINDEX(',', Propertyaddress) -1) AS Address,
   SUBSTRING(Propertyaddress,CHARINDEX(',', Propertyaddress) +1, LEN(Propertyaddress)) AS Address
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertyAddress1 NVARCHAR(255),
 PropertyCity NVARCHAR (255)


UPDATE NashvilleHousing
SET PropertyAddress1 = SUBSTRING(Propertyaddress, 1, CHARINDEX(',', Propertyaddress) -1),
 PropertyCity = SUBSTRING(Propertyaddress,CHARINDEX(',', Propertyaddress) +1, LEN(Propertyaddress))


--Owner Address--

SELECT *-- OwnerAddress
FROM  NashvilleHousing

SELECT
  PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3),
  PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2),
  PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)
 FROM NashvilleHousing


ALTER TABLE NashvilleHousing
 ADD OwnerAddress1 NVARCHAR(255),
     OwnerCity NVARCHAR(255),
	 OwnerState NVARChAR(255)


UPDATE NashvilleHousing
SET OwnerAddress1 = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 3),
    OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 2),
	OwnerState =   PARSENAME(REPLACE(OwnerAddress, ',' , '.') , 1)

-----------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Solid as Vecant" field--

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT Soldasvacant,
   CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsvacant = 'N' THEN 'No'
        ELSE SoldAsVacant
   END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant =  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                         WHEN SoldAsvacant = 'N' THEN 'No'
                         ELSE SoldAsVacant
                    END

---------------------------------------------------------------------------------------------

--Remove Duplicates--

WITH Row_NumCTE AS(
SELECT *,
   ROW_NUMBER() OVER(
     PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  saleDate,
				  LegalReference
				  ORDER BY
				      UniqueID
					) row_num
FROM NashvilleHousing
--ORDER BY ParcelID 
)

DELETE FROM Row_NumCTE
WHERE Row_Num > 1
--ORDER BY PropertyAddress
---------------------------------------------------------------------------------------------------

--Delete Unused Columns & Rename--

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


EXEC sp_rename 'NashvilleHousing.PropertyAddress1' , 'PropertyAddress' , 'COLUMN'

EXEC sp_rename 'NashvilleHousing.OwnerAddress1' , 'OwnerAddress' , 'COLUMN'


SELECT * FROM NashvilleHousing;
