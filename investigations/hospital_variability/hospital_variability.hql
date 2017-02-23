-- Hospital Variability - Investigations
-- By Nikki Haas
-- w205 Exercise 1

-- run as hive -f hospital_variability.hql

-- Investigate the question:
-- Which procedures have the greatest variability between hospitals?

-- go to effective_care_t, pivot on the measure_ids, the get the  variability of each.  
-- omit the infrequently used scores, as variability on sparse data can give wonky results.


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

--expected results
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
