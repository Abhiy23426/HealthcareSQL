create database if not exists Healthcare;
-- import all tables
-- 'TATHLGP21004V032122' 
-- 'SHAHLGP22134V012122' 
-- these two are duplicate keys in insurance plan


-- '3287-4212' duplicate key in keep table
-- there are too many duplicate values in keep table

-- import keep table without primary key constraint

-- another table keep2, taking only unique values from keep table

create table Keep2 ( select pharmacyID, medicineID, quantity, discount 
from (select *,  row_number() over(partition by pharmacyID,medicineID order by pharmacyID,medicineID) as rn from keep) as k where rn = 1);


-- add primary key constraint on keep2 table
alter table keep2 add constraint primary key (pharmacyID,medicineID);

-- drop keep table
drop table keep;

-- rename keep2 to keep
alter table keep2 rename Keep;

