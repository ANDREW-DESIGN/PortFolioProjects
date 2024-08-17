select * from nashvillehousing;


--Populate property address 

select * 
from nashvillehousing
--where propertyaddress is null;
ORDER BY parcelid;


select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, NVL(a.propertyaddress,b.propertyaddress)
from nashvillehousing a
join nashvillehousing b
on a.parcelid = b.parcelid
and a.uniqueid_ <> b.uniqueid_
where a.propertyaddress is null;

update a
set propertyaddress = NVL(a.propertyaddress,b.propertyaddress)
from nashvillehousing a
join nashvillehousing b
on a.parcelid = b.parcelid
and a.uniqueid_ <> b.uniqueid_
where a.propertyaddress is null;





UPDATE nashvillehousing a
SET a.propertyaddress = (
    SELECT NVL(b.propertyaddress, a.propertyaddress)
    FROM nashvillehousing b
    WHERE a.parcelid = b.parcelid
    AND a.uniqueid_ <> b.uniqueid_
    AND b.propertyaddress IS NOT NULL
    
)
WHERE a.propertyaddress IS NULL;




-- Breaking out address into individual columns (Address, City, State)


select propertyaddress
from nashvillehousing;


select substr(propertyaddress, 1, instr(propertyaddress, ',')-1) as address,
substr(propertyaddress, instr(propertyaddress, ',')+1, length(propertyaddress)) as city
from nashvillehousing;



alter table nashvillehousing
add PropertySplitAddress varchar(255);

update nashvillehousing
set PropertySplitAddress = substr(propertyaddress, 1, instr(propertyaddress, ',')-1);



alter table nashvillehousing
add PropertySplitCity varchar(255);


update nashvillehousing
set PropertySplitCity = substr(propertyaddress, instr(propertyaddress, ',')+1, length(propertyaddress));


select * from nashvillehousing;



--splitting owneraddress into address, city, state

SELECT 
    REGEXP_SUBSTR(Owneraddress, '[^,]+', 1, 1) AS address,
    REGEXP_SUBSTR(Owneraddress, '[^,]+', 1, 2) AS city,
    REGEXP_SUBSTR(Owneraddress, '[^,]+', 1, 3) AS state
FROM 
    nashvillehousing;
    
    

alter table nashvillehousing
add OwnerSplitAddress varchar(255);

update nashvillehousing
set OwnerSplitAddress = REGEXP_SUBSTR(Owneraddress, '[^,]+', 1, 1);



alter table nashvillehousing
add OwnerSplitCity varchar(255);


update nashvillehousing
set OwnerSplitCity = REGEXP_SUBSTR(Owneraddress, '[^,]+', 1, 2);


alter table nashvillehousing
add OwnerSplitState varchar(255);

update nashvillehousing
set OwnerSplitState = REGEXP_SUBSTR(Owneraddress, '[^,]+', 1, 3);



--change y and n to yes and no in 'SOLDASVACANT'
SELECT DISTINCT(SOLDASVACANT), COUNT(SOLDASVACANT)
FROM NASHVILLEHOUSING
GROUP BY SOLDASVACANT
ORDER BY COUNT(SOLDASVACANT);


SELECT SOLDASVACANT,
CASE
WHEN SOLDASVACANT ='Y' THEN 'YES'
WHEN SOLDASVACANT ='N' THEN 'NO'
ELSE SOLDASVACANT
END
FROM NASHVILLEHOUSING;

UPDATE NASHVILLEHOUSING
SET SOLDASVACANT = CASE
WHEN SOLDASVACANT ='Y' THEN 'YES'
WHEN SOLDASVACANT ='N' THEN 'NO'
ELSE SOLDASVACANT
END;


--Remove Duplicates


WITH ROWNUMCTE AS (
    SELECT 
        PARCELID,
        PROPERTYADDRESS,
        SALEPRICE,
        SALEDATE,
        LEGALREFERENCE,
        UNIQUEID_,
        ROW_NUMBER() OVER (
            PARTITION BY PARCELID, PROPERTYADDRESS, SALEPRICE, SALEDATE, LEGALREFERENCE 
            ORDER BY UNIQUEID_
        ) AS row_num
    FROM nashvillehousing
)
SELECT *
FROM ROWNUMCTE
WHERE row_num > 1
ORDER BY PropertyAddress;


--deleting unused columns
select * from nashvillehousing;

ALTER TABLE NASHVILLEHOUSING
DROP (OwnerAddress, TAXDISTRICT, PROPERTYADDRESS);




















































