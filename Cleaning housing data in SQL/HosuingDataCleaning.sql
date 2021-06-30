
--Data Cleaning in SQL

select * 
from HousingProject.dbo.NashvilleHousing

--Standardize date fromat
select SaleDate, convert(date, SaleDate)
from HousingProject.dbo.NashvilleHousing

alter table HousingProject.dbo.NashvilleHousing
add SaleDateConverted date;

update HousingProject.dbo.NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

select SaleDateConverted
from HousingProject.dbo.NashvilleHousing


--Fill Property Address

select *
from HousingProject.dbo.NashvilleHousing
where PropertyAddress is null

select *
from HousingProject.dbo.NashvilleHousing
order by ParcelID

select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, isnull(A.PropertyAddress, B.PropertyAddress)
from HousingProject.dbo.NashvilleHousing A
join HousingProject.dbo.NashvilleHousing B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null

update A
Set PropertyAddress = isnull(A.PropertyAddress, B.PropertyAddress)
from HousingProject.dbo.NashvilleHousing A
join HousingProject.dbo.NashvilleHousing B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null



-- Seprating Adress, City, and State in seperate columns

select PropertyAddress
from HousingProject.dbo.NashvilleHousing

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as Address,
substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress)) as City
from HousingProject.dbo.NashvilleHousing

alter table NashvilleHousing
add Address nvarchar(255);

update HousingProject.dbo.NashvilleHousing
set Address = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

alter table NashvilleHousing
add City nvarchar(255);

update HousingProject.dbo.NashvilleHousing
set City = substring(PropertyAddress, charindex(',', PropertyAddress) + 1, len(PropertyAddress))

select *
from HousingProject.dbo.NashvilleHousing


select OwnerAddress
from HousingProject.dbo.NashvilleHousing

Select
parsename(replace(OwnerAddress, ',', '.'),3),
parsename(replace(OwnerAddress, ',', '.'),2),
parsename(replace(OwnerAddress, ',', '.'),1)
from HousingProject.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255),
OwnerCity nvarchar(255),
OwnerState nvarchar(255);

update HousingProject.dbo.NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'),3),
OwnerCity = parsename(replace(OwnerAddress, ',', '.'),2),
OwnerState = parsename(replace(OwnerAddress, ',', '.'),1)

select *
from HousingProject.dbo.NashvilleHousing



--Change Y and N to 'Yes' and 'No' in SoldAsVacant Column

select distinct(SoldAsVacant), count(SoldAsVacant)
from HousingProject.dbo.NashvilleHousing
group by SoldAsVacant


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from HousingProject.dbo.NashvilleHousing


update HousingProject.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


-- Removing Duplicates

with RowNumCTE as(
select *, 
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					uniqueID
					) row_num
from HousingProject.dbo.NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


with RowNumCTE as(
select *, 
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					uniqueID
					) row_num
from HousingProject.dbo.NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1



-- Remove Unused Columns

select *
from HousingProject.dbo.NashvilleHousing

alter table HousingProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table HousingProject.dbo.NashvilleHousing
drop column SaleDate

