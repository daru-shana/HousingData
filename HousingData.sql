/*

Cleaning Data in SQL Queries

*/
use HouseData;

select *from HousingData

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate, convert(Date, SaleDate)
from HousingData

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from HousingData
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from HousingData a inner join HousingData b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
from HousingData a inner join HousingData b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From HousingData

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
From HousingData


ALTER TABLE HousingData
Add PropertySplitAddress Nvarchar(255);

Update HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE HousingData
Add PropertySplitCity Nvarchar(255);

Update HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select *
from HousingData

Select OwnerAddress
From HousingData

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From HousingData

ALTER TABLE HousingData
Add OwnerSplitAddress Nvarchar(255);

Update HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE HousingData
Add OwnerSplitCity Nvarchar(255);

Update HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE HousingData
Add OwnerSplitState Nvarchar(255);

Update HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From HousingData

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HousingData
Group by SoldAsVacant
order by 2

alter table HousingData 
alter column SoldAsVacant char(10);

Select SoldAsVacant
, CASE When SoldAsVacant = '1' THEN 'Yes'
	   When SoldAsVacant = '0' THEN 'No'
	   ELSE SoldAsVacant
	   END
From HousingData

Update HousingData
SET SoldAsVacant = CASE When SoldAsVacant = '0' THEN 'Yes'
	   When SoldAsVacant = '1' THEN 'No'
	   ELSE SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE As(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID) row_num
from HousingData)
select * from RowNumCTE
where row_num > 1


WITH RowNumCTE As(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID) row_num
from HousingData)
DELETE
from RowNumCTE
where row_num > 1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From HousingData


ALTER TABLE HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-----------------------------------------------------------------------------------------------
















