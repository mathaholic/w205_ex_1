-- Best Hospitals - Investigations
-- By Nikki Haas
-- w205 Exercise 1

-- run as hive -f best_hospitals.hql

-- Investigate the question:
-- What hospitals are models of high-quality care? That is, which hospitals 
-- have the most consistently high scores for a variety of procedures.

-- SQL code in plain English: Some of the measure_ids are golf scores and some are basketball
-- scores in other words, the golf measure_ids are better if they're lower, and the basketball
-- measure_ids are better if they are higher.  So, I read the documentation and created a table
-- called measure_supp that contains the measure_ids as primary keys and the qualifier as B or 
-- G.  I also decided that the Emergency Room volumes were not important since they have
-- no score, so they are not included in the analysis.  
-- Then, I summed all the basketball scores and all the golf scores per hospital, and found the 
-- 75th percentile for B measure_ids and the 25th percentile for G measure_ids.
-- Then, compared the summation for all B and G measure ids per hospital to the 75th and 25th 
-- percentiles.  
-- The Hospitals returned had to have both a B measure_id summed score above the 75th 
-- percentile and a G measure_id summed score below the 25th percentile.
-- the result is then joined back to the effective_care_t table to give the aggregate values
-- requested in the documentation.

-- get headers
set hive.cli.print.header=true;

-- use the database the tables reside in to cut down on typing
use exerise1;

CREATE TABLE exercise1.question_1 AS
SELECT
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
group by u.provider_id, u.hospital_name
ORDER BY score_agg DESC
limit 10;



--expected results:
-- OK
-- provider_id	hosiptal_name	score_agg	score_variance	score_avg
-- 170123	WESLEY MEDICAL CENTER	3701	1155.4158239143364	90.26829268292683
-- 420087	ROPER HOSPITAL	3595	1043.3872694824513	87.6829268292683
-- 160069	MERCY MEDICAL CENTER-DUBUQUE	3525	1131.8777120315585	90.38461538461539
-- 520088	ST AGNES HOSPITAL	3514	1165.9775	87.85
-- 370106	INTEGRIS SOUTHWEST MEDICAL CENTER	3496	1155.513384889946	85.26829268292683
-- 490118	HENRICO DOCTORS' HOSPITAL	3494	1383.2675871137408	89.58974358974359
-- 390091	UPMC NORTHWEST	3467	1110.8193749999996	86.675
-- 520083	ST MARYS HOSPITAL	3464	1187.8395792241945	88.82051282051282
-- 170176	OVERLAND PARK REG MED CTR	3464	1204.0959894806049	88.82051282051282
-- 100166	DOCTORS HOSPITAL OF SARASOTA	3439	921.618699780862	92.94594594594595
-- Time taken: 440.086 seconds, Fetched: 10 row(s)


