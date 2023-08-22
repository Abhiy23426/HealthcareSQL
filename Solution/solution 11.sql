/* Problem Statement 1:
Patients are complaining that it is often difficult to find some medicines. 
They move from pharmacy to pharmacy to get the required medicine.
A system is required that finds the pharmacies and their contact number 
that have the required medicine in their inventory. 
So that the patients can contact the pharmacy and order the required medicine.
Create a stored procedure that can fix the issue.
*/

Delimiter //
Create Procedure Pharmacy_Info(Medicine_Name varchar(50))
	begin 
		select pharmacyName, phone, address1, city, state from pharmacy join address using(addressID)
		where pharmacyID in 
				(select distinct pharmacyID 
				 from keep where medicineID in 
						(select medicineID 
						 from medicine where productName = Medicine_Name));
	end //
delimiter ;

select * from medicine;
call pharmacy_info('CETIL');

/* Problem Statement 2:
The pharmacies are trying to estimate the average cost of 
all the prescribed medicines per prescription, for all the prescriptions 
they have prescribed in a particular year. 
Create a stored function that will return the required value when 
the pharmacyID and year are passed to it. Test the function with multiple values.
*/

Delimiter //
Create function Avg_Pres_Price_Year(pharmacy_ID_IN int, year_in int)
returns int deterministic
	Begin
		declare Avg_Prescription_Price int ;
		select round(sum(quantity*maxPrice)/ count(distinct prescriptionID), 2) into Avg_Prescription_Price
		from treatment
		join prescription using(treatmentID)
		join contain using(prescriptionID)
		join medicine using(medicineID)
		where pharmacyID = pharmacy_ID_IN and year(date) = year_in;
        return Avg_Prescription_Price;
	end //
delimiter ;

select distinct pharmacyID, year(date) as 'Year', Avg_Pres_Price_Year(pharmacyID, year(date)) as Avg_Pres_Price_Year 
from treatment join prescription using(treatmentID)
where pharmacyID = 1008 
;

/* Problem Statement 3:
The healthcare department has requested an application that 
finds out the disease that was spread the most in a state for a given year. 
So that they can use the information to compare the historical data and gain some insight.
Create a stored function that returns the name of the disease 
for which the patients from a particular state had 
the most number of treatments for a particular year. 
Provided the name of the state and year is passed to the stored function.
*/

Delimiter //
Create function Most_Spread_Disease(State_Name varchar(10), year_In int)
returns varchar(150) deterministic
	begin
		declare res varchar(150);
		select group_concat(diseaseName separator ', ') into res 
		from (select diseaseID, DiseaseName, count(patientID) as 'Infected_Patients', rank() over(order by count(diseaseID) desc) as max_r
				from disease
				join treatment using(diseaseID)
				join person on person.personID = treatment.patientID
				join address using(addressID)
				where state = State_Name and year(date) = year_In
				group by diseaseID) as q1 
		where max_r = 1;
        return res;
	End //
Delimiter ;

drop function Most_Spread_Disease;
select distinct state, year(date), Most_Spread_Disease(state, year(date)) as Most_Spread_Disease
from treatment 
join person on person.personID = treatment.patientID
join address using(addressID)
where state = 'VT' ;



/*Problem Statement 4:
The representative of the pharma union, Aubrey, has requested a system 
that she can use to find how many people in a specific city have been 
treated for a specific disease in a specific year.
Create a stored function for this purpose.
*/

Delimiter //
Create function Disease_in_City_in_year(Disease_ID_In int, city_name varchar(50), year_In int)
returns int deterministic 
	begin
		declare patient_count int;
		select count(patientID) into Patient_count
		from disease
		join treatment using(diseaseID)
		join person on person.personID = treatment.patientID
		join address using(addressID)
		where city = city_name and diseaseID= disease_ID_In and year(date) = year_In
		group by city, diseaseID, year(date);
        return Patient_count;
	end //
delimiter ;

select Disease_in_City_in_year(4,'Glen Burnie',2022);



/* Problem Statement 5:
The representative of the pharma union, Aubrey, is trying to 
audit different aspects of the pharmacies. 
She has requested a system that can be used to find the 
average balance for claims submitted by a specific insurance company in the year 2022. 
Create a stored function that can be used in the requested application. 
*/
delimiter //
create function avg_bal_2k22(company_ID_In int)
returns int deterministic
	begin
		declare avg_balance int ;
		select round(avg(balance), 0) into avg_balance
		from insuranceplan
		join claim using(UIN)
		join treatment using(claimID)
		where companyID = company_ID_In and year(date) = 2022;
        return avg_balance;
	end //
delimiter ;


select companyID, avg_bal_2k22(companyID) from insurancecompany;