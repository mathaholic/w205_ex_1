-- Hospitals and Patients - Investigations
-- By Nikki Haas
-- w205 Exercise 1

-- run as hive -f hospitals_and_patients.hql

-- Investigate the questions
-- Are average scores for hospital quality or procedural variability correlated 
-- with patient survey responses?


-- Use the answer from question 1 as a temporary table, and join to the survey responses



-- quick check with just the top rated hospitals


Select
corr(x.score_agg, (y.hcahps_base_score + y.hcahps_consistency_score)) correlation_score
from 
question_1 x 
join
survey_responses_t  y
on x.provider_id = y.provider_id


-- results

-- OK
-- correlation_score
-- -0.015390079896484768
-- Time taken: 68.827 seconds, Fetched: 1 row(s)


-- try on all of the base table from q1

Select
corr(a.score_agg, (b.hcahps_base_score + b.hcahps_consistency_score)) correlation_score,
corr(a.score_variance, (b.hcahps_base_score + b.hcahps_consistency_score)) correlation_var
from 
(SELECT
u.provider_id provider_id,
u.hospital_name hosiptal_name,
sum(etc.score) score_agg,
variance(etc.score) score_variance,
avg(etc.score) score_avg
FROM
(SELECT
w.provider_id provider_id,
w.hospital_name hospital_name,
count(w.provider_id) total_count
from (
Select 
y.provider_id provider_id,
y.hospital_name hospital_name,
z.qualifier,
y.total_score
from 
(select 
x.qualifier qualifier,
case when x.qualifier = "B" then percentile(x.total_score, 0.75) when x.qualifier = "G" then percentile(x.total_score, 0.25) end as pct 
from 
(select 
ec.provider_id provider_id,
ec.hospital_name hospital_name,
m.qualifier,
sum(ec.score) as total_score
from measure_supp m
join effective_care_t ec
on m.measure_id = ec.measure_id
where 
m.qualifier in ("B", "G")
group by ec.provider_id, ec.hospital_name, m.qualifier) x
group by x.qualifier) z
join 
(select 
ec.provider_id provider_id,
ec.hospital_name hospital_name,
m.qualifier,
sum(ec.score) as total_score
from measure_supp m
join effective_care_t ec
on m.measure_id = ec.measure_id
where  
m.qualifier in ("B", "G")
group by ec.provider_id, ec.hospital_name, m.qualifier) y 
on 
z.qualifier = y.qualifier
WHERE
(y.total_score < z.pct AND z.qualifier = "G")
OR (y.total_score > z.pct AND z.qualifier = "B")) w
group by w.provider_id, w.hospital_name
having count(w.provider_id) > 1) u 
join 
effective_care_t etc 
on u.provider_id = etc.provider_id
group by u.provider_id, u.hospital_name) a
join
survey_responses_t  b
on a.provider_id = b.provider_id


-- results
-- OK
-- correlation_score	correlation_var
-- -0.26682328771747466	-0.08321417076776778
-- Time taken: 467.1 seconds, Fetched: 1 row(s)


-- This is a very weak correlation, or even a nonexistent correlation for both the hospitals performancy
-- and the variability in measure scores.  I am not surprised, as opinion polls are rarely scientific.  
-- The measures are based upon concrete, recorded observations from the hospitals, and not the combination of a 
-- patient's recollections and their whims on the day they filled out the survey.
-- If we want further proof that opinion polls do not reflect reality, Nate Silver painfully reminded us of 
-- this last November.
