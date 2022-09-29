
--Preview data

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Standadize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--- -------------------------------------------------------------------------------------------------

--Populate Property Address Data

SELECT *   --Checking for reference point to populate null values
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

--Self join to select null property address values and add column with selected reference address from matching ParcelID
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--updated table to replace null property values
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


---------------------------------------------------------------------------------------------------

-- Breaking out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress 
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

-- Separated street name and city into two columns using substring
SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX( ',' ,PropertyAddress) - 1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX( ',' ,PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing

-- Added new columns to table and updated them with split address data
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX( ',' ,PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX( ',' ,PropertyAddress) + 1, LEN(PropertyAddress))




-- Splitting owner address

Select OwnerAddress
FROM PortfolioProject..NashvilleHousing

Select
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Street,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM PortfolioProject..NashvilleHousing


--Creating new columns for street,city, and state and updating values
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



---------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Find where soldasvacant is y or n and replace with yes or no
SELECT
  CASE	
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END AS UpdatedSoldAsVacant
FROM PortfolioProject..NashvilleHousing

--Updated table with new values

UPDATE NashvilleHousing
SET SoldAsVacant =  CASE	
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END
  


  ---------------------------------------------------------------------------------------------------

  -- Remove Duplicates
-- Use cte to create column that marks duplicate rows
WITH RowNumCTE AS (
SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
			   PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY 
			     UniqueId
				 ) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
-- delete rows where row_num greater than 1
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--Check to see if duplicate rows were deleted
WITH RowNumCTE AS (
SELECT *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
			   PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY 
			     UniqueId
				 ) row_num
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1




 ---------------------------------------------------------------------------------------------------
 
 --Delete Unsused Columns

 ALTER TABLE PortfolioProject..NashvilleHousing
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress 

 ALTER TABLE PortfolioProject..NashvilleHousing
 DROP COLUMN SaleDate
 
 SELECT *
 FROM PortfolioProject..NashvilleHousing


