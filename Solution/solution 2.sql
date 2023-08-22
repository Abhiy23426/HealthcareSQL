/* Problem Statement 1: 
A company needs to set up 3 new pharmacies, 
they have come up with an idea that the pharmacy can be set up in cities 
where the pharmacy-to-prescription ratio is the lowest 
and the number of prescriptions should exceed 100. 
Assist the company to identify those cities where the pharmacy can be set up. */

select city, count(distinct pharmacyID)/count(distinct prescriptionID) as 'pharmacy_to_prescription' 
from address 
join pharmacy using(addressid)
join prescription using(pharmacyid)
group by city
having count(prescriptionID)>100
order by pharmacy_to_prescription
limit 3;


/* Problem Statement 2: 
The State of Alabama (AL) is trying to manage its healthcare resources more efficiently. 
For each city in their state, they need to identify the disease for which 
the maximum number of patients have gone for treatment. Assist the state for this purpose.
Note: The state of Alabama is represented as AL in Address Table.
 */
 

WITH Patients AS
	(select city, diseaseid, count(patientID) as Patient_Count from address
		join person using(addressid)
		join treatment on person.personid = treatment.patientID
		where state = 'AL' 
		group by city, diseaseid
        order by city)

select city, diseaseid, diseaseName, Patient_Count from Patients P1
join disease as d using(diseaseid) 
where patient_count = (select max(Patient_Count) from Patients as p2 where P1.city = P2.city)
Order by patient_count desc, city, diseaseName;


/* Problem Statement 3: 
The healthcare department needs a report about insurance plans. 
The report is required to include the insurance plan, 
which was claimed the most and least for each disease.
Assist to create such a report. */

/************* Minimum Claimed ***********/
WITH Insurence_Count as 
	(select diseaseID, planName, count(patientID) as 'Plan_Claimed' from treatment
		join claim using(claimId)
		join insuranceplan using(UIN) 
		group by diseaseid, planName
		order by diseaseid, planName)

select diseaseID, planName, (plan_claimed), row_number() over(partition by diseaseID, Plan_claimed) as 'Plan_Count'  
from (
		(select  DiseaseID, planName, Plan_claimed from Insurence_Count as IC1 where Plan_claimed = 
			(select min(Plan_Claimed) from Insurence_count IC2 where IC1.DiseaseID= IC2.DiseaseID )) 
		union
		(select  DiseaseID, planName, Plan_claimed from Insurence_Count as IC1 where Plan_claimed = 
			(select max(Plan_Claimed) from Insurence_count IC2 where IC1.DiseaseID= IC2.DiseaseID ))) as t ;
group by diseaseID, planName with rollup
order by diseaseID, sum(plan_claimed);

/************* Maximum Claimed ***********
WITH Insurence_Count as 
	(select diseaseID, planName, count(patientID) as 'Plan_Claimed' from treatment
		join claim using(claimId)
		join insuranceplan using(UIN) 
		group by diseaseid, planName
		order by diseaseid, planName)*/



/* Problem Statement 4: 
The Healthcare department wants to know which disease is most likely to infect multiple people in the same household. 
For each disease find the number of households that has more than one patient with the same disease.
Note: 2 people are considered to be in the same household if they have the same address. */

select diseaseid, diseaseName, count(addressID) as 'Number of Households'
from (select diseaseID,diseaseName, addressID
		from disease
		join treatment using(diseaseID)
		join Person on Person.PersonID = treatment.PatientID
		group by diseaseID, AddressID
		having count(distinct patientID) > 1
		order by diseaseID) as q1
group by diseaseID;


/* Problem Statement 5:  
An Insurance company wants a state wise report of the treatments to claim ratio
between 1st April 2021 and 31st March 2022 (days both included). 
Assist them to create such a report. */

select state, count( distinct treatmentID)/count(distinct claimID) as 'Treatment to Claim Ratio'
from treatment
join person on person.personID = treatment.patientID
join address using(addressID) 
where date between '2021-04-01' and '2022-03-31'
group by state
order by state;