--data cleaning in SQL

--###############replacing null, cleaning fields#####################

select *
from nashville_project.dbo.Sheet1$

---saledate has date and time, make it just date
select SaleDate, cast(SaleDate as date) as SaleDateConverted
from nashville_project.dbo.Sheet1$

--update nashville_project.dbo.Sheet1$
--set SaleDate=cast(SaleDate as date)

---fill the null values of propertyaddress
--same parcelID has same property address but unique id is different


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from nashville_project.dbo.Sheet1$ a
join nashville_project.dbo.Sheet1$ b
on a.ParcelID=b.ParcelID
where a.[UniqueID ] <> b.[UniqueID ]
and a.PropertyAddress is null

--update table 
update a
set a.PropertyAddress=isnull(a.PropertyAddress, b.PropertyAddress)
from nashville_project.dbo.Sheet1$ a
join nashville_project.dbo.Sheet1$ b
on a.ParcelID=b.ParcelID
where a.[UniqueID ] <> b.[UniqueID ]
and a.PropertyAddress is null


--split the address in address and city through comma.

--add blank fields first

alter table nashville_project.dbo.Sheet1$ 
add PropertySplitAddress nvarchar(255)

alter table nashville_project.dbo.Sheet1$ 
add PropertySplitCity nvarchar(255)

--add values in those fields
update nashville_project.dbo.Sheet1$ 
set PropertySplitAddress=substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)


update nashville_project.dbo.Sheet1$ 
set PropertySplitCity=substring(PropertyAddress,charindex(',',PropertyAddress)+1,len(PropertyAddress))

----owner address has address city and state. separate them
---use substring or parsename. parsename is easier.

select OwnerAddress,
PARSENAME(replace(owneraddress,',','.'),1),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),3)
from nashville_project.dbo.Sheet1$

--lets split them
alter table nashville_project.dbo.Sheet1$
add OwnerSplitCity nvarchar(255)

alter table nashville_project.dbo.Sheet1$
add OwnerSplitState nvarchar(255)

alter table nashville_project.dbo.Sheet1$
add OwnerSplitAddress nvarchar(255)

update nashville_project.dbo.Sheet1$
set OwnerSplitState=PARSENAME(replace(owneraddress,',','.'),1)

update nashville_project.dbo.Sheet1$
set OwnerSplitCity=PARSENAME(replace(owneraddress,',','.'),2)

update nashville_project.dbo.Sheet1$
set OwnerSplitAddress=PARSENAME(replace(owneraddress,',','.'),3)

--soldasvacant has Y,N, Yes and NO. replace Y with yes and n with No
--check distinct fields
select distinct(SoldAsVacant), count(soldasvacant)
from nashville_project.dbo.Sheet1$
group by SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant='N' then 'No'
when SoldAsVacant='Y' then 'Yes'
else SoldAsVacant
end
from nashville_project.dbo.Sheet1$

---update now 
update nashville_project.dbo.Sheet1$
set SoldAsVacant=
case when SoldAsVacant='N' then 'No'
when SoldAsVacant='Y' then 'Yes'
else SoldAsVacant
end

--############################ ---remove duplicates--##############################

--remove rows where parcelid, propertyaddress, saleprice, saledate, legalreference all together are same.
--this means same property is repeated.

--get count for repeated rows
select *,
row_number() 
over (partition by 
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by UniqueID) row_num
from nashville_project.dbo.Sheet1$

---create cte to get the count>1
;with Rowcte AS(
select *,
row_number() 
over (partition by 
ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by UniqueID) row_num
from nashville_project.dbo.Sheet1$
)

--as count>1 means repeating rows. Lets delete them
--delete
--from Rowcte
--where row_num>1

---#################--remove unused column--#####################

select * 
from nashville_project.dbo.Sheet1$

--Alter table nashville_project.dbo.Sheet1$
--drop column ownerAddress, PropertyAddress,TaxDistrict

--Alter table nashville_project.dbo.Sheet1$
--drop column SaleDate

