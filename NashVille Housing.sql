-- First View the data

Select *
from NashVilleHousing

-- Change SaleDate from datetime to date

Select SaleDate
from NashVilleHousing

Alter Table NashVilleHousing
Alter Column SaleDate date

--Property Address

Select*
from NashVilleHousing
where PropertyAddress is null
order by parcelID


Select nvha.parcelID, nvha.PropertyAddress, nvhb.parcelID, nvhb.PropertyAddress --ISNULL(nvha.PropertyAddress, nvhb.PropertyAddress)
from NashVilleHousing as nvha
join NashVilleHousing as nvhb
on nvha.parcelID = nvhb.parcelID
AND nvha.UniqueID <> nvhb.UniqueID
--where nvha.PropertyAddress is null

update nvha
set PropertyAddress = ISNULL(nvha.PropertyAddress, nvhb.PropertyAddress)
from NashVilleHousing as nvha
join NashVilleHousing as nvhb
on nvha.parcelID = nvhb.parcelID
AND nvha.UniqueID <> nvhb.UniqueID
where nvha.PropertyAddress is null


--Breaking Out Address Into individual column

Select PropertyAddress
from NashVilleHousing

Select SUBSTRING(propertyAddress, 1, charindex(',', PropertyAddress)-1)
from NashVilleHousing

Select SUBSTRING(propertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))
from NashVilleHousing

ALTER TABLE NashVilleHousing
ADD SplitAddress varchar(255)

update NashVilleHousing
set SplitAddress = SUBSTRING(propertyAddress, 1, charindex(',', PropertyAddress)-1)

ALTER TABLE NashVilleHousing
ADD SplitCity varchar(255)

update NashVilleHousing
set SplitCity = SUBSTRING(propertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

select *
from NashVilleHousing

select SplitCity, Count(SplitCity)
from NashVilleHousing
group by SplitCity


select OwnerAddress
from NashVilleHousing


select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashVilleHousing

ALTER TABLE NashVilleHousing
ADD SplitOwnerAddress varchar(255)

update NashVilleHousing
set SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashVilleHousing
ADD SplitOwnerCity varchar(255)

update NashVilleHousing
set SplitOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashVilleHousing
ADD SplitOwnerState varchar(255)

update NashVilleHousing
set SplitOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


select * 
from NashVilleHousing

--Changing Y or N to Yes or No

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashVilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from NashVilleHousing

update NashVilleHousing
set SoldAsVacant = case
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end


-- Removing Duplicates

select *
from [Portfolio Project].dbo.NashVilleHousing

--CTE

with dupes
AS(
select *,
ROW_NUMBER() over (Partition by
PropertyAddress,
ParcelID,
SaleDate,
SalePrice,
LegalReference
order by UniqueID
) as row_num
from [Portfolio Project].dbo.NashVilleHousing
)

select *
from dupes
where row_num > 1

--Deleting Columns

select *
from [Portfolio Project].dbo.NashVilleHousing

alter table NashVilleHousing
drop column PropertyAddress, OwnerAddress