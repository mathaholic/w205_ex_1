-- Best Hospitals - EDA
-- By Nikki Haas
-- w205 Exercise 1

-- don't run
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
-- measure_iddenominatorscorecompared_to_national
-- MORT_30_AMI69912.20
-- MORT_30_CABG2693.70
-- MORT_30_COPD5668.80
-- MORT_30_HF77612.60
-- MORT_30_PN37411.60
-- MORT_30_STK49515.30
-- READM_30_AMI77217.40
-- READM_30_CABG26615.90
-- READM_30_COPD68722.00
-- READM_30_HF95821.00
-- READM_30_HIP_KNEE3295.20
-- READM_30_HOSP_WIDE530914.80
-- READM_30_PN42318.20
-- READM_30_STK49313.00
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
-- score_c1
--11801
-- 11321
-- 11231
-- 10501

select * from effective_care_t where score > 1000;
-- OK
-- effective_care_t.provider_ideffective_care_t.hospital_nameeffective_care_t.addresseffective_care_t.cityeffective_care_t.stateeffective_care_t.zip_codeeffective_care_t.countyeffective_care_t.phoneeffective_care_t.conditioneffective_care_t.measure_ideffective_care_t.measure_nameeffective_care_t.scoreeffective_care_t.sampleeffective_care_t.footnoteeffective_care_t.measure_start_dateeffective_care_t.measure_end_date
-- 310002NEWARK BETH ISRAEL MEDICAL CENTER201 LYONS AVENEWARKNJ7112ESSEX9739267850EMERGENCY DEPARTMENTED_1BED11123609["2"]2013-10-012014-09-30
-- 400079HOSP COMUNITARIO BUEN SAMARITANOCARR.2 KM.1.4 AVE. SEVERIANO CUEVAS #18AGUADILLAPR603AGUADILLA7876580000EMERGENCY DEPARTMENTED_1BED11050717["2","3"]2013-10-012014-09-30
-- 450348FALLS COMMUNITY HOSPITAL AND CLINIC322 COLEMAN STREETMARLINTX76661FALLS2548033561EMERGENCY DEPARTMENTED_1BED11180313["2"]2013-10-012014-09-30
-- 450348FALLS COMMUNITY HOSPITAL AND CLINIC322 COLEMAN STREETMARLINTX76661FALLS2548033561EMERGENCY DEPARTMENTED_2BED21132285["2"]2013-10-012014-09-30
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
-- score_c1
-- NULL0
-- 151
-- 162
-- 183
-- 191
-- 205
-- 213
-- 228
-- 234
-- 246
-- 256
-- 268
-- 272
-- 286
-- 302
-- 311
-- 321
-- 331
-- 341
-- 361
-- 371
-- 391
-- 401
-- 421
-- 451
-- 641

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
-- measure_idpct
-- AMI_10100.0
-- AMI_2100.0
-- AMI_7A70.69999999999999
-- AMI_8A100.0
-- CAC_1100.0
-- CAC_2100.0
-- CAC_3100.0
-- EDVNULL
-- ED_1B441.25
-- ED_2B211.25
-- HF_1100.0
-- HF_2100.0
-- HF_3100.0
-- IMM_2100.0
-- IMM_3_FAC_ADHPCT99.0
-- OP_139.65
-- OP_18B214.5999999999999
-- OP_297.19999999999999
-- OP_2061.0
-- OP_2186.0
-- OP_225.0
-- OP_2395.09999999999991
-- OP_3B118.0
-- OP_4100.0
-- OP_518.0
-- OP_6100.0
-- OP_7100.0
-- PC_0115.0
-- PN_6100.0
-- SCIP_CARD_2100.0
-- SCIP_INF_1100.0
-- SCIP_INF_10100.0
-- SCIP_INF_2100.0
-- SCIP_INF_3100.0
-- SCIP_INF_4NULL
-- SCIP_INF_9100.0
-- SCIP_VTE_2100.0
-- STK_1100.0
-- STK_10100.0
-- STK_2100.0
-- STK_3100.0
-- STK_4100.0
-- STK_5100.0
-- STK_6100.0
-- STK_8100.0
-- VTE_1100.0
-- VTE_2100.0
-- VTE_3100.0
-- VTE_4100.0
-- VTE_5100.0


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

-- AMI_10B100.0
-- AMI_2B100.0
-- AMI_7AB70.69999999999999
-- AMI_8AB100.0
-- CAC_1B100.0
-- CAC_2B100.0
-- CAC_3B100.0
-- EDVNULLNULL
-- ED_1BG157.75
-- ED_2BG30.78
-- HF_1B100.0
-- HF_2B100.0
-- HF_3B100.0
-- IMM_2B100.0
-- IMM_3_FAC_ADHPCTB99.0
-- OP_1G16.266666666666666
-- OP_18BG86.58636363636364
-- OP_2B97.19999999999999
-- OP_20G8.683333333333334
-- OP_21G29.45777777777778
-- OP_22G0.0
-- OP_23B95.09999999999991
-- OP_3BG29.408333333333335
-- OP_4B100.0
-- OP_5G1.3198717948717948
-- OP_6B100.0
-- OP_7B100.0
-- PC_01G0.0
-- PN_6B100.0
-- SCIP_CARD_2B100.0
-- SCIP_INF_1B100.0
-- SCIP_INF_10B100.0
-- SCIP_INF_2B100.0
-- SCIP_INF_3B100.0
-- SCIP_INF_4BNULL
-- SCIP_INF_9B100.0
-- SCIP_VTE_2B100.0
-- STK_1B100.0
-- STK_10B100.0
-- STK_2B100.0
-- STK_3B100.0
-- STK_4B100.0
-- STK_5B100.0
-- STK_6B100.0
-- STK_8B100.0
-- VTE_1B100.0
-- VTE_2B100.0
-- VTE_3B100.0
-- VTE_4B100.0
-- VTE_5B100.0
-- VTE_6G0.0
-- Time taken: 93.09 seconds, Fetched: 51 row(s)


-- sanity check with a high golf:
select measure_id, 
percentile(score, 0.95) high_pct, 
percentile(score, 0.05) low_pct 
from effective_care_t 
where measure_id = "ED_1B" 
group by measure_id;

-- OK
-- measure_idhigh_pctlow_pct
-- ED_1B441.25157.75
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
-- provider_idhospital_namemeasure_idqualifierscorepct
-- 10012DEKALB REGIONAL MEDICAL CENTEROP_23B10095.09999999999991
-- 10012DEKALB REGIONAL MEDICAL CENTEROP_5G12.0
-- 10036ANDALUSIA REGIONAL HOSPITALOP_20G89.0
-- 10036ANDALUSIA REGIONAL HOSPITALOP_21G2630.0
-- 10036ANDALUSIA REGIONAL HOSPITALOP_5G02.0
-- 10038STRINGFELLOW MEMORIAL HOSPITALOP_18BG8587.0
-- 10047GEORGIANA MEDICAL CENTERED_1BG127157.75
-- 10047GEORGIANA MEDICAL CENTERED_2BG3031.0
-- 10049MEDICAL CENTER ENTERPRISEOP_23B10095.09999999999991
-- 10051GREENE COUNTY HOSPITALED_2BG831.0
-- 10059LAWRENCE MEDICAL CENTEROP_18BG8187.0
-- 10083SOUTH BALDWIN REGIONAL MEDICAL CENTEROP_23B10095.09999999999991
-- 10089WALKER BAPTIST MEDICAL CENTEROP_5G02.0


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
-- provider_idhospital_nameno_of_high_measure
-- 450845EL PASO SPECIALTY HOSPITAL5
-- 171308MERCY HOSPITAL COLUMBUS4
-- 170027PRATT REGIONAL MEDICAL CENTER4
-- 10125LAKELAND COMMUNITY HOSPITAL4
-- 171354COMMUNITY HOSPITAL, ONAGA AND ST MARYS CAMPUS4
-- 370072LATIMER COUNTY GENERAL HOSPITAL4
-- 670058EMERUS HOSPITAL4
-- 441311TRISTAR ASHLAND CITY MEDICAL CENTER3
-- 190090WINN PARISH MEDICAL CENTER3
-- 260142FITZGIBBON HOSPITAL3
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


-- provider_idhospital_nameno_of_high_measure
-- 180127FRANKFORT REGIONAL MEDICAL CENTER11
-- 390071LOCK HAVEN HOSPITAL11
-- 420087ROPER HOSPITAL11
-- 361308UNIVERSITY HOSPITALS CONNEAUT MEDICAL CENTER10
-- 670006THE HOSPITAL AT WESTLAKE MEDICAL CENTER10
-- 170176OVERLAND PARK REG MED CTR10
-- 260190LEE'S SUMMIT MEDICAL CENTER10
-- 151323PARKVIEW LAGRANGE HOSPITAL10
-- 261320LAFAYETTE REGIONAL HEALTH CENTER10
-- 420104MOUNT PLEASANT HOSPITAL10


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
-- provider_idhospital_namem.qualifiertotal_score
-- NULLWHITE RIVER JCT VA MEDICAL CENTERB764
-- 470001CENTRAL VERMONT MEDICAL CENTERB2793
-- 470001CENTRAL VERMONT MEDICAL CENTERG715
-- 470003UNIVERSITY OF VERMONT MEDICAL CENTERB2947
-- 470003UNIVERSITY OF VERMONT MEDICAL CENTERG770
-- 470005RUTLAND REGIONAL MEDICAL CENTERB3006
-- 470005RUTLAND REGIONAL MEDICAL CENTERG561
-- 470011BRATTLEBORO MEMORIAL HOSPITALB2427
-- 470011BRATTLEBORO MEMORIAL HOSPITALG610
-- 470012SOUTHWESTERN VERMONT MEDICAL CENTERB2591
-- 470012SOUTHWESTERN VERMONT MEDICAL CENTERG721
-- 470024NORTHWESTERN MEDICAL CENTER INCB2599
-- 470024NORTHWESTERN MEDICAL CENTER INCG437
-- 471300GRACE COTTAGE HOSPITALB272
-- 471300GRACE COTTAGE HOSPITALGNULL
-- 471301GIFFORD MEDICAL CENTERB978
-- 471301GIFFORD MEDICAL CENTERGNULL
-- 471302MT ASCUTNEY HOSPITALBNULL
-- 471302MT ASCUTNEY HOSPITALGNULL
-- 471303NORTHEASTERN VERMONT REGIONAL HOSPITALB865
-- 471303NORTHEASTERN VERMONT REGIONAL HOSPITALGNULL
-- 471304NORTH COUNTRY HOSPITAL AND HEALTH CENTERB978
-- 471304NORTH COUNTRY HOSPITAL AND HEALTH CENTERGNULL
-- 471305COPLEY HOSPITALB928
-- 471305COPLEY HOSPITALGNULL
-- 471306SPRINGFIELD HOSPITALB993
-- 471306SPRINGFIELD HOSPITALGNULL
-- 471307PORTER HOSPITAL, INCB1087
-- 471307PORTER HOSPITAL, INCGNULL
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
-- qualifierpct
-- B3049.8
-- G187.40000000000003

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
-- provider_idhospital_namez.qualifiery.total_score
-- 10035CULLMAN REGIONAL MEDICAL CENTERB3049
-- 10039HUNTSVILLE HOSPITALB3398
-- 11302RED BAY HOSPITALG21
-- 21306PROVIDENCE KODIAK ISLAND MEDICAL CTRG2
-- 21313SOUTH PENINSULA HOSPITALG8
-- 30023FLAGSTAFF MEDICAL CENTERB3059
-- 30024ST JOSEPH'S HOSPITAL AND MEDICAL CENTERB3153
-- 30036CHANDLER REGIONAL MEDICAL CENTERB3210
-- 30064BANNER-UNIVERSITY MEDICAL CENTER TUCSON CAMPUSB3217
-- 30065BANNER DESERT MEDICAL CENTERB3304
-- 30085NORTHWEST MEDICAL CENTERB3097
-- 30092DEER VALLEY MEDICAL CENTERB3114
-- 30093BANNER DEL E WEBB MEDICAL CENTERB3039
-- 30103MAYO CLINIC HOSPITALB3088
-- 30110ABRAZO WEST CAMPUSB3086
-- 30115BANNER ESTRELLA MEDICAL CENTERB3182
-- 30119MERCY GILBERT MEDICAL CENTERB3041
-- 31300WICKENBURG COMMUNITY HOSPITALG13
-- 31304PAGE HOSPITALG5
-- 31315WHITE MOUNTAIN REGIONAL MEDICAL CENTERG2
-- 40020ST BERNARDS MEDICAL CENTERB3198
-- 40118NEA BAPTIST MEMORIAL HOSPITALB3163
-- 40147ARKANSAS SURGICAL HOSPITALG135
-- 40152PHYSICIANS' SPECIALTY HOSPITALG125
-- 41302RIVER VALLEY MEDICAL CENTERG8
-- 41307CROSSRIDGE COMMUNITY HOSPITALG4


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


-- Gave good results, now try to find the ones where it has both G and B
SELECT
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
case when x.qualifier = "B" then percentile(x.total_score, 0.80) when x.qualifier = "G" then percentile(x.total_score, 0.20) end as pct 
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
OR (y.total_score > z.pct AND z.qualifier = "B")) w
group by w.provider_id, w.hospital_name
having count(w.provider_id) > 1


-- returns 0 rows with 0.9 and 0.1 percentile, respectively

-- try 80/20

-- OK
-- provider_idhospital_nametotal_count
-- 50424SCRIPPS GREEN HOSPITAL2
-- 160069MERCY MEDICAL CENTER-DUBUQUE2
-- 170176OVERLAND PARK REG MED CTR2
-- 190144MINDEN MEDICAL CENTER2
-- 280077FREMONT HEALTH MEDICAL CENTER2
-- 420087ROPER HOSPITAL2
-- 500152SWEDISH ISSAQUAH2
-- Time taken: 304.573 seconds, Fetched: 7 row(s)

--provider_id IN (50424,160069, 170176, 190144, 280077, 500152)
--Done

-- Sanity check:
Select 
y.provider_id provider_id,
y.hospital_name hospital_name,
z.qualifier,
y.total_score
from 
(select 
x.qualifier qualifier,
case when x.qualifier = "B" then percentile(x.total_score, 0.80) when x.qualifier = "G" then percentile(x.total_score, 0.20) end as pct 
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
((y.total_score < z.pct AND z.qualifier = "G")
OR (y.total_score > z.pct AND z.qualifier = "B"))
AND provider_id IN (50424,160069, 170176, 190144, 280077, 500152);

-- looks normal, OK, cool, moving on...

-- SELECT
-- ec.provider_id,
-- ec.hospital_name,
-- case when sup.qualifier = "B" then ec.score else 0 end b_score
-- case when sup.qualifier = "G" then ec.score else 0 end g_score
-- from
-- (

SELECT w.provider_id provider_id,
w.hospital_name hospital_name,
w.qualifier qualifier,
w.total_score total_score,
count(w.provider_id) total_count
from (
Select 
y.provider_id provider_id,
y.hospital_name hospital_name,
z.qualifier qualifier,
y.total_score total_score
from 
(select 
x.qualifier qualifier,
case when x.qualifier = "B" then percentile(x.total_score, 0.78) when x.qualifier = "G" then percentile(x.total_score, 0.22) end as pct 
from 
(select 
ec.provider_id provider_id,
ec.hospital_name hospital_name,
m.qualifier qualifier,
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
group by w.provider_id, w.hospital_name,w.qualifier, w.total_score

-- ) u 
-- join 
-- effective_care_t ec 
-- on 
-- u.provider_id = ec.provider_id


-- final table:

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

-- returns
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