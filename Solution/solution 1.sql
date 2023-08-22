/* Problem Statement 1:  
Jimmy, from the healthcare department, has requested a report that shows 
how the number of treatments each age category of patients has gone through in the year 2022. 
The age category is as follows, Children (00-14 years), Youth (15-24 years), 
Adults (25-64 years), and Seniors (65 years and over). Assist Jimmy in generating the report. 
*/

ALTER TABLE patient Add column Age INT;

set sql_safe_updates = 0;

 Update patient set age = DATE_FORMAT(FROM_DAYS(DATEDIFF('2022-01-01', dob)), '%Y');

-- Update patient set age = DATEDIFF(NOW(), dob)/365.25;

select age_category, count(patientID) as 'Patient Count' from 
(Select *, case 
			when age between 0 and 14 then 'Children'
            when age between 15 and 24 then 'Youth'
            when age between 25 and 64 then 'Adults'
            else 'Seniors' 
		  end as 'Age_Category'
          from Patient) as q1
          join treatment using(patientid)
          where year(date) = 2022
          group by age_category;



/*Problem Statement 2:  
Jimmy, from the healthcare department, wants to know which disease is infecting people of which gender more often.
Assist Jimmy with this purpose by generating a report that shows for each disease the male-to-female ratio. 
Sort the data in a way that is helpful for Jimmy.
 */

WITH patient_count as 
	(select diseaseid, gender, count(patientid) as Patients
		from Person as p
		join treatment as t on t.patientid = p.personid
		group by diseaseid, gender
		order by diseaseid)

select diseaseid,diseasename, f.Patients, m.Patients from 
	disease join 
	(select diseaseid, Patients from patient_count where gender = 'Female') as f using (diseaseid)
    join (select diseaseid, Patients from patient_count where gender = 'Male') as m using(diseaseid);
    
    


/* Problem Statement 3: 
Jacob, from insurance management, has noticed that insurance claims are not made for all the treatments. 
He also wants to figure out if the gender of the patient has any impact on the insurance claim. 
Assist Jacob in this situation by generating a report that finds 
for each gender the number of treatments, number of claims, and treatment-to-claim ratio. 
And notice if there is a significant difference between the treatment-to-claim ratio of male and female patients.
 */

select Gender, count(treatmentID) as 'Number of Treatments' , count(claimID) as 'No of Claims', count(treatmentID)/count(claimID) 'Treatment to Claim Ratio' 
		from Person as p
		join treatment as t on t.patientid = p.personid
		group by  gender;


/* Problem Statement 4: 
The Healthcare department wants a report about the inventory of pharmacies. 
Generate a report on their behalf that shows how many units of medicine each pharmacy has in their inventory, 
the total maximum retail price of those medicines, and the total price of all the medicines after discount. 
Note: discount field in keep signifies the percentage of discount on the maximum price.
 */
 
 select pharmacyid,PharmacyName, round(sum(quantity),0) as 'Total Medicine', round(sum(quantity*maxprice),0) as 'Total MRP of All Medicine', 
		round(sum(quantity*maxprice*(1-discount/100)),0) as 'Total Price After Discount' from keep
 join medicine using(medicineID)
 join pharmacy using (pharmacyID)
 group by pharmacyid;
 select distinct governmentDiscount from medicine;
 
 

/* Problem Statement 5:  
The healthcare department suspects that some pharmacies prescribe more medicines than others in a single prescription, 
for them, generate a report that finds for each pharmacy the maximum, minimum and average number of medicines prescribed in their prescriptions.  */

select pharmacyID, pharmacyName, min(medicine_count) as 'Min_Prescribe', max(medicine_count) as 'Max_Prescribe', round(avg(medicine_count),0) as 'Avg_Prescribe'
from 
	(select pharmacyID, prescriptionID, count(medicineID) as 'Medicine_Count'
	from prescription as pr 
	join contain as c using (prescriptionID) 
	group by pharmacyID, prescriptionID ) as q1
join pharmacy using(pharmacyID)
group by pharmacyID
order by Avg_Prescribe desc, Max_Prescribe desc, min_prescribe desc;


