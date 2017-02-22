-- Best States - Investigations
-- By Nikki Haas
-- w205 Exercise 1

-- run as hive -f best_states.hql

-- Ivestigate the question:
-- What states are models of high-quality care?

-- I cannot use the same method that I used for question 1, as the largest population states will win
-- over the smallest population states due to sheer number.

-- Idea: for each state, find the total number of hospitals
-- for each hospital, get the total B score and the total G score
-- Then, sum up the total B and total G score and divide by numer of hospitals

--  Then for the adjusted score ...

-- or just use the timely and effective care - state file. 


-- get headers
set hive.cli.print.header=true;

-- use the database the tables reside in to cut down on typing
use exercise1;



CREATE TABLE exercise1.question_2_ans AS SELECT
s.state state,
SUM(es.score) agg_score,
AVG(es.score) avg_score,
VARIANCE(es.score) score_variance,
RANK() OVER(ORDER BY sum(es.score) DESC) state_rank
FROM (SELECT  
z.state state,
z.qualifier qualifier,
z.total_score total_score,
z.score_rank score_rank
from 
(select 
u.state from 
(select 
z.state state,
z.qualifier qualifier,
z.total_score total_score,
z.score_rank score_rank
from 
(SELECT 
x.state state,
x.qualifier qualifier,
x.total_score total_score,
RANK() OVER(PARTITION BY x.qualifier ORDER BY x.total_score DESC) score_rank
FROM
(SELECT
ecs.state state,
sup.qualifier qualifier,
SUM(ecs.score) total_score
FROM effective_care_state_t ecs 
JOIN measure_supp sup 
ON ecs.measure_id = sup.measure_id
GROUP BY  ecs.state, sup.qualifier) x
where total_score is not NULL) z
where (z.qualifier = 'B' AND score_rank < 25) OR (z.qualifier = 'G' AND score_rank > 25)) u 
group by u.state 
having count(u.state)>1) v 
JOIN
(SELECT 
x.state state,
x.qualifier qualifier,
x.total_score total_score,
RANK() OVER(PARTITION BY x.qualifier ORDER BY x.total_score DESC) score_rank
FROM
(SELECT
ecs.state state,
sup.qualifier qualifier,
SUM(ecs.score) total_score
FROM effective_care_state_t ecs 
JOIN measure_supp sup 
ON ecs.measure_id = sup.measure_id
GROUP BY  ecs.state, sup.qualifier) x
where total_score is not NULL) z
on v.state = z.state
where (z.qualifier = 'B' AND score_rank < 25) OR (z.qualifier = 'G' AND score_rank > 25)) s
join effective_care_state_t es
on 
s.state = es.state
group by s.state
limit 10;


-- results OK
-- question_2_ans.state	question_2_ans.agg_score	question_2_ans.avg_score	question_2_ans.score_variance	question_2_ans.state_rank
-- ID	12596.0	95.42424242424242	3220.7669880624426	10
-- TN	12764.0	96.6969696969697	3463.1505968778706	9
-- MO	12778.0	96.8030303030303	3262.7642332415053	8
-- IL	13092.0	99.18181818181819	3991.7017906336087	7
-- SC	13176.0	99.81818181818181	3903.9593663911855	6
-- WA	13204.0	100.03030303030303	4026.2718089990817	5
-- MI	13235.0	100.26515151515152	4609.100149219466	4
-- VA	13309.0	100.82575757575758	4392.208275941228	3
-- OH	13424.0	97.27536231884058	3778.518378491915	2
-- ME	14024.0	107.87692307692308	5626.146390532546	1
-- Time taken: 0.07 seconds, Fetched: 10 row(s)
