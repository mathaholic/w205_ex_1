-- hospital_variability_exploratory_data_analysis.hql-- Hospital Variability - Investigations
-- By Nikki Haas
-- w205 Exercise 1

-- run as hive -f hospital_variability.hql

-- Ivestigate the question:
-- Which procedures have the greatest variability between hospitals?

-- go to effective_care_t, pivot on the measure_ids, the get the  variability of each


SELECT
measure_id measure_id,
measure_name measure_name,
count(measure_id) measure_popularity,
variance(score) score_var
from effective_care_t
group by measure_id, measure_name;

-- returns
-- OK
-- measure_id	measure_name	measure_popularity	score_var
-- AMI_10	STATIN AT DISCHARGE	4656	31.595224408356682
-- AMI_2	ASPIRIN PRESCRIBED AT DISCHARGE	4656	14.485360560345837
-- AMI_7A	FIBRINOLYTIC THERAPY RECEIVED WITHIN 30 MINUTES OF HOSPITAL ARRIVAL	4785	352.6666666666667
-- AMI_8A	PRIMARY PCI RECEIVED WITHIN 90 MINUTES OF HOSPITAL ARRIVAL	4785	44.81676591924561
-- CAC_1	RELIEVERS FOR INPATIENT ASTHMA	103	0.020193431820597303
-- CAC_2	SYSTEMIC CORTICOSTEROIDS FOR INPATIENT ASTHMA	103	1.6471463492400888
-- CAC_3	HOME MANAGEMENT PLAN OF CARE DOCUMENT	102	161.7760416666667
-- EDV	EMERGENCY DEPARTMENT VOLUME	4679	NULL
-- ED_1B	ED1	4656	8617.740839212507
-- ED_2B	ED2	4656	3864.6924460743544
-- HF_1	DISCHARGE INSTRUCTIONS	4656	139.9011388469527
-- HF_2	EVALUATION OF LVS FUNCTION	4785	108.40606462202838
-- HF_3	ACEI OR ARB FOR LVSD	4656	41.74263736700456
-- IMM_2	IMMUNIZATION FOR INFLUENZA	4778	142.68029969125467
-- IMM_3_FAC_ADHPCT	HEALTHCARE WORKERS GIVEN INFLUENZA VACCINATION	3657	267.25866979161765
-- OP_1	MEDIAN TIME TO FIBRINOLYSIS	4111	57.20588235294118
-- OP_18B	OP 18	4111	1656.5529409803205
-- OP_2	FIBRINOLYTIC THERAPY RECEIVED WITHIN 30 MINUTES OF ED ARRIVAL	4111	325.74632352941165
-- OP_20	DOOR TO DIAGNOSTIC EVAL	4111	285.00371267017476
-- OP_21	MEDIAN TIME TO PAIN MED	4111	314.0819735739413
-- OP_22	LEFT BEFORE BEING SEEN	4111	2.9468931849164655
-- OP_23	HEAD CT RESULTS	4111	477.18888614639235
-- OP_3B	MEDIAN TIME TO TRANSFER TO ANOTHER FACILITY FOR ACUTE CORONARY INTERVENTION	4111	869.0306968514053
-- OP_4	ASPIRIN AT ARRIVAL	4111	27.10450276416237
-- OP_5	MEDIAN TIME TO ECG	4111	37.32454597926683
-- OP_6	PROPHYLACTIC ANTIBIOTIC INITIATED WITHIN ONE HOUR PRIOR TO SURGICAL INCISION	4111	25.695019345256917
-- OP_7	PROPHYLACTIC ANTIBIOTIC SELECTION FOR SURGICAL PATIENTS	4111	15.333263105383406
-- PC_01	PERCENT OF NEWBORNS WHOSE DELIVERIES WERE SCHEDULED EARLY (1-3 WEEKS EARLY), WHEN A SCHEDULED DELIVERY WAS NOT MEDICALLY NECESSARY	4656	48.41735386747294
-- PN_6	INITIAL ANTIBIOTIC SELECTION FOR CAP IN IMMUNOCOMPETENT PATIENT	4785	86.04221827311703
-- SCIP_CARD_2	SURGERY PATIENTS ON A BETA BLOCKER PRIOR TO ARRIVAL WHO RECEIVED A BETA BLOCKER DURING THE PERIOPERATIVE PERIOD	4785	32.055614040094476
-- SCIP_INF_1	PROPHYLACTIC ANTIBIOTIC RECEIVED WITHIN 1 HOUR PRIOR TO SURGICAL INCISION	4785	32.88189497007928
-- SCIP_INF_10	SURGERY PATIENTS WITH PERIOPERATIVE TEMPERATURE MANAGEMENT	4656	5.291112646631726
-- SCIP_INF_2	PROPHYLACTIC ANTIBIOTIC SELECTION FOR SURGICAL PATIENTS	4785	17.352251551548402
-- SCIP_INF_3	PROPHYLACTIC ANTIBIOTICS DISCONTINUED WITHIN 24 HOURS AFTER SURGERY END TIME	4785	21.81881722378057
-- SCIP_INF_4	CARDIAC SURGERY PATIENTS WITH CONTROLLED 6 A.M. POSTOPERATIVE BLOOD GLUCOSE	4785	NULL
-- SCIP_INF_9	POSTOPERATIVE URINARY CATHETER REMOVAL	4785	23.611219427550832
-- SCIP_VTE_2	SURGERY PATIENTS WHO RECEIVED APPROPRIATE VENOUS THROMBOEMBOLISM PROPHYLAXIS WITHIN 24 HOURS PRIOR TO SURGERY TO 24 HOURS AFTER SURGERY	4785	22.018134656657434
-- STK_1	VENOUS THROMBOEMBOLISM (VTE) PROPHYLAXIS	4656	80.29629988698409
-- STK_10	ASSESSED FOR REHABILITATION	4656	32.136432097067704
-- STK_2	DISCHARGED ON ANTITHROMBOTIC THERAPY	4656	15.071783078600157
-- STK_3	ANTICOAGULATION THERAPY FOR ATRIAL FIBRILLATION/FLUTTER	4656	38.76581274329642
-- STK_4	THROMBOLYTIC THERAPY	4656	481.98665882944397
-- STK_5	ANTITHROMBOTIC THERAPY BY END OF HOSPITAL DAY 2	4656	28.84502387981477
-- STK_6	DISCHARGED ON STATIN MEDICATION	4656	100.74762297044258
-- STK_8	STROKE EDUCATION	4656	196.37153240873673
-- VTE_1	VENOUS THROMBOEMBOLISM PROPHYLAXIS	4656	232.78828961700816
-- VTE_2	ICU VENOUS THROMBOEMBOLISM PROPHYLAXIS	4656	55.92415390473564
-- VTE_3	ANTICOAGULATION OVERLAP THERAPY	4656	63.514327147052875
-- VTE_4	UNFRACTIONATED HEPARIN WITH DOSAGES/PLATELET COUNT MONITORING	4656	31.255488907885557
-- VTE_5	WARFARIN THERAPY DISCHARGE INSTRUCTIONS	4656	265.78796126891007
-- VTE_6	INCIDENCE OF POTENTIALLY PREVENTABLE VTE	4656	65.0033282395833
-- Time taken: 49.668 seconds, Fetched: 51 row(s)


-- ok, this is exactly what I want.  Let us now rank by variance and bring back the top ten


SELECT
measure_id measure_id,
measure_name measure_name,
count(measure_id) measure_popularity,
variance(score) score_var,
rank() over(order by variance(score) DESC)
from effective_care_t
group by measure_id, measure_name
limit 10;

--OK
-- measure_id	measure_name	measure_popularity	score_var	_wcol0
-- ED_1B	ED1	4656	8617.740839212507	1
-- ED_2B	ED2	4656	3864.6924460743544	2
-- OP_18B	OP 18	4111	1656.5529409803205	3
-- OP_3B	MEDIAN TIME TO TRANSFER TO ANOTHER FACILITY FOR ACUTE CORONARY INTERVENTION	4111	869.0306968514053	4
-- STK_4	THROMBOLYTIC THERAPY	4656	481.98665882944397	5
-- OP_23	HEAD CT RESULTS	4111	477.18888614639235	6
-- AMI_7A	FIBRINOLYTIC THERAPY RECEIVED WITHIN 30 MINUTES OF HOSPITAL ARRIVAL	4785	352.6666666666667	7
-- OP_2	FIBRINOLYTIC THERAPY RECEIVED WITHIN 30 MINUTES OF ED ARRIVAL	4111	325.74632352941165	8
-- OP_21	MEDIAN TIME TO PAIN MED	4111	314.0819735739413	9
-- OP_20	DOOR TO DIAGNOSTIC EVAL	4111	285.00371267017476	10

-- this gives only golf measures, let's try it with basketball measures too

SELECT
e.measure_id measure_id,
e.measure_name measure_name,
count(e.measure_id) measure_popularity,
variance(e.score) score_var,
rank() over(order by variance(e.score) DESC) measure_rank
from effective_care_t e
join measure_supp s 
on e.measure_id = s.measure_id
where 
s.qualifier = 'B'
group by e.measure_id, e.measure_name
limit 10;

-- returns
-- measure_id	measure_name	measure_popularity	score_var	_wcol0
-- STK_4	THROMBOLYTIC THERAPY	4656	481.98665882944397	1
-- OP_23	HEAD CT RESULTS	4111	477.18888614639235	2
-- AMI_7A	FIBRINOLYTIC THERAPY RECEIVED WITHIN 30 MINUTES OF HOSPITAL ARRIVAL	4785	352.6666666666667	3
-- OP_2	FIBRINOLYTIC THERAPY RECEIVED WITHIN 30 MINUTES OF ED ARRIVAL	4111	325.74632352941165	4
-- IMM_3_FAC_ADHPCT	HEALTHCARE WORKERS GIVEN INFLUENZA VACCINATION	3657	267.25866979161765	5
-- VTE_5	WARFARIN THERAPY DISCHARGE INSTRUCTIONS	4656	265.78796126891007	6
-- VTE_1	VENOUS THROMBOEMBOLISM PROPHYLAXIS	4656	232.78828961700816	7
-- STK_8	STROKE EDUCATION	4656	196.37153240873673	8
-- CAC_3	HOME MANAGEMENT PLAN OF CARE DOCUMENT	102	161.7760416666667	9
-- IMM_2	IMMUNIZATION FOR INFLUENZA	4778	142.68029969125467	10
-- Time taken: 116.753 seconds, Fetched: 10 row(s)


--eeerrmmmmm...

select min(score), max(score) from effective_care_t where measure_id = "AMI_7A" group by measure_id;

-- should have a range of 0 to 100... but the variance is 352

SELECT
measure_id measure_id,
count(measure_id) measure_popularity,
variance(score) score_var,
rank() over(order by variance(score) DESC)
from effective_care_t
group by measure_id, measure_name
limit 10;

-- results
-- measure_id	measure_popularity	score_var	_wcol0
-- ED_1B	4656	8617.740839212507	1
-- ED_2B	4656	3864.6924460743544	2
-- OP_18B	4111	1656.5529409803205	3
-- OP_3B	4111	869.0306968514053	4
-- STK_4	4656	481.98665882944397	5
-- OP_23	4111	477.18888614639235	6
-- AMI_7A	4785	352.6666666666667	7
-- OP_2	4111	325.74632352941165	8
-- OP_21	4111	314.0819735739413	9
-- OP_20	4111	285.00371267017476	10


select measure_id, min(score) score_min, max(score) score_max, avg(score) score_avg from effective_care_t where 
measure_id in ("ED_1B", "ED_2B", "OP_18B", "OP_3B", "STK_4", "OP_23", "AMI_7A", "OP_2", "OP_21", "OP_20")
group by measure_id;

-- OK
-- measure_id	score_min	score_max	score_avg
-- AMI_7A	27	73	50.0
-- ED_1B	53	1180	271.6069397042093
-- ED_2B	0	1132	98.51859267734554
-- OP_18B	44	443	142.76739325171692
-- OP_2	27	100	70.25
-- OP_20	0	143	28.081991651759093
-- OP_21	12	182	55.35687263556116
-- OP_23	0	100	66.71324296141815
-- OP_3B	21	221	60.74572127139364
-- STK_4	0	100	82.90045766590389
-- Time taken: 48.749 seconds, Fetched: 10 row(s)

--I'm going crazy


SELECT
measure_id measure_id,
count(measure_id) measure_popularity,
var_samp(score) score_var
--rank() over(order by variance(score) DESC)
from effective_care_t
group by measure_id;

--results
-- OK
-- measure_id	measure_popularity	score_var
-- AMI_10	4656	31.609671241648112
-- AMI_2	4656	14.491926906928043
-- AMI_7A	4785	529.0
-- AMI_8A	4785	44.8461154712556
-- CAC_1	103	0.020403780068728526
-- CAC_2	103	1.6643041237113396
-- CAC_3	102	163.4789473684211
-- EDV	4679	NULL
-- ED_1B	4656	8620.192543576437
-- ED_2B	4656	3865.7982235982668
-- HF_1	4656	139.948837837354
-- HF_2	4785	108.43474347510299
-- HF_3	4656	41.75814930954154
-- IMM_2	4778	142.71846991589118
-- IMM_3_FAC_ADHPCT	3657	267.33177117832213
-- OP_1	4111	58.05970149253732
-- OP_18B	4111	1657.047729791844
-- OP_2	4111	330.60820895522374
-- OP_20	4111	285.08871228624105
-- OP_21	4111	314.1810218153711
-- OP_22	4111	2.9478126523688575
-- OP_23	4111	477.6869956308875
-- OP_3B	4111	871.1606740495705
-- OP_4	4111	27.117496293771268
-- OP_5	4111	37.342336515958564
-- OP_6	4111	25.703855321647996
-- OP_7	4111	15.338526841430568
-- PC_01	4656	48.43657473046122
-- PN_6	4785	86.06388046301458
-- SCIP_CARD_2	4785	32.06579689080607
-- SCIP_INF_1	4785	32.891357385898004
-- SCIP_INF_10	4656	5.292736683662613
-- SCIP_INF_2	4785	17.357257971499802
-- SCIP_INF_3	4785	21.82513053894949
-- SCIP_INF_4	4785	NULL
-- SCIP_INF_9	4785	23.6183141449269
-- SCIP_VTE_2	4785	22.024393364632605
-- STK_1	4656	80.32594045541782
-- STK_10	4656	32.148330072668244
-- STK_2	4656	15.077423715979872
-- STK_3	4656	38.79169112296485
-- STK_4	4656	482.5387626769004
-- STK_5	4656	28.855811098917172
-- STK_6	4656	100.78665730712234
-- STK_8	4656	196.454354649314
-- VTE_1	4656	232.85417931121054
-- VTE_2	4656	55.943085574980984
-- VTE_3	4656	63.53815991521312
-- VTE_4	4656	31.270780242967692
-- VTE_5	4656	265.8956985860033
-- VTE_6	4656	65.0501943738584
-- Time taken: 48.58 seconds, Fetched: 51 row(s)

-- Looks like there is a bug in variance in this version of Hive

	-- https://issues.apache.org/jira/browse/HIVE-6664


-- we're mathematicians, we know the variance is the sqaure of the standard deviation

select power(stddev_pop(score), 2) from effective_care_t where measure_id = "AMI_7A";

--_c0
--352.66666666666674
--Time taken: 50.78 seconds, Fetched: 1 row(s)
--nope *eyetwitch*

select var_pop(score), variance(score), var_samp(score) from effective_care_t where measure_id = "AMI_7A" group by measure_id;

--OK
-- OK
-- 352.6666666666667	352.6666666666667	529.0
-- Time taken: 52.882 seconds, Fetched: 1 row(s)



select var_pop(score), variance(score), var_samp(score) from effective_care_t where measure_id = "AMI_7A" and score is not null group by measure_id;

-- OK
-- _c0	_c1	_c2
-- 352.6666666666667	352.6666666666667	529.0


select sum(power(score - avg(score)), 2)/(count(score) - 1) as var from effective_care_t where measure_id = "AMI_7A" and score is not null group by measure_id;
--FAILED: SemanticException [Error 10128]: Line 1:25 Not yet supported place for UDAF 'avg'

SELECT
measure_id measure_id,
sum(power((t.score - x.avg_score), 2))/(x.cnt_score -1) var 
from 
(select measure_id, avg(score) avg_score, count(score) cnt_score from effective_care_t where measure_id = "AMI_7A" and score is not null group by measure_id) x
join 
effective_care_t  t on 
x.measure_id = t.measure_id
where t.measure_id = "AMI_7A"
and t.score is not null
group by t.measure_id, x.avg_score, x.cnt_score;

-- OK
-- measure_id	var
-- AMI_7A	529.0
-- GAAAAAHHHHH!


-- spread is a measure of variability
-- let's go with spread

select distinct score from effective_care_t where measure_id = "AMI_7A";

-- looks like there are over 4000 null values

select x.measure_id, variance(x.score) var from
(select measure_id, score, sample from effective_care_t where score is not null and measure_id = "AMI_7A") x
group by x.measure_id;



SELECT
measure_id measure_id,
count(measure_id) measure_popularity,
variance(score) score_var,
rank() over(order by variance(score) DESC)
from effective_care_t
where score is not null
group by measure_id, measure_name
limit 50;

-- --results
-- measure_id	measure_popularity	score_var	_wcol0
-- ED_1B	3516	8617.740839212507	1
-- ED_2B	3496	3864.6924460743544	2
-- OP_18B	3349	1656.5529409803205	3
-- OP_3B	409	869.0306968514053	4
-- STK_4	874	481.98665882944397	5
-- OP_23	959	477.18888614639235	6
-- AMI_7A	3	352.6666666666667	7
-- OP_2	68	325.74632352941165	8
-- OP_21	3172	314.0819735739413	9
-- OP_20	3354	285.00371267017476	10
-- IMM_3_FAC_ADHPCT	3657	267.25866979161765	11
-- VTE_5	2468	265.78796126891007	12
-- VTE_1	3534	232.78828961700816	13
-- STK_8	2372	196.37153240873673	14
-- CAC_3	96	161.7760416666667	15
-- IMM_2	3739	142.68029969125467	16
-- HF_1	2934	139.9011388469527	17
-- HF_2	3781	108.40606462202838	18
-- STK_6	2582	100.74762297044258	19
-- PN_6	3973	86.04221827311703	20
-- STK_1	2710	80.29629988698409	21
-- VTE_6	1388	65.0033282395833	22
-- VTE_3	2666	63.514327147052875	23
-- OP_1	68	57.20588235294118	24
-- VTE_2	2955	55.92415390473564	25
-- PC_01	2520	48.41735386747294	26
-- AMI_8A	1528	44.81676591924561	27
-- HF_3	2692	41.74263736700456	28
-- STK_3	1499	38.76581274329642	29
-- OP_5	2099	37.32454597926683	30
-- SCIP_INF_1	3476	32.88189497007928	31
-- STK_10	2702	32.136432097067704	32
-- SCIP_CARD_2	3149	32.055614040094476	33
-- AMI_10	2188	31.595224408356682	34
-- VTE_4	2045	31.255488907885557	35
-- STK_5	2675	28.84502387981477	36
-- OP_4	2087	27.10450276416237	37
-- OP_6	2909	25.695019345256917	38
-- SCIP_INF_9	3329	23.611219427550832	39
-- SCIP_VTE_2	3519	22.018134656657434	40
-- SCIP_INF_3	3457	21.81881722378057	41
-- SCIP_INF_2	3467	17.352251551548402	42
-- OP_7	2914	15.333263105383406	43
-- STK_2	2673	15.071783078600157	44
-- AMI_2	2207	14.485360560345837	45
-- SCIP_INF_10	3259	5.291112646631726	46
-- OP_22	3206	2.9468931849164655	47
-- CAC_2	97	1.6471463492400888	48
-- CAC_1	97	0.020193431820597303	49

SELECT
z.measure_id measure_id,
z.measure_popularity measure_popularity,
z.score_var score_var,
z.ranking ranking
FROM 
(SELECT
measure_id measure_id,
COUNT(measure_id) measure_popularity,
VARIANCE(score) score_var,
RANK() OVER(ORDER BY VARIANCE(score) DESC) ranking
FROM effective_care_t
WHERE score IS NOT NULL
GROUP BY measure_id, measure_name
limit 50) z
WHERE z.measure_popularity > 3000
ORDER BY ranking 
LIMIT 10;

-- returns

-- measure_id	measure_popularity	score_var	ranking
-- ED_1B	3516	8617.740839212507	1
-- ED_2B	3496	3864.6924460743544	2
-- OP_18B	3349	1656.5529409803205	3
-- OP_21	3172	314.0819735739413	9
-- OP_20	3354	285.00371267017476	10
-- IMM_3_FAC_ADHPCT	3657	267.25866979161765	11
-- VTE_1	3534	232.78828961700816	13
-- IMM_2	3739	142.68029969125467	16
-- HF_2	3781	108.40606462202838	18
-- PN_6	3973	86.04221827311703	20
-- Time taken: 196.663 seconds, Fetched: 10 row(s)

-- finalize
create table  question_3_ans as SELECT
z.measure_id measure_id,
z.measure_popularity measure_popularity,
z.score_var score_var,
z.ranking ranking
FROM 
(SELECT
measure_id measure_id,
COUNT(measure_id) measure_popularity,
VARIANCE(score) score_var,
RANK() OVER(ORDER BY VARIANCE(score) DESC) ranking
FROM effective_care_t
WHERE score IS NOT NULL
GROUP BY measure_id, measure_name
) z
WHERE z.measure_popularity > 3000
ORDER BY ranking 
LIMIT 10;