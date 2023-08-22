/* Problem Statement 1: 
Johansson is trying to prepare a report on patients who have gone through treatments more than once. 
Help Johansson prepare a report that shows the patient's name, the number of treatments they have undergone, 
and their age, Sort the data in a way that the patients who have undergone more treatments appear on top.
*/
select personName, count(treatmentID) as 'Number_of_Treatments', age
from person
join patient on patient.patientID = person.personID
join treatment using(patientID)
group by patientID
having count(treatmentID) > 1
order by Number_of_Treatments desc; 



/* Problem Statement 2:  
Bharat is researching the impact of gender on different diseases, 
He wants to analyze if a certain disease is more likely to infect a certain gender or not.
Help Bharat analyze this by creating a report showing for every disease 
how many males and females underwent treatment for each in the year 2021. 
It would also be helpful for Bharat if the male-to-female ratio is also shown.
*/
With patient_data AS
	(select *
	from person
	join patient on patient.patientID = person.personID
	join treatment using(patientID)
	where year(date)=2021)

select diseaseID, DiseaseName, Male_Count, Female_Count, Male_Count/Female_Count as 'Male_to_Female_ratio'
from (Select diseaseID, count(treatmentID) as 'Male_Count' from Patient_data where gender = 'male' group by diseaseID) as m
join (Select diseaseID, count(treatmentID) as 'Female_Count' from Patient_data where gender = 'Female' group by diseaseID) as f
    using (diseaseID)
join disease using(diseaseID)
order by diseaseID;


/* Problem Statement 3:  
Kelly, from the Fortis Hospital management, 
has requested a report that shows for each disease, 
the top 3 cities that had the most number treatment for that disease.
Generate a report for Kelly’s requirement.
*/
select diseaseID, DiseaseName, City, Number_of_Patients  from 
	(select diseaseID, city,count(treatmentID) as 'Number_of_Patients',rank() over(partition by diseaseID order by count(treatmentID) desc) as 'City_rank'
	from treatment 
	join person on person.personID = treatment.patientID
	join address using(addressID)
	group by diseaseID, city
	order by diseaseid) as q1
join disease using(diseaseID)
where city_rank<=3
order by diseaseID, Number_of_patients desc;


/*Problem Statement 4: 
Brooke is trying to figure out if patients with a particular disease 
are preferring some pharmacies over others or not, 
For this purpose, she has requested a detailed pharmacy report 
that shows each pharmacy name, and how many prescriptions they have prescribed 
for each disease in 2021 and 2022, She expects the number of prescriptions 
prescribed in 2021 and 2022 be displayed in two separate columns.
Write a query for Brooke’s requirement.
*/
with pres as
	(select pharmacyID, diseaseID,date, prescriptionID
	from prescription
	join treatment using(treatmentID))
    
    
select pharmacyID, pharmacyName, diseaseID, diseaseName, 
		coalesce(prescription_count_2021, 0) as 'prescription_count_2021', 
		coalesce(prescription_count_2022, 0) as 'prescription_count_2022'
from pharmacy 
join disease 
left join (select pharmacyID, diseaseID, count(prescriptionID) as prescription_count_2021 from pres where year(DATE) = 2021 group by pharmacyID, diseaseID) as Y2K1
	using(pharmacyID, diseaseID)
left join (select pharmacyID, diseaseID, count(prescriptionID) as prescription_count_2022 from pres where year(DATE) = 2022 group by pharmacyID, diseaseID) as Y2K2
using(pharmacyID, diseaseID)
where prescription_count_2021 !=0 and prescription_count_2022 != 0
order by pharmacyID, prescription_count_2021 desc , prescription_count_2022 desc;

/*Problem Statement 5:  
Walde, from Rock tower insurance, has sent a requirement 
for a report that presents which insurance company is targeting the patients of which state the most. 
Write a query for Walde that fulfills the requirement of Walde.
Note: We can assume that the insurance company is targeting a region more 
if the patients of that region are claiming more insurance of that company.
*/
with state_pref as
	(select companyID, state, count(claimID) as 'patient_count'
	from address
	join person using(addressID)
	join treatment on person.personID = treatment.patientID
	join claim using(claimID)
	join insuranceplan using(UIN)
	group by companyID, state
	order by companyID, count(claimID) desc)
    
select companyID, companyName, count(*) as 'Number_of_states', group_concat(state separator ', ') as states, patient_count from state_pref as s1
join insurancecompany using(companyID)
where patient_count = (select max(patient_count) from state_pref as s2 where s1.companyID = s2.companyID)
group by companyID, patient_count
order by companyID;