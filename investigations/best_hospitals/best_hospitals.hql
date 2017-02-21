-- Best Hospitals - Investigations
-- By Nikki Haas
-- w205 Exercise 1

-- run as hive -f best_hospitals.hql

-- Ivestigate the question:
-- What hospitals are models of high-quality care? That is, which hospitals 
-- have the most consistently high scores for a variety of procedures.


-- Readmissions and Deaths: 30-Day Readmission and Death Measures
-- Description/
-- Background
-- The 30-day unplanned readmission measures are estimates of unplanned readmission to any acute care hospital
-- within 30 days of discharge from a hospitalization for any cause related to medical conditions, including heart
-- attack, heart failure, pneumonia, chronic obstructive pulmonary disease (COPD), and stroke; and surgical
-- procedures, including hip/knee replacement and cornary artery bypass graft (CABG). The 30-day unplanned
-- hospital-wide readmission measure focuses on whether patients who were discharged from a hospitalization
-- were hospitalized again within 30 days. The hospital-wide readmission measure includes all medical, surgical
-- and gynecological, neurological, cardiovascular, and cardiorespiratory patients. The 30-day death measures are
-- estimates of deaths within 30-days of a hospital admission from any cause related to medical conditions,
-- including heart attack, heart failure, pneumonia, COPD, and stroke; and surgical procedures, including CABG.
-- Hospitals’ rates are compared to the national rate to determine if hospitals’ performance on these measures is
-- better than the national rate (lower), no different than the national rate, or worse than the national rate (higher).
-- For some hospitals, the number of cases is too small to reliably compare their results to the national average rate.
-- Rates are provided in the downloadable databases as decimals and typically indicate information that is
-- presented on the Hospital Compare website as percentages. Lower percentages for readmission and mortality are
-- better.
-- Reporting Cycle Collection period: Approximately 36 months. Refreshed annually.

-- check out one hospital:

set hive.cli.print.header=true;

use exerise1;

select measure_id, denominator, score,
 compared_to_national from readmissions_t where provider_id = 10001;

	-- OK
	-- measure_id	denominator	score	compared_to_national
	-- MORT_30_AMI	699	12.2	0
	-- MORT_30_CABG	269	3.7	0
	-- MORT_30_COPD	566	8.8	0
	-- MORT_30_HF	776	12.6	0
	-- MORT_30_PN	374	11.6	0
	-- MORT_30_STK	495	15.3	0
	-- READM_30_AMI	772	17.4	0
	-- READM_30_CABG	266	15.9	0
	-- READM_30_COPD	687	22.0	0
	-- READM_30_HF	958	21.0	0
	-- READM_30_HIP_KNEE	329	5.2	0
	-- READM_30_HOSP_WIDE	5309	14.8	0
	-- READM_30_PN	423	18.2	0
	-- READM_30_STK	493	13.0	0
	-- Time taken: 0.115 seconds, Fetched: 14 row(s)


-- check out distinct global measuare names
select distinct measure_id from readmissions_t;
	-- OK
	-- measure_id
	-- MORT_30_AMI
	-- MORT_30_CABG
	-- MORT_30_COPD
	-- MORT_30_HF
	-- MORT_30_PN
	-- MORT_30_STK
	-- READM_30_AMI
	-- READM_30_CABG
	-- READM_30_COPD
	-- READM_30_HF
	-- READM_30_HIP_KNEE
	-- READM_30_HOSP_WIDE
	-- READM_30_PN
	-- READM_30_STK
	-- Time taken: 50.928 seconds, Fetched: 14 row(s)

-- it appears that the hospitals all have the same mortality and readmission 
-- rates.  let's see if there are hospitals where this is not true and investigate
-- the outlyers

SELECT 
x.provider_id, x.record_count
FROM
(SELECT provider_id, count(provider_id) record_count from readmissions_t 
	group by provider_id) x
where x.record_count != 14;

-- this is an empty set, so we can be confident that for each hospital, there is 
-- an entry for each category of readmission or death.
-- However, we know from transformations the footnote might include insufficient data notes
-- so we must be careful.

SELECT * FROM readmissions_t where score is NULL;

	--Time taken: 0.218 seconds, Fetched: 23847 row(s)

-- Indeed, we can see in our readmissions file, of the 66,990 listings, there are 23,847 
-- entries with a NULL score.  Often they have footnote 5, which means the 'This footnote 
-- is applied when the hospital does not have data to report or has chosen not to submit data.'

-- We will have to investigate these hospitals further

select distinct state from readmissions_t where score is NULL;
	-- Time taken: 48.783 seconds, Fetched: 55 row(s)

-- it is not a single state, territory, or district that did not include this data
-- so we can be confident we can use this set to get state data.


-- Next, review effective_care_t

-- There was no quantitative information for the emergency room volumes to begin with,
-- so we lose nothing by omitting their scores.

-- Speaking of scores, they are to range from 0 to 100, but a few scores are above 1000, 
-- investigate

select score, count(score) from effective_care_t group by score order by score desc;

-- OK
-- score	_c1
--1180	1
-- 1132	1
-- 1123	1
-- 1050	1

select * from effective_care_t where score > 1000;
-- OK
-- effective_care_t.provider_id	effective_care_t.hospital_name	effective_care_t.address	effective_care_t.city	effective_care_t.state	effective_care_t.zip_code	effective_care_t.county	effective_care_t.phone	effective_care_t.condition	effective_care_t.measure_id	effective_care_t.measure_name	effective_care_t.score	effective_care_t.sample	effective_care_t.footnote	effective_care_t.measure_start_date	effective_care_t.measure_end_date
-- 310002	NEWARK BETH ISRAEL MEDICAL CENTER	201 LYONS AVE	NEWARK	NJ	7112	ESSEX	9739267850	EMERGENCY DEPARTMENT	ED_1B	ED1	1123	609	["2"]	2013-10-01	2014-09-30
-- 400079	HOSP COMUNITARIO BUEN SAMARITANO	CARR.2 KM.1.4 AVE. SEVERIANO CUEVAS #18	AGUADILLA	PR	603	AGUADILLA	7876580000	EMERGENCY DEPARTMENT	ED_1B	ED1	1050	717	["2","3"]	2013-10-01	2014-09-30
-- 450348	FALLS COMMUNITY HOSPITAL AND CLINIC	322 COLEMAN STREET	MARLIN	TX	76661	FALLS	2548033561	EMERGENCY DEPARTMENT	ED_1B	ED1	1180	313	["2"]	2013-10-01	2014-09-30
-- 450348	FALLS COMMUNITY HOSPITAL AND CLINIC	322 COLEMAN STREET	MARLIN	TX	76661	FALLS	2548033561	EMERGENCY DEPARTMENT	ED_2B	ED2	1132	285	["2"]	2013-10-01	2014-09-30
-- Time taken: 0.238 seconds, Fetched: 4 row(s)


-- The higest ranges are for measure_id in (ED_1B, ED_2B)  which are wait and admittance times from emergency 
-- rooms, respectively.  In these cases, a high score would be a BAD thing, not a GOOD thing.
-- See https://www.medicare.gov/HospitalCompare/data/Data-Updated.html#MG3
-- looking through this document, we see that  several measure_ids that have higher scores
-- are bad, but other measure_ids that have higher scores are worse.

-- let's gather the unique measure_ids from the timely and effective care table and research
-- them.

SELECT DISTINCT measure_id from effective_care_t;

-- A complete list of this information is in the hospitals.pdf document, but effective_care_t
-- does not contain all the measure ids listed therein.

	-- measure_id
	-- AMI_10
	-- AMI_2
	-- AMI_7A
	-- AMI_8A
	-- CAC_1
	-- CAC_2
	-- CAC_3
	-- EDV
	-- ED_1B
	-- ED_2B
	-- HF_1
	-- HF_2
	-- HF_3
	-- IMM_2
	-- IMM_3_FAC_ADHPCT
	-- OP_1
	-- OP_18B
	-- OP_2
	-- OP_20
	-- OP_21
	-- OP_22
	-- OP_23
	-- OP_3B
	-- OP_4
	-- OP_5
	-- OP_6
	-- OP_7
	-- PC_01
	-- PN_6
	-- SCIP_CARD_2
	-- SCIP_INF_1
	-- SCIP_INF_10
	-- SCIP_INF_2
	-- SCIP_INF_3
	-- SCIP_INF_4
	-- SCIP_INF_9
	-- SCIP_VTE_2
	-- STK_1
	-- STK_10
	-- STK_2
	-- STK_3
	-- STK_4
	-- STK_5
	-- STK_6
	-- STK_8
	-- VTE_1
	-- VTE_2
	-- VTE_3
	-- VTE_4
	-- VTE_5
	-- VTE_6
	-- Time taken: 48.738 seconds, Fetched: 51 row(s)

-- let's run through this list and figure out if it high scores are good, or high scores
-- are bad.  I'll name the categories "B" for basketball (highscore good) and
-- "G" for golf (high scores bad).

--measure_id
-- AMI_10 B
-- AMI_2 B
-- AMI_7A B
-- AMI_8A B
-- CAC_1 B
-- CAC_2 B
-- CAC_3 B
-- EDV  NULL
-- ED_1B G
-- ED_2B G
-- HF_1 B
-- HF_2 B
-- HF_3 B
-- IMM_2 B
-- IMM_3_FAC_ADHPCT B
-- OP_1 G
-- OP_18B G
-- OP_2 B
-- OP_20 G
-- OP_21 G
-- OP_22 G
-- OP_23 B
-- OP_3B G
-- OP_4 B
-- OP_5 G
-- OP_6 B
-- OP_7 B
-- PC_01 G
-- PN_6 B
-- SCIP_CARD_2 B
-- SCIP_INF_1 B
-- SCIP_INF_10 B
-- SCIP_INF_2 B
-- SCIP_INF_3 B
-- SCIP_INF_4 B
-- SCIP_INF_9 B 
-- SCIP_VTE_2 B
-- STK_1 B
-- STK_10 B
-- STK_2 B
-- STK_3 B
-- STK_4 B
-- STK_5 B
-- STK_6 B
-- STK_8 B
-- VTE_1 B
-- VTE_2 B
-- VTE_3 B
-- VTE_4 B
-- VTE_5 B
-- VTE_6 G


-- OP1 often appears to be NA
select score, count(score) from effective_care_t where measure_id l= 'OP_1' group by score;
-- score	_c1
-- NULL	0
-- 15	1
-- 16	2
-- 18	3
-- 19	1
-- 20	5
-- 21	3
-- 22	8
-- 23	4
-- 24	6
-- 25	6
-- 26	8
-- 27	2
-- 28	6
-- 30	2
-- 31	1
-- 32	1
-- 33	1
-- 34	1
-- 36	1
-- 37	1
-- 39	1
-- 40	1
-- 42	1
-- 45	1
-- 64	1

-- adding a supplementary table to include the measure_ids,
-- whether the a high score is good "B", a low score is 
-- good, "G", and threshold information from the Value Based
-- Purchasing guidelines found here: https://www.lsqin.org/wp-content/uploads/2015/11/FY2018-VBP-Fact-Sheet-11.10.pdf
-- Please note that several of the measure_ids are no longer 
-- included in effective care measures, so their data is hard to 
-- come by.  In these cases, a uniform threshold median is chosen
-- as the threshold.  For example, if the scale is 0 to 100 and 
-- we have no information on the measure id because it is retired,
-- the threshold will be chosen as 50.  AMI-10 and AMI-7A are
-- examples of retired measures

--test percentile measures
select measure_id,
 percentile(score, 0.95) pct from effective_care_t 
  group by measure_id, score

-- OK
-- measure_id	pct
-- AMI_10	100.0
-- AMI_2	100.0
-- AMI_7A	70.69999999999999
-- AMI_8A	100.0
-- CAC_1	100.0
-- CAC_2	100.0
-- CAC_3	100.0
-- EDV	NULL
-- ED_1B	441.25
-- ED_2B	211.25
-- HF_1	100.0
-- HF_2	100.0
-- HF_3	100.0
-- IMM_2	100.0
-- IMM_3_FAC_ADHPCT	99.0
-- OP_1	39.65
-- OP_18B	214.5999999999999
-- OP_2	97.19999999999999
-- OP_20	61.0
-- OP_21	86.0
-- OP_22	5.0
-- OP_23	95.09999999999991
-- OP_3B	118.0
-- OP_4	100.0
-- OP_5	18.0
-- OP_6	100.0
-- OP_7	100.0
-- PC_01	15.0
-- PN_6	100.0
-- SCIP_CARD_2	100.0
-- SCIP_INF_1	100.0
-- SCIP_INF_10	100.0
-- SCIP_INF_2	100.0
-- SCIP_INF_3	100.0
-- SCIP_INF_4	NULL
-- SCIP_INF_9	100.0
-- SCIP_VTE_2	100.0
-- STK_1	100.0
-- STK_10	100.0
-- STK_2	100.0
-- STK_3	100.0
-- STK_4	100.0
-- STK_5	100.0
-- STK_6	100.0
-- STK_8	100.0
-- VTE_1	100.0
-- VTE_2	100.0
-- VTE_3	100.0
-- VTE_4	100.0
-- VTE_5	100.0


select 
e.provider_id,
e.hospital_name,
x.measure_id,
x.pct
from 
(select measure_id,
 percentile(score, 0.95) pct from effective_care_t 
  group by measure_id) x
inner join effective_care_t e
on x.measure_id = e.measure_id 
where e.score > x.pct



-- get data from effective_care_t and measure_sup.

SELECT
m.measure_id,
m.qualifier,
case when m.qualifier = 'B' then percentile(e.score, 0.95) when m.qualifier = 'G' then percentile(e.score, 0.05) else NULL end pct
from measure_supp m
join effective_care_t e
on m.measure_id = e.measure_id
group by m.measure_id, m.qualifier;

	-- AMI_10	B	100.0
	-- AMI_2	B	100.0
	-- AMI_7A	B	70.69999999999999
	-- AMI_8A	B	100.0
	-- CAC_1	B	100.0
	-- CAC_2	B	100.0
	-- CAC_3	B	100.0
	-- EDV	NULL	NULL
	-- ED_1B	G	157.75
	-- ED_2B	G	30.78
	-- HF_1	B	100.0
	-- HF_2	B	100.0
	-- HF_3	B	100.0
	-- IMM_2	B	100.0
	-- IMM_3_FAC_ADHPCT	B	99.0
	-- OP_1	G	16.266666666666666
	-- OP_18B	G	86.58636363636364
	-- OP_2	B	97.19999999999999
	-- OP_20	G	8.683333333333334
	-- OP_21	G	29.45777777777778
	-- OP_22	G	0.0
	-- OP_23	B	95.09999999999991
	-- OP_3B	G	29.408333333333335
	-- OP_4	B	100.0
	-- OP_5	G	1.3198717948717948
	-- OP_6	B	100.0
	-- OP_7	B	100.0
	-- PC_01	G	0.0
	-- PN_6	B	100.0
	-- SCIP_CARD_2	B	100.0
	-- SCIP_INF_1	B	100.0
	-- SCIP_INF_10	B	100.0
	-- SCIP_INF_2	B	100.0
	-- SCIP_INF_3	B	100.0
	-- SCIP_INF_4	B	NULL
	-- SCIP_INF_9	B	100.0
	-- SCIP_VTE_2	B	100.0
	-- STK_1	B	100.0
	-- STK_10	B	100.0
	-- STK_2	B	100.0
	-- STK_3	B	100.0
	-- STK_4	B	100.0
	-- STK_5	B	100.0
	-- STK_6	B	100.0
	-- STK_8	B	100.0
	-- VTE_1	B	100.0
	-- VTE_2	B	100.0
	-- VTE_3	B	100.0
	-- VTE_4	B	100.0
	-- VTE_5	B	100.0
	-- VTE_6	G	0.0
	-- Time taken: 93.09 seconds, Fetched: 51 row(s)


-- sanity check with a high golf:
select measure_id, 
percentile(score, 0.95) high_pct, 
percentile(score, 0.05) low_pct 
from effective_care_t 
where measure_id = "ED_1B" 
group by measure_id;

	-- OK
	-- measure_id	high_pct	low_pct
	-- ED_1B	441.25	157.75
	-- Time taken: 53.227 seconds, Fetched: 1 row(s)

--sweet

Select 
ec.provider_id provider_id,
ec.hospital_name hospital_name,
x.measure_id measure_id,
x.qualifier qualifier,
ec.score score,
x.pct pct
from 
(SELECT
m.measure_id,
m.qualifier,
case when m.qualifier = 'B' then percentile(e.score, 0.95) when m.qualifier = 'G' then percentile(e.score, 0.05) else NULL end pct
from measure_supp m
join effective_care_t e
on m.measure_id = e.measure_id
group by m.measure_id, m.qualifier) x
join 
effective_care_t ec
on 
x.measure_id = ec.measure_id
where (ec.score > x.pct and x.qualifier = 'B') 
OR (ec.score < x.pct and x.qualifier = 'G')

--returns

	-- OK
	-- provider_id	hospital_name	measure_id	qualifier	score	pct
	-- 10012	DEKALB REGIONAL MEDICAL CENTER	OP_23	B	100	95.09999999999991
	-- 10012	DEKALB REGIONAL MEDICAL CENTER	OP_5	G	1	2.0
	-- 10036	ANDALUSIA REGIONAL HOSPITAL	OP_20	G	8	9.0
	-- 10036	ANDALUSIA REGIONAL HOSPITAL	OP_21	G	26	30.0
	-- 10036	ANDALUSIA REGIONAL HOSPITAL	OP_5	G	0	2.0
	-- 10038	STRINGFELLOW MEMORIAL HOSPITAL	OP_18B	G	85	87.0
	-- 10047	GEORGIANA MEDICAL CENTER	ED_1B	G	127	157.75
	-- 10047	GEORGIANA MEDICAL CENTER	ED_2B	G	30	31.0
	-- 10049	MEDICAL CENTER ENTERPRISE	OP_23	B	100	95.09999999999991
	-- 10051	GREENE COUNTY HOSPITAL	ED_2B	G	8	31.0
	-- 10059	LAWRENCE MEDICAL CENTER	OP_18B	G	81	87.0
	-- 10083	SOUTH BALDWIN REGIONAL MEDICAL CENTER	OP_23	B	100	95.09999999999991
	-- 10089	WALKER BAPTIST MEDICAL CENTER	OP_5	G	0	2.0


-- I would like now to count up all the different hospitals with the highest scores and see who has the most measures
-- in the 95th percentile (for Basketball) or 5th percentile (for Golf)

SELECT
y.provider_id provider_id,
y.hospital_name hospital_name,
count(y.provider_id) no_of_high_measure
FROM 
(Select 
ec.provider_id provider_id,
ec.hospital_name hospital_name,
x.measure_id measure_id,
x.qualifier qualifier,
ec.score score,
x.pct pct
from 
(SELECT
m.measure_id,
m.qualifier,
case when m.qualifier = 'B' then percentile(e.score, 0.95) when m.qualifier = 'G' then percentile(e.score, 0.05) else NULL end pct
from measure_supp m
join effective_care_t e
on m.measure_id = e.measure_id
group by m.measure_id, m.qualifier) x
join 
effective_care_t ec
on 
x.measure_id = ec.measure_id
where (ec.score > x.pct and x.qualifier = 'B') 
OR (ec.score < x.pct and x.qualifier = 'G')) y
group by y.provider_id, y.hospital_name;


SELECT 
z.provider_id provider_id,
z.hospital_name hospital_name,
z.no_of_high_measure no_of_high_measure
FROM
(SELECT
y.provider_id provider_id,
y.hospital_name hospital_name,
count(y.provider_id) no_of_high_measure
FROM 
(Select 
ec.provider_id provider_id,
ec.hospital_name hospital_name,
x.measure_id measure_id,
x.qualifier qualifier,
ec.score score,
x.pct pct
from 
(SELECT
m.measure_id,
m.qualifier,
case when m.qualifier = 'B' then percentile(e.score, 0.95) when m.qualifier = 'G' then percentile(e.score, 0.05) else NULL end pct
from measure_supp m
join effective_care_t e
on m.measure_id = e.measure_id
group by m.measure_id, m.qualifier) x
join 
effective_care_t ec
on 
x.measure_id = ec.measure_id
where (ec.score > x.pct and x.qualifier = 'B') 
OR (ec.score < x.pct and x.qualifier = 'G')) y
group by y.provider_id, y.hospital_name) z
ORDER BY no_of_high_measure DESC
Limit 10;


-- results:
-- provider_id	hospital_name	no_of_high_measure
-- 450845	EL PASO SPECIALTY HOSPITAL	5
-- 171308	MERCY HOSPITAL COLUMBUS	4
-- 170027	PRATT REGIONAL MEDICAL CENTER	4
-- 10125	LAKELAND COMMUNITY HOSPITAL	4
-- 171354	COMMUNITY HOSPITAL, ONAGA AND ST MARYS CAMPUS	4
-- 370072	LATIMER COUNTY GENERAL HOSPITAL	4
-- 670058	EMERUS HOSPITAL	4
-- 441311	TRISTAR ASHLAND CITY MEDICAL CENTER	3
-- 190090	WINN PARISH MEDICAL CENTER	3
-- 260142	FITZGIBBON HOSPITAL	3
-- Time taken: 221.098 seconds, Fetched: 10 row(s)


-- what is the average number of measures per hospital? 5 seems kinda low, and #1 (El Paso Speciality) has only 27 beds

Select 
avg(x.measure_cnt)
from 
(select provider_id provider_id, count(provider_id) measure_cnt
from effective_care_t
group by provider_id) x

-- returns 46.21217948717949

-- yeah, I think I identified a sparsity problem, not the best.  Trying with a looser threshold.  If this doesn't work I can 
-- use logspace too, since the data is quite skewed

SELECT 
z.provider_id provider_id,
z.hospital_name hospital_name,
z.no_of_high_measure no_of_high_measure
FROM
(SELECT
y.provider_id provider_id,
y.hospital_name hospital_name,
count(y.provider_id) no_of_high_measure
FROM 
(Select 
ec.provider_id provider_id,
ec.hospital_name hospital_name,
x.measure_id measure_id,
x.qualifier qualifier,
ec.score score,
x.pct pct
from 
(SELECT
m.measure_id,
m.qualifier,
case when m.qualifier = 'B' then percentile(e.score, 0.75) when m.qualifier = 'G' then percentile(e.score, 0.25) else NULL end pct
from measure_supp m
join effective_care_t e
on m.measure_id = e.measure_id
group by m.measure_id, m.qualifier) x
join 
effective_care_t ec
on 
x.measure_id = ec.measure_id
where (ec.score > x.pct and x.qualifier = 'B') 
OR (ec.score < x.pct and x.qualifier = 'G')) y
group by y.provider_id, y.hospital_name) z
where no_of_high_measure > 9
ORDER BY no_of_high_measure DESC
Limit 10;


-- provider_id	hospital_name	no_of_high_measure
-- 180127	FRANKFORT REGIONAL MEDICAL CENTER	11
-- 390071	LOCK HAVEN HOSPITAL	11
-- 420087	ROPER HOSPITAL	11
-- 361308	UNIVERSITY HOSPITALS CONNEAUT MEDICAL CENTER	10
-- 670006	THE HOSPITAL AT WESTLAKE MEDICAL CENTER	10
-- 170176	OVERLAND PARK REG MED CTR	10
-- 260190	LEE'S SUMMIT MEDICAL CENTER	10
-- 151323	PARKVIEW LAGRANGE HOSPITAL	10
-- 261320	LAFAYETTE REGIONAL HEALTH CENTER	10
-- 420104	MOUNT PLEASANT HOSPITAL	10


-- At least most of these hospitals have very high ranks according to US News and World Report
-- however this data is still sparse



select 
ec.provider_id provider_id,
ec.hospital_name hospital_name,
m.qualifier,
sum(ec.score) as total_score
from measure_supp m
join effective_care_t ec
on m.measure_id = ec.measure_id
where state = "VT"
and m.qualifier in ("B", "G")
group by ec.provider_id, ec.hospital_name, m.qualifier

-- OK
-- provider_id	hospital_name	m.qualifier	total_score
-- NULL	WHITE RIVER JCT VA MEDICAL CENTER	B	764
-- 470001	CENTRAL VERMONT MEDICAL CENTER	B	2793
-- 470001	CENTRAL VERMONT MEDICAL CENTER	G	715
-- 470003	UNIVERSITY OF VERMONT MEDICAL CENTER	B	2947
-- 470003	UNIVERSITY OF VERMONT MEDICAL CENTER	G	770
-- 470005	RUTLAND REGIONAL MEDICAL CENTER	B	3006
-- 470005	RUTLAND REGIONAL MEDICAL CENTER	G	561
-- 470011	BRATTLEBORO MEMORIAL HOSPITAL	B	2427
-- 470011	BRATTLEBORO MEMORIAL HOSPITAL	G	610
-- 470012	SOUTHWESTERN VERMONT MEDICAL CENTER	B	2591
-- 470012	SOUTHWESTERN VERMONT MEDICAL CENTER	G	721
-- 470024	NORTHWESTERN MEDICAL CENTER INC	B	2599
-- 470024	NORTHWESTERN MEDICAL CENTER INC	G	437
-- 471300	GRACE COTTAGE HOSPITAL	B	272
-- 471300	GRACE COTTAGE HOSPITAL	G	NULL
-- 471301	GIFFORD MEDICAL CENTER	B	978
-- 471301	GIFFORD MEDICAL CENTER	G	NULL
-- 471302	MT ASCUTNEY HOSPITAL	B	NULL
-- 471302	MT ASCUTNEY HOSPITAL	G	NULL
-- 471303	NORTHEASTERN VERMONT REGIONAL HOSPITAL	B	865
-- 471303	NORTHEASTERN VERMONT REGIONAL HOSPITAL	G	NULL
-- 471304	NORTH COUNTRY HOSPITAL AND HEALTH CENTER	B	978
-- 471304	NORTH COUNTRY HOSPITAL AND HEALTH CENTER	G	NULL
-- 471305	COPLEY HOSPITAL	B	928
-- 471305	COPLEY HOSPITAL	G	NULL
-- 471306	SPRINGFIELD HOSPITAL	B	993
-- 471306	SPRINGFIELD HOSPITAL	G	NULL
-- 471307	PORTER HOSPITAL, INC	B	1087
-- 471307	PORTER HOSPITAL, INC	G	NULL
-- Time taken: 68.029 seconds, Fetched: 29 row(s)


--Get percentiles

select 
x.qualifier qualifier,
case when x.qualifier = "B" then percentile(x.total_score, 0.90) when x.qualifier = "G" then percentile(x.total_score, 0.10) end as pct 
from 
(select 
ec.provider_id provider_id,
ec.hospital_name hospital_name,
m.qualifier,
sum(ec.score) as total_score
from measure_supp m
join effective_care_t ec
on m.measure_id = ec.measure_id
where state = "CO"
and m.qualifier in ("B", "G")
group by ec.provider_id, ec.hospital_name, m.qualifier) x
group by x.qualifier

--that was not crazy

-- OK
-- qualifier	pct
-- B	3049.8
-- G	187.40000000000003

--tie it together
Select 
y.provider_id provider_id,
y.hospital_name hospital_name,
z.qualifier,
y.total_score
from 
(select 
x.qualifier qualifier,
case when x.qualifier = "B" then percentile(x.total_score, 0.90) when x.qualifier = "G" then percentile(x.total_score, 0.10) end as pct 
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
-- state = "CO" and 
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
--state = "CO" and 
m.qualifier in ("B", "G")
group by ec.provider_id, ec.hospital_name, m.qualifier) y 
on 
z.qualifier = y.qualifier
WHERE
(y.total_score < z.pct AND z.qualifier = "G")
OR (y.total_score > z.pct AND z.qualifier = "B")


-- Now we're getting somewhere:
-- OK
-- provider_id	hospital_name	z.qualifier	y.total_score
-- 10035	CULLMAN REGIONAL MEDICAL CENTER	B	3049
-- 10039	HUNTSVILLE HOSPITAL	B	3398
-- 11302	RED BAY HOSPITAL	G	21
-- 21306	PROVIDENCE KODIAK ISLAND MEDICAL CTR	G	2
-- 21313	SOUTH PENINSULA HOSPITAL	G	8
-- 30023	FLAGSTAFF MEDICAL CENTER	B	3059
-- 30024	ST JOSEPH'S HOSPITAL AND MEDICAL CENTER	B	3153
-- 30036	CHANDLER REGIONAL MEDICAL CENTER	B	3210
-- 30064	BANNER-UNIVERSITY MEDICAL CENTER TUCSON CAMPUS	B	3217
-- 30065	BANNER DESERT MEDICAL CENTER	B	3304
-- 30085	NORTHWEST MEDICAL CENTER	B	3097
-- 30092	DEER VALLEY MEDICAL CENTER	B	3114
-- 30093	BANNER DEL E WEBB MEDICAL CENTER	B	3039
-- 30103	MAYO CLINIC HOSPITAL	B	3088
-- 30110	ABRAZO WEST CAMPUS	B	3086
-- 30115	BANNER ESTRELLA MEDICAL CENTER	B	3182
-- 30119	MERCY GILBERT MEDICAL CENTER	B	3041
-- 31300	WICKENBURG COMMUNITY HOSPITAL	G	13
-- 31304	PAGE HOSPITAL	G	5
-- 31315	WHITE MOUNTAIN REGIONAL MEDICAL CENTER	G	2
-- 40020	ST BERNARDS MEDICAL CENTER	B	3198
-- 40118	NEA BAPTIST MEMORIAL HOSPITAL	B	3163
-- 40147	ARKANSAS SURGICAL HOSPITAL	G	135
-- 40152	PHYSICIANS' SPECIALTY HOSPITAL	G	125
-- 41302	RIVER VALLEY MEDICAL CENTER	G	8
-- 41307	CROSSRIDGE COMMUNITY HOSPITAL	G	4
