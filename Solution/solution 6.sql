/* Problem Statement 1: 
The healthcare department wants a pharmacy report on the 
percentage of hospital-exclusive medicine prescribed in the year 2022.
Assist the healthcare department to view for each pharmacy, the pharmacy id, 
pharmacy name, total quantity of medicine prescribed in 2022, 
total quantity of hospital-exclusive medicine prescribed by the pharmacy in 2022,
 and the percentage of hospital-exclusive medicine to the total medicine prescribed in 2022.
Order the result in descending order of the percentage found. 
*/

with pharmacy_count as
	(select pharmacyID, quantity, hospitalExclusive 
	from treatment
	join prescription using(treatmentID)
	join contain using(prescriptionID)
	join medicine using(medicineID)
	where year(date) = 2022)
select pharmacyID, pharmacyName, Total_Quantity, Hospital_Exclusive_Quantity, 
		(Hospital_Exclusive_Quantity*100/Total_Quantity) as 'Percentage_Hospital_Exclusive'
from (select pharmacyID, sum(quantity) as 'Total_Quantity' from pharmacy_count group by pharmacyID) as t1
join (select pharmacyID, sum(quantity) as 'Hospital_Exclusive_Quantity' from pharmacy_count where hospitalexclusive = 's' group by pharmacyID) as t2
	using(pharmacyID)
join pharmacy using (pharmacyID)
order by Percentage_Hospital_Exclusive desc;


/*Problem Statement 2:  
Sarah, from the healthcare department, has noticed many people do not claim insurance for their treatment. 
She has requested a state-wise report of the percentage of treatments that took place without claiming insurance. 
Assist Sarah by creating a report as per her requirement.
*/

select state, count(treatmentID) as 'Total_Treatments', count(distinct claimID) as 'Total_Claimed', 
	round((1-count(distinct claimID)/count(treatmentID))*100, 2) 'Percentage_Not_Claimed'
from treatment
join person on person.personID = treatment.patientID
join address using(addressID)
group by state;

/*Problem Statement 3:  
Sarah, from the healthcare department, is trying to understand 
if some diseases are spreading in a particular region. 
Assist Sarah by creating a report which shows for each state, 
the number of the most and least treated diseases by the patients of that state in the year 2022. 
*/
with patient_count as
	(select state, DiseaseName, count(patientID) as 'Number_of_Patients', 
		rank() over(partition by state order by count(patientID)) as min_r,
		rank() over(partition by state order by count(patientID) desc) as max_r
	from disease
	join treatment using(diseaseID)
	join person on person.personId = treatment.patientID
	join address using(addressID)
	group by state, diseaseID
	order by state)

select state, Leaset_Treated_Diseases, Number_of_Least_Patients, Most_Treated_Diseases, Number_of_Most_Patients
from (select state, group_concat(diseaseName separator ', ') as Leaset_Treated_Diseases, Number_of_Patients as Number_of_Least_Patients from patient_count where min_r = 1 group by state, Number_of_Patients) as mi
join (select state, group_concat(diseaseName separator ', ') as Most_Treated_Diseases, Number_of_Patients as Number_of_Most_Patients from patient_count where max_r = 1 group by state, Number_of_Patients) as ma
	using(state);
    
/*Problem Statement 4: 
Manish, from the healthcare department, wants to know 
how many registered people are registered as patients as well, in each city. 
Generate a report that shows each city that has 10 or more registered people 
belonging to it and the number of patients from that city 
as well as the percentage of the patient with respect to the registered people.
*/

select city, count(distinct personID) as 'Total_Persons', count(distinct patientID) as 'Total_Patient', 
	round((1-count(distinct patientID)/count(personID))*100, 2) 'Percentage_Patient_to_Person'
from address
join person using(addressID)
left join patient on person.personID = patient.patientID
group by city
having count(personID) >= 10;


/*Problem Statement 5:  
It is suspected by healthcare research department that 
the substance “ranitidine” might be causing some side effects. 
Find the top 3 companies using the substance 
in their medicine so that they can be informed about it.
*/
select count(medicineid) c,companyname from medicine
where substanceName rlike 'ranitidina' group by companyname order by c desc
limit 3;