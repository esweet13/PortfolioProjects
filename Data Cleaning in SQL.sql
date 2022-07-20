/* Cleaning Data In SQL */

Select * 
From PortfolioProject.nashville_housing;

/* Standardize Sales Date */

SET SQL_SAFE_UPDATES=0;

Alter Table nashville_housing
Add SaleDateConverted Date;

Update PortfolioProject.nashville_housing
Set SaleDateConverted = Convert(SaleDate, Date);

Select SaleDateConverted
From nashville_housing;

/* Populate Property Address Data */

Select *
From nashville_housing
/* Where PropertyAddress = '' */
Order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
From nashville_housing a
Join nashville_housing b
	on a.ParcelID = b.ParcelID
    And a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null;

Update PortfolioProject.nashville_housing a
Join PortfolioProject.nashville_housing b
	on a.ParcelID = b.ParcelID
    And a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
Where a.PropertyAddress is null;

/* Breaking Out Address Into Individual Columns (Address, City, State) */

Select PropertyAddress
From nashville_housing
/* Where PropertyAddress is null 
Order by ParcelID */;

SELECT
substring(PropertyAddress, 1, locate(',', PropertyAddress) -1) as Address, substring(PropertyAddress, locate(',', PropertyAddress) +1, length(PropertyAddress)) as Address
FROM nashville_housing;

Alter Table nashville_housing
Add Property_Split_Address varchar(255);

Update PortfolioProject.nashville_housing
Set Property_Split_Address = substring(PropertyAddress, 1, locate(',', PropertyAddress) -1);

Alter Table nashville_housing
Add Property_Split_City varchar(255);

Update PortfolioProject.nashville_housing
Set Property_Split_City = substring(PropertyAddress, locate(',', PropertyAddress) +1, length(PropertyAddress));


Select OwnerAddress
From nashville_housing;

Select
substring_index(OwnerAddress, ',', 1),
substring_index(substring_index(OwnerAddress, ',', 2), ',', -1),
substring_index(substring_index(OwnerAddress, ',', -1), ',', 1)
From nashville_housing;


Alter Table nashville_housing
Add Owner_Split_Address varchar(255);

Update PortfolioProject.nashville_housing
Set Owner_Split_Address = substring_index(OwnerAddress, ',', 1);

Alter Table nashville_housing
Add Owner_Split_City varchar(255);

Update PortfolioProject.nashville_housing
Set Owner_Split_City = substring_index(substring_index(OwnerAddress, ',', 2), ',', -1);

Alter Table nashville_housing
Add Owner_Split_State varchar(255);

Update PortfolioProject.nashville_housing
Set Owner_Split_State = substring_index(substring_index(OwnerAddress, ',', -1), ',', 1);

/* Change Y and N to Yes and No in 'Sold as Vacant' field */

Select distinct(SoldAsVacant), count(SoldAsVacant)
From nashville_housing
Group By SoldAsVacant
Order By 2;

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
    Else SoldAsVacant
    END
From nashville_housing;

Update nashville_housing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
    Else SoldAsVacant
    END;
    
    
/* Delete Unused Columns */

Alter Table PortfolioProject.nashville_housing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

Alter Table PortfolioProject.nashville_housing
DROP COLUMN SaleDate;

Select *
From nashville_housing;