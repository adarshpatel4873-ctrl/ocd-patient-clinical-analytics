-- OCD Patient Clinical Analytics portfolio project
-- creating Database of OCD 
CREATE DATABASE IF NOT EXISTS ocd_db;
use ocd_db;
-- creating table schema
create table ocd_patients
(patient_id int primary key, age int, gender varchar(10),
ethnicity varchar(50),
marital_status varchar(30),
education_level varchar(30),
ocd_diagnosis_date date,
duration_of_symptoms_months int,
previous_diagnoses varchar(50),
family_history_of_ocd varchar(10),
obsession_type varchar(50),compulsion_type varchar(50),
ybocs_score_obsession int,
ybocs_score_compulsions int,
depression_diagnosis varchar(10),
anxiety_diagnosis varchar(10),
medications varchar(50) );


select count(*) from ocd_patients;

-- Audit missing values 
select sum(case when previous_diagnoses is null then 1 else 0 end) as missing_prev_diag,
sum(case when medications is null then 1 else 0 end) as missing_mads 
from ocd_patients;

-- Q1: Count total patients in the clinical study.
select count(*) as total_patients from ocd_patients;

-- Q2: Find the gender breakdown of OCD patients.
select gender,count(*) from ocd_patients 
group by gender;

-- Q3: Calculate average age of patients across genders.

select gender,round(avg(age),2) as avg_age
from ocd_patients
group by gender;

-- Q4: Find the most common obsession type.

select obsession_type,count(*) as total_cases
 from ocd_patients group by obsession_type 
 order by total_cases desc;
 
-- Q5: Find the most common compulsion type.

select compulsion_type, count(*) as total_case
from ocd_patients group by compulsion_type 
order by total_case desc;

-- Q6: Average Y-BOCS Obsession and Compulsion scores.

select avg(ybocs_score_obsession) as avg_of_ybocs_score_obsession,
avg(ybocs_score_compulsions) as avg_ybocs_score_compulsions
 from ocd_patients;
 
 -- Q7: Count patients with comorbid depression and anxiety.
 
 select count(*) as dual_comorbid_count from 
 ocd_patients where depression_diagnosis = 'Yes' 
 and anxiety_diagnosis = 'Yes';
 
 -- Q8: Find average Y-BOCS total score by ethnicity.
 
 select ethnicity,round(avg(ybocs_score_obsession + 
ybocs_score_compulsions),2)as avg_total_ybocs 
 from ocd_patients group by ethnicity 
 order by avg_total_ybocs desc;
 
-- Q9: Patients with family history of OCD vs. without.

select family_history_of_ocd,count(*) as patient_count, 
round(avg(ybocs_score_obsession + ybocs_score_compulsions),2)
as avg_total_ybocs 
from ocd_patients group by family_history_of_ocd;


-- Q10: Top prescribed medications across the patient cohort.

select medications,count(*) as patient_count
from ocd_patients 
group by medications order by patient_count desc;

-- Q11: Average duration of symptoms (months) by marital status.

select marital_status, round(avg(duration_of_symptoms_months),0) as avg_symptom_month
from ocd_patients group by marital_status;

-- Q12: Rank patients by total Y-BOCS score using DENSE_RANK().

select patient_id,age,(ybocs_score_obsession+ybocs_score_compulsions) as y_bocs_score,
dense_rank() over (order by (ybocs_score_obsession+ybocs_score_compulsions)desc) as Patients_rank 
from ocd_patients;


-- Q13: Find patients whose Y-BOCS total score exceeds the cohort average.

select patient_id,(ybocs_score_obsession+ybocs_score_compulsions) as total_score 
from ocd_patients 
where (ybocs_score_obsession+ybocs_score_compulsions)>
(select avg(ybocs_score_obsession+ybocs_score_compulsions) from ocd_patients);


-- Q14: Calculate cumulative patient counts by OCD diagnosis year.

with diag_plan as (select year(ocd_diagnosis_date) as diag_year, 
count(*) as new_patients
from ocd_patients 
group by year(ocd_diagnosis_date))
select *,
sum(new_patients) over (order by diag_year rows between unbounded 
preceding and current row) as cumulative_patients 
from diag_plan ;


-- Q15: Categorize patient severity ('Severe' if total Y-BOCS > 30, 'Moderate' > 20, else 'Mild').

 with my_patient as (select patient_id,(ybocs_score_obsession + ybocs_score_compulsions) AS total_ybocs
 from ocd_patients)
select *,
case when total_ybocs>30 then 'Severe' when total_ybocs>=20 then 'Moderate' 
else 'Mild' end as clinical_severity from my_patient;