/* Problem Statement 1: 
 “HealthDirect” pharmacy finds it difficult to deal with 
the product type of medicine being displayed in numerical form, 
they want the product type in words. 
Also, they want to filter the medicines based on tax criteria. 
Display only the medicines of product categories 1, 2, and 3 
for medicines that come under tax category I 
and medicines of product categories 4, 5, and 6 for medicines that come under tax category II.
Write a SQL query to solve this problem.
ProductType numerical form and ProductType in words are given by
1 - Generic, 
2 - Patent, 
3 - Reference, 
4 - Similar, 
5 - New, 
6 - Specific,
7 - Biological, 
8 – Dinamized
 */
 
select distinct medicineID, companyName, productName, description, substanceName, 
	case productType
		when 1 then 'Generic'
        when 2 then 'Patent'
        when 3 then 'Reference'
        when 4 then 'Similar'
        when 5 then 'New'
        when 6 then 'Specific'
	end as producttype, 
    taxCriteria, hospitalexclusive, governmentdiscount, taxImunity, maxPrice
from medicine 
where 
			((productType in (1,2,3) and taxCriteria = 'I') or 
						(productType in (4,5,6) and taxCriteria = 'II'))
order by medicineID;



/* Problem Statement 2:  
'Ally Scripts' pharmacy company wants to find out the quantity of medicine prescribed in each of its prescriptions.
Write a query that finds the sum of the quantity of all the medicines in a prescription 
and if the total quantity of medicine is less than 20 tag it as “low quantity”. 
If the quantity of medicine is from 20 to 49 (both numbers including) tag it as “medium quantity“ 
and if the quantity is more than equal to 50 then tag it as “high quantity”.
Show the prescription Id, the Total Quantity of all the medicines in that prescription, 
and the Quantity tag for all the prescriptions issued by 'Ally Scripts'.
*/

select prescriptionID, sum(quantity),
	case 
		when sum(quantity) < 20 then 'Low Quantity'
        when sum(quantity) between 20 and 49 then 'Medium Quantity'
        when sum(quantity) > 50 then 'High Quantity'
	end as 'Tag'
from prescription
join contain using(prescriptionID)
where pharmacyID = (select pharmacyID from pharmacy where pharmacyName = 'Ally Scripts')
group by prescriptionID;


/* Problem Statement 3: 
In the Inventory of a pharmacy 'Spot Rx' the quantity of medicine is considered ‘HIGH QUANTITY’
when the quantity exceeds 7500 and ‘LOW QUANTITY’ when the quantity falls short of 1000. 
The discount is considered “HIGH” if the discount rate on a product is 30% or higher,
and the discount is considered “NONE” when the discount rate on a product is 0%.
'Spot Rx' needs to find all the Low quantity products with high discounts 
and all the high-quantity products with no discount
so they can adjust the discount rate according to the demand. 
Write a query for the pharmacy listing all the necessary details relevant to the given requirement.
Hint: Inventory is reflected in the Keep table.
 */
 
select MedicineID, Quantity, Discount,
		CASE
			when (quantity > 7500 and discount = 0) then 'High quantity products with no discount'
            when (quantity < 1000 and discount >= 30) then 'Low quantity products with high discounts'
		END AS Medicine_Type
from keep 
where pharmacyID = (select pharmacyID from pharmacy where pharmacyName = 'Spot Rx')
		AND ( 	(quantity > 7500 and discount = 0)
					or (quantity < 1000 and discount >= 30) 
			)
Order by medicine_type, quantity;




/*Problem Statement 4: 
Mack, From HealthDirect Pharmacy, wants to get a list of all the affordable and costly, hospital-exclusive medicines in the database. 
Where affordable medicines are the medicines that have a maximum price of less than 50% of the avg maximum price of all the medicines in the database, 
and costly medicines are the medicines that have a maximum price of more than double the avg maximum price of all the medicines in the database.
Mack wants clear text next to each medicine name to be displayed that identifies the medicine as affordable or costly. 
The medicines that do not fall under either of the two categories need not be displayed.
Write a SQL query for Mack for this requirement.
*/

set @avg_price = (select avg(maxPrice) from medicine);
select medicineID, companyName, productName,
		CASE
			when maxPrice < @avg_price*0.5 then 'Affordable'
            when maxPrice > @avg_price*2 then 'Costly'
		END as Tag
from medicine as m
where hospitalExclusive = 's'
	and ((maxPrice < @avg_price*0.5) OR (maxPrice > @avg_price*2))
order by medicineID;



/* Problem Statement 5:  
The healthcare department wants to categorize the patients into the following category.
YoungMale: Born on or after 1st Jan  2005  and gender male.
YoungFemale: Born on or after 1st Jan  2005  and gender female.
AdultMale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender male.
AdultFemale: Born before 1st Jan 2005 but on or after 1st Jan 1985 and gender female.
MidAgeMale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender male.
MidAgeFemale: Born before 1st Jan 1985 but on or after 1st Jan 1970 and gender female.
ElderMale: Born before 1st Jan 1970, and gender male.
ElderFemale: Born before 1st Jan 1970, and gender female.
Write a SQL query to list all the patient name, gender, dob, and their category.
*/
DELIMITER $$
CREATE FUNCTION category(dob date, gender varchar(10))
	RETURNS VARCHAR(50)
    deterministic
	BEGIN
		DECLARE category varchar(50) default NULL;
			if dob > '2005-01-01' and gender = 'Male' then set category = 'YoungMale' ;
			elseif dob > '2005-01-01' and gender = 'Female' then set category = 'YoungFemale';
			elseif dob > '1985-01-01' and gender = 'Male' then set category = 'AdultMale';
			elseif dob > '1985-01-01' and gender = 'Female' then set category = 'AdultFemale';
			elseif dob > '1970-01-01' and gender = 'Male' then set category = 'MidAgeMale';
			elseif dob > '1970-01-01' and gender = 'Female' then set category = 'MidAgeFemale';
			elseif dob < '1970-01-01' and gender = 'Male' then set category = 'ElderMale';
			elseif dob < '1970-01-01' and gender = 'Female' then set category = 'ElderFemale';
            end if;
        return (category);
	end $$
delimiter ;


select  personName, gender, dob, category(dob, gender) as 'Category'
from patient
join person on person.personId = patient.patientID;