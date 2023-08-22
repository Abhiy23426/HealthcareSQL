/* Problem Statement 1:  
Some complaints have been lodged by patients that they have been prescribed 
hospital-exclusive medicine that they can’t find elsewhere and facing problems due to that. 
Joshua, from the pharmacy management, wants to get a report of 
which pharmacies have prescribed hospital-exclusive medicines the most in the years 2021 and 2022. 
Assist Joshua to generate the report so that the pharmacies who prescribe 
hospital-exclusive medicine more often are advised to avoid such practice if possible. */


select pharmacyID, pharmacyName, count(distinct prescriptionID) as Prescription_Count, 
	count(medicineID) as Medicine_Count
from medicine 
join contain using(medicineID) 
join prescription using(prescriptionID)
join treatment using(treatmentID)
join pharmacy using(pharmacyID)
WHERE hospitalExclusive = 'S' and year(date) in( 2021 , 2022)
group by pharmacyID
order by Medicine_count DESC, prescription_count DESC;


/*
select * from prescription;
select count(*) from contain;

select pharmacyID, PharmacyName, count(distinct medicineID) from keep
join pharmacy using(pharmacyID)
join prescription using( pharmacyID) 
join treatment using(treatmentID)
where medicineid in (
		select medicineID from keep
		group by medicineid
		having count(pharmacyID) = 1)
	AND year(date) between 2021 and 2022
group by pharmacyID
order by count(medicineID) DESC;


*/


/* Problem Statement 2: 
Insurance companies want to assess the performance of their insurance plans. 
Generate a report that shows each insurance plan, the company that issues the plan, and the number of treatments the plan was claimed for.
*/
select companyID, companyName, planName, count(claimID) as 'Number_of_claims'
from treatment 
join claim using (claimID)
join insurancePlan using (UIN)
join insurancecompany using(companyID)
group by companyID, planName
order by companyID, planName;


/* Problem Statement 3: 
Insurance companies want to assess the performance of their insurance plans. 
Generate a report that shows each insurance company's name with their most and least claimed insurance plans. */

/** Minimum Claimed Plan **/
with planInfo as 
	(select companyID, planName, count(claimID) as 'Number_of_Claims', rank() over(partition by companyID order by count(claimID)) as min_r,
			rank() over(partition by companyID order by count(claimID) desc) as max_r
	from claim
	join insurancePlan using (UIN)
	group by companyID, planName
    order by companyID)

select CompanyID, companyName, Minimum_claimed, Number_of_Minimum_Claims, Maximum_claimed, Number_of_Maximum_Claims	
from (select companyID, group_concat(planName separator ', ') as Minimum_claimed, Number_of_Claims as Number_of_Minimum_Claims from planInfo where min_r = 1 group by companyID, Number_of_Claims ) as mi
join (select companyID, group_concat(planName separator ', ') as Maximum_claimed, Number_of_Claims as Number_of_Maximum_Claims from planInfo where max_r = 1 group by companyID, Number_of_Claims) as ma using (companyID)
join insurancecompany using(companyID)
;



/* Problem Statement 4:  
The healthcare department wants a state-wise health report to assess 
which state requires more attention in the healthcare sector. 
Generate a report for them that shows the state name, 
number of registered people in the state, 
number of registered patients in the state, 
and the people-to-patient ratio. 
sort the data by people-to-patient ratio. */

select state, count(personID), count( distinct patientID)
from address
join person as p using (addressID)
left join patient as pa on pa.patientID = p.personID
group by state
order by state;


/* Problem Statement 5:  
Jhonny, from the finance department of Arizona(AZ), 
has requested a report that lists the total quantity of medicine each pharmacy 
in his state has prescribed that falls under Tax criteria I for treatments 
that took place in 2021. Assist Jhonny in generating the report.  */

select pharmacyID, pharmacyName, sum(quantity) as 'Total Medicine'
from medicine 
join contain using(medicineID)
join prescription using(prescriptionID)
join pharmacy using(pharmacyID)
join address using(addressID)
join treatment using(treatmentID)
where taxCriteria = 'I' and state = 'AZ' and year(date)= 2021
group by pharmacyID
order by pharmacyName;
