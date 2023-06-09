select *
from NashvilleHousing

----------------------------------------------

-- Standardize Date Format

select SaleDateConverted,SaleDate
from NashvilleHousing



update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate)


alter table NashvilleHousing
add SaleDateConverted Date;


update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)


-------------------

-- Populate Property Addres Data

Select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a 
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a 
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-----------------------

-- Breaing out Addres into Individual Columns ( Address, City, State )

Select PropertyAddress
from NashvilleHousing


select
SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
from NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
from NashvilleHousing



Select OwnerAddress
from NashvilleHousing


select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From NashvilleHousing


--------------------------------------------

-- Change Y and N to Yes and No in "solid as Vacant" Field

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
	end
from NashvilleHousing


Update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
	end




----------------------------------

-- Remove Duplicates

with RowNUMCTE as (
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference 
				Order by UniqueID ) row_num 
from NashvilleHousing
--order by ParcelID
)
Select *
from RowNUMCTE
where row_num > 1

----------------------

-- Delete Unused Columns

select *
from NashvilleHousing


alter table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress


alter table NashvilleHousing
Drop Column SaleDate
