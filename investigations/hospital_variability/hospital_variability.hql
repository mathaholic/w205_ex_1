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