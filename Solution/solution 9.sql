/* Problem Statement 1: 
Brian, the healthcare department, has requested for a report 
that shows for each state how many people underwent treatment for the disease “Autism”.  
He expects the report to show the data for each state 
as well as each gender and for each state and gender combination. 
Prepare a report for Brian for his requirement.
*/

select coalesce(State, 'Total') as 'State', coalesce(gender, 'Total') as 'Gender', count(patientID) as 'Patient_Count'
from disease 
join treatment using(diseaseID)
join person on person.personID = treatment.patientID
join address using(addressID)
where diseaseName = 'Autism'
group by state, gender with rollup;



/* Problem Statement 2:  
Insurance companies want to evaluate the performance of different insurance plans they offer. 
Generate a report that shows each insurance plan, the company that issues the plan, 
and the number of treatments the plan was claimed for. 
The report would be more relevant if the data compares the performance for different years(2020, 2021 and 2022) 
and if the report also includes the total number of claims in the different years, 
as well as the total number of claims for each plan in all 3 years combined.
*/

 set @@sql_mode =  REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY','');
with claim_info as 
	(select planName, companyName, coalesce(year(date),'total') as 'Year', count(claimID) as Claim_Count
	from insurancecompany
	join insuranceplan using(companyID)
	join claim using(UIN)
	join treatment using(claimID)
	where year(date) in (2020,2021,2022) 
	group by PlanName, companyName, year(date) with rollup)

select * from claim_info where (companyName is not null) and (planName is not null);


/* Problem Statement 3:  
Sarah, from the healthcare department, is trying to understand 
if some diseases are spreading in a particular region.
Assist Sarah by creating a report which shows each state 
the number of the most and least treated diseases 
by the patients of that state in the year 2022. 
It would be helpful for Sarah if the aggregation for the different combinations is found as well. 
Assist Sarah to create this report. 
*/
with cte as 
(select state, diseaseID, count(patientID) as 'treatment_count', rank() over(partition by state order by count(patientID)) as min_r, 
	rank() over(partition by state order by count(patientID) desc) as max_r
from treatment
join disease using(diseaseID)
join person on treatment.patientID = person.personID
join address using(addressID)
group by state, diseaseID)

select * from cte
where min_r = 1 or max_r = 1;

/* Problem Statement 4: 
Jackson has requested a detailed pharmacy report that shows each pharmacy name, 
and how many prescriptions they have prescribed for each disease in the year 2022, 
along with this Jackson also needs to view how many prescriptions were prescribed by each pharmacy, 
and the total number prescriptions were prescribed for each disease.
Assist Jackson to create this report. 
*/

select pharmacyName, coalesce(DiseaseName, 'Total'), count(prescriptionID) as 'Prescription_Count'
from Pharmacy
join Prescription using(pharmacyID)
join treatment using(treatmentID)
join disease using(diseaseID)
where year(date) = 2022
group by pharmacyName, DiseaseName with rollup
order by pharmacyName, Prescription_Count desc;

/* Problem Statement 5:  
Praveen has requested for a report that finds for every disease how many 
males and females underwent treatment for each in the year 2022. 
It would be helpful for Praveen if the aggregation for the different combinations is found as well.
Assist Praveen to create this report. 
*/
select  diseaseName, coalesce(gender, 'Total') as 'Gender', count(patientID) as 'Patient_Count'
from disease
join treatment using(diseaseID)
join person on person.personiD= treatment.patientID
group by diseaseName, gender with rollup;
