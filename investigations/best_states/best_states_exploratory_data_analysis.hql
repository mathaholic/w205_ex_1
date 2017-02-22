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

-- or just use the timely and effective care - state file.  First, see if that will work.  Is there
-- parity between an aggregate of the hospital data pivoted on state and the state data?


-- get headers
set hive.cli.print.header=true;

-- use the database the tables reside in to cut down on typing
use exercise1;

-- first, test to see if the average or median score for a few states using the hospital data are identical 
-- to the average or median score for the states in the state level data

SELECT state, avg(cast(score as float)), percentile_approx(cast(score as float), 0.5) FROM effective_care_t 
WHERE measure_id = "OP_3B"
GROUP BY state ORDER BY state;


-- for most of this set, there is parity.  But for Alaska, we literally have no information for OP_3B in 
-- effective_care hospital but we have a score for OP_3B in effective care state o_0

-- The data in effective care state appears to be more complete than the data in hospitals.  I will
-- use the state aggregated data over the hospital aggregated data for this question.


SELECT
ecs.state state,
sup.qualifier qualifier,
SUM(ecs.score) total_score
FROM effective_care_state_t ecs 
JOIN measure_supp sup 
ON ecs.measure_id = sup.measure_id
GROUP BY  ecs.state, sup.qualifier;


-- returns
	-- OK
	-- state	qualifier	total_score
	-- AK	B	3184.0
	-- AK	G	843.0
	-- AL	B	3226.0
	-- AL	G	646.0
	-- AR	B	3205.0
	-- AR	G	606.0
	-- AS	B	NULL
	-- AS	G	NULL
	-- AZ	B	3239.0
	-- AZ	G	739.0
	-- CA	B	3536.0
	-- CA	G	813.0
	-- CO	B	3241.0
	-- CO	G	634.0
	-- CT	B	3299.0
	-- CT	G	829.0
	-- DC	B	3039.0
	-- DC	G	1186.0
	-- DE	B	3131.0
	-- DE	G	975.0
	-- FL	B	3608.0
	-- FL	G	713.0
	-- GA	B	3204.0
	-- GA	G	722.0
	-- GU	B	1797.0
	-- GU	G	864.0
	-- HI	B	3167.0
	-- HI	G	761.0
	-- IA	B	3189.0
	-- IA	G	555.0
	-- ID	B	3276.0
	-- ID	G	632.0
	-- IL	B	3246.0
	-- IL	G	668.0
	-- IN	B	3177.0
	-- IN	G	599.0
	-- KS	B	3165.0
	-- KS	G	534.0
	-- KY	B	3214.0
	-- KY	G	635.0
	-- LA	B	3144.0
	-- LA	G	688.0
	-- MA	B	3269.0
	-- MA	G	793.0
	-- MD	B	3446.0
	-- MD	G	919.0
	-- ME	B	3249.0
	-- ME	G	674.0
	-- MI	B	3252.0
	-- MI	G	685.0
	-- MN	B	3155.0
	-- MN	G	561.0
	-- MO	B	3303.0
	-- MO	G	631.0
	-- MP	B	NULL
	-- MP	G	NULL
	-- MS	B	3119.0
	-- MS	G	613.0
	-- MT	B	3243.0
	-- MT	G	638.0
	-- NC	B	3581.0
	-- NC	G	712.0
	-- ND	B	3138.0
	-- ND	G	644.0
	-- NE	B	3290.0
	-- NE	G	604.0
	-- NH	B	3227.0
	-- NH	G	705.0
	-- NJ	B	3270.0
	-- NJ	G	862.0
	-- NM	B	3089.0
	-- NM	G	806.0
	-- NV	B	3231.0
	-- NV	G	835.0
	-- NY	B	3191.0
	-- NY	G	901.0
	-- OH	B	3546.0
	-- OH	G	660.0
	-- OK	B	3196.0
	-- OK	G	582.0
	-- OR	B	3140.0
	-- OR	G	663.0
	-- PA	B	3285.0
	-- PA	G	690.0
	-- PR	B	2362.0
	-- PR	G	1221.0
	-- RI	B	3213.0
	-- RI	G	740.0
	-- SC	B	3294.0
	-- SC	G	683.0
	-- SD	B	3171.0
	-- SD	G	517.0
	-- TN	B	3270.0
	-- TN	G	625.0
	-- TX	B	3551.0
	-- TX	G	698.0
	-- UT	B	3278.0
	-- UT	G	555.0
	-- VA	B	3312.0
	-- VA	G	674.0
	-- VI	B	2637.0
	-- VI	G	600.0
	-- VT	B	3171.0
	-- VT	G	760.0
	-- WA	B	3241.0
	-- WA	G	679.0
	-- WI	B	3255.0
	-- WI	G	548.0
	-- WV	B	3227.0
	-- WV	G	717.0
	-- WY	B	3128.0
	-- WY	G	662.0
	-- Time taken: 68.231 seconds, Fetched: 112 row(s)

SELECT 
x.qualifier qualifier,
CASE WHEN x.qualifier = "G" then percentile_approx(x.total_score, 0.25) WHEN x.qualifier = "B" then percentile_approx(x.total_score, 0.75) ELSE NULL END pct
FROM
(SELECT
ecs.state state,
sup.qualifier qualifier,
SUM(ecs.score) total_score
FROM effective_care_state_t ecs 
JOIN measure_supp sup 
ON ecs.measure_id = sup.measure_id
GROUP BY  ecs.state, sup.qualifier) x
group by x.qualifier;


-- returns 
-- OK
-- qualifier	pct
-- B	3273.0
-- G	628.0
-- Time taken: 118.85 seconds, Fetched: 2 row(s)


-- find the states that are above pct


-- try with rank()
SELECT 
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
where total_score is not NULL;

-- returns
	-- OK
	-- state	qualifier	total_score	score_rank
	-- FL	B	3608.0	1
	-- NC	B	3581.0	2
	-- TX	B	3551.0	3
	-- OH	B	3546.0	4
	-- CA	B	3536.0	5
	-- MD	B	3446.0	6
	-- VA	B	3312.0	7
	-- MO	B	3303.0	8
	-- CT	B	3299.0	9
	-- SC	B	3294.0	10
	-- NE	B	3290.0	11
	-- PA	B	3285.0	12
	-- UT	B	3278.0	13
	-- ID	B	3276.0	14
	-- NJ	B	3270.0	15
	-- TN	B	3270.0	15
	-- MA	B	3269.0	17
	-- WI	B	3255.0	18
	-- MI	B	3252.0	19
	-- ME	B	3249.0	20
	-- IL	B	3246.0	21
	-- MT	B	3243.0	22
	-- CO	B	3241.0	23
	-- WA	B	3241.0	23
	-- AZ	B	3239.0	25
	-- NV	B	3231.0	26
	-- NH	B	3227.0	27
	-- WV	B	3227.0	27
	-- AL	B	3226.0	29
	-- KY	B	3214.0	30
	-- RI	B	3213.0	31
	-- AR	B	3205.0	32
	-- GA	B	3204.0	33
	-- OK	B	3196.0	34
	-- NY	B	3191.0	35
	-- IA	B	3189.0	36
	-- AK	B	3184.0	37
	-- IN	B	3177.0	38
	-- VT	B	3171.0	39
	-- SD	B	3171.0	39
	-- HI	B	3167.0	41
	-- KS	B	3165.0	42
	-- MN	B	3155.0	43
	-- LA	B	3144.0	44
	-- OR	B	3140.0	45
	-- ND	B	3138.0	46
	-- DE	B	3131.0	47
	-- WY	B	3128.0	48
	-- MS	B	3119.0	49
	-- NM	B	3089.0	50
	-- DC	B	3039.0	51
	-- VI	B	2637.0	52
	-- PR	B	2362.0	53
	-- GU	B	1797.0	54
	-- MP	B	NULL	55
	-- AS	B	NULL	55
	-- PR	G	1221.0	1
	-- DC	G	1186.0	2
	-- DE	G	975.0	3
	-- MD	G	919.0	4
	-- NY	G	901.0	5
	-- GU	G	864.0	6
	-- NJ	G	862.0	7
	-- AK	G	843.0	8
	-- NV	G	835.0	9
	-- CT	G	829.0	10
	-- CA	G	813.0	11
	-- NM	G	806.0	12
	-- MA	G	793.0	13
	-- HI	G	761.0	14
	-- VT	G	760.0	15
	-- RI	G	740.0	16
	-- AZ	G	739.0	17
	-- GA	G	722.0	18
	-- WV	G	717.0	19
	-- FL	G	713.0	20
	-- NC	G	712.0	21
	-- NH	G	705.0	22
	-- TX	G	698.0	23
	-- PA	G	690.0	24
	-- LA	G	688.0	25
	-- MI	G	685.0	26
	-- SC	G	683.0	27
	-- WA	G	679.0	28
	-- VA	G	674.0	29
	-- ME	G	674.0	29
	-- IL	G	668.0	31
	-- OR	G	663.0	32
	-- WY	G	662.0	33
	-- OH	G	660.0	34
	-- AL	G	646.0	35
	-- ND	G	644.0	36
	-- MT	G	638.0	37
	-- KY	G	635.0	38
	-- CO	G	634.0	39
	-- ID	G	632.0	40
	-- MO	G	631.0	41
	-- TN	G	625.0	42
	-- MS	G	613.0	43
	-- AR	G	606.0	44
	-- NE	G	604.0	45
	-- VI	G	600.0	46
	-- IN	G	599.0	47
	-- OK	G	582.0	48
	-- MN	G	561.0	49
	-- IA	G	555.0	50
	-- UT	G	555.0	50
	-- WI	G	548.0	52
	-- KS	G	534.0	53
	-- SD	G	517.0	54
	-- MP	G	NULL	55
	-- AS	G	NULL	55
	-- Time taken: 115.793 seconds, Fetched: 112 row(s)



-- promising.... try to expand now to include the highest highs and lowest lows

SELECT 
x.state state,
x.qualifier qualifier,
x.total_score total_score,
RANK() OVER(PARTITION BY x.qualifier ORDER BY (case when x.qualifier = "B" then x.total_score DESC else x.total_score ASC END)) score_rank
FROM
(SELECT
ecs.state state,
sup.qualifier qualifier,
SUM(ecs.score) total_score
FROM effective_care_state_t ecs 
JOIN measure_supp sup 
ON ecs.measure_id = sup.measure_id
GROUP BY  ecs.state, sup.qualifier) x
where total_score is not NULL;


-- FAILED: ParseException line 5:94 mismatched input 'DESC' expecting KW_END near 'total_score' in case expression
 

-- damnit
SELECT 
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
where total_score is not NULL;


select 
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
where (z.qualifier = 'B' AND score_rank < 25) OR (z.qualifier = 'G' AND score_rank > 25);


-- returns 
--OK
	-- state	qualifier	total_score	score_rank
	-- FL	B	3608.0	1
	-- NC	B	3581.0	2
	-- TX	B	3551.0	3
	-- OH	B	3546.0	4
	-- CA	B	3536.0	5
	-- MD	B	3446.0	6
	-- VA	B	3312.0	7
	-- MO	B	3303.0	8
	-- CT	B	3299.0	9
	-- SC	B	3294.0	10
	-- NE	B	3290.0	11
	-- PA	B	3285.0	12
	-- UT	B	3278.0	13
	-- ID	B	3276.0	14
	-- NJ	B	3270.0	15
	-- TN	B	3270.0	15
	-- MA	B	3269.0	17
	-- WI	B	3255.0	18
	-- MI	B	3252.0	19
	-- ME	B	3249.0	20
	-- IL	B	3246.0	21
	-- MT	B	3243.0	22
	-- WA	B	3241.0	23
	-- CO	B	3241.0	23
	-- MI	G	685.0	26
	-- SC	G	683.0	27
	-- WA	G	679.0	28
	-- VA	G	674.0	29
	-- ME	G	674.0	29
	-- IL	G	668.0	31
	-- OR	G	663.0	32
	-- WY	G	662.0	33
	-- OH	G	660.0	34
	-- AL	G	646.0	35
	-- ND	G	644.0	36
	-- MT	G	638.0	37
	-- KY	G	635.0	38
	-- CO	G	634.0	39
	-- ID	G	632.0	40
	-- MO	G	631.0	41
	-- TN	G	625.0	42
	-- MS	G	613.0	43
	-- AR	G	606.0	44
	-- NE	G	604.0	45
	-- VI	G	600.0	46
	-- IN	G	599.0	47
	-- OK	G	582.0	48
	-- MN	G	561.0	49
	-- UT	G	555.0	50
	-- IA	G	555.0	50
	-- WI	G	548.0	52
	-- KS	G	534.0	53
	-- SD	G	517.0	54
	-- Time taken: 119.328 seconds, Fetched: 53 row(s)


-- find a way to return back only the states with two lines 
 


select 
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
having count(u.state)>1;



-- returns


-- ok now plug it into this as the second join:

SELECT  
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
where (z.qualifier = 'B' AND score_rank < 25) OR (z.qualifier = 'G' AND score_rank > 25)
;


-- returns
	-- state	qualifier	total_score	score_rank
	-- OH	B	3546.0	4
	-- VA	B	3312.0	7
	-- MO	B	3303.0	8
	-- SC	B	3294.0	10
	-- NE	B	3290.0	11
	-- UT	B	3278.0	13
	-- ID	B	3276.0	14
	-- TN	B	3270.0	15
	-- WI	B	3255.0	18
	-- MI	B	3252.0	19
	-- ME	B	3249.0	20
	-- IL	B	3246.0	21
	-- MT	B	3243.0	22
	-- WA	B	3241.0	23
	-- CO	B	3241.0	23
	-- MI	G	685.0	26
	-- SC	G	683.0	27
	-- WA	G	679.0	28
	-- VA	G	674.0	29
	-- ME	G	674.0	29
	-- IL	G	668.0	31
	-- OH	G	660.0	34
	-- MT	G	638.0	37
	-- CO	G	634.0	39
	-- ID	G	632.0	40
	-- MO	G	631.0	41
	-- TN	G	625.0	42
	-- NE	G	604.0	45
	-- UT	G	555.0	50
	-- WI	G	548.0	52
	-- Time taken: 337.503 seconds, Fetched: 30 row(s)

--alright, now to rank them and give back the top 10

SELECT
s.state state,
SUM(s.total_score) total_score,
RANK() OVER(PARTITION BY s.state ORDER BY sum(s.total_score) DESC) state_rank
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
group by s.state
limit 10;


-- not exactly what was intended:

-- state	total_score	state_rank
-- CO	3875.0	1
-- ID	3908.0	1
-- IL	3914.0	1
-- ME	3923.0	1
-- MI	3937.0	1
-- MO	3934.0	1
-- MT	3881.0	1
-- NE	3894.0	1
-- OH	4206.0	1
-- SC	3977.0	1
-- Time taken: 424.298 seconds, Fetched: 10 row(s)

--take out partition

SELECT
s.state state,
SUM(s.total_score) total_score,
RANK() OVER(ORDER BY sum(s.total_score) DESC) state_rank
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
group by s.state
limit 10;

-- results

-- OK
-- state	total_score	state_rank
-- OH	4206.0	1
-- VA	3986.0	2
-- SC	3977.0	3
-- MI	3937.0	4
-- MO	3934.0	5
-- ME	3923.0	6
-- WA	3920.0	7
-- IL	3914.0	8
-- ID	3908.0	9
-- TN	3895.0	10
-- Time taken: 424.701 seconds, Fetched: 10 row(s)

--and there we go


-- let's join it back to the original table to get the variance, average, and whatnot

SELECT
    > s.state state,
    > SUM(s.total_score) total_score,
    > AVG(es.score) avg_score,
    > VARIANCE(es.score) score_variance,
    > RANK() OVER(ORDER BY sum(s.total_score) DESC) state_rank
    > FROM (SELECT  
    > z.state state,
    > z.qualifier qualifier,
    > z.total_score total_score,
    > z.score_rank score_rank
    > from 
    > (select 
    > u.state from 
    > (select 
    > z.state state,
    > z.qualifier qualifier,
    > z.total_score total_score,
    > z.score_rank score_rank
    > from 
    > (SELECT 
    > x.state state,
    > x.qualifier qualifier,
    > x.total_score total_score,
    > RANK() OVER(PARTITION BY x.qualifier ORDER BY x.total_score DESC) score_rank
    > FROM
    > (SELECT
    > ecs.state state,
    > sup.qualifier qualifier,
    > SUM(ecs.score) total_score
    > FROM effective_care_state_t ecs 
    > JOIN measure_supp sup 
    > ON ecs.measure_id = sup.measure_id
    > GROUP BY  ecs.state, sup.qualifier) x
    > where total_score is not NULL) z
    > where (z.qualifier = 'B' AND score_rank < 25) OR (z.qualifier = 'G' AND score_rank > 25)) u 
    > group by u.state 
    > having count(u.state)>1) v 
    > JOIN
    > (SELECT 
    > x.state state,
    > x.qualifier qualifier,
    > x.total_score total_score,
    > RANK() OVER(PARTITION BY x.qualifier ORDER BY x.total_score DESC) score_rank
    > FROM
    > (SELECT
    > ecs.state state,
    > sup.qualifier qualifier,
    > SUM(ecs.score) total_score
    > FROM effective_care_state_t ecs 
    > JOIN measure_supp sup 
    > ON ecs.measure_id = sup.measure_id
    > GROUP BY  ecs.state, sup.qualifier) x
    > where total_score is not NULL) z
    > on v.state = z.state
    > where (z.qualifier = 'B' AND score_rank < 25) OR (z.qualifier = 'G' AND score_rank > 25)) s
    > join effective_care_state_t es
    > on 
    > s.state = es.state
    > group by s.state
    > limit 10;

-- OK
-- state	total_score	avg_score	score_variance	state_rank
-- OH	294420.0	97.27536231884058	3778.518378491915	1
-- VA	279020.0	100.82575757575758	4392.208275941228	2
-- SC	278390.0	99.81818181818181	3903.9593663911855	3
-- MI	275590.0	100.26515151515152	4609.100149219466	4
-- MO	275380.0	96.8030303030303	3262.7642332415053	5
-- WA	274400.0	100.03030303030303	4026.2718089990817	6
-- IL	273980.0	99.18181818181819	3991.7017906336087	7
-- ID	273560.0	95.42424242424242	3220.7669880624426	8
-- TN	272650.0	96.6969696969697	3463.1505968778706	9
-- NE	272580.0	93.96969696969697	2924.7945362718083	10
-- Time taken: 444.42 seconds, Fetched: 10 row(s)



--- crap, try again
SELECT
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

-- results
-- state	agg_score	avg_score	score_variance	state_rank
-- ME	14024.0	107.87692307692308	5626.146390532546	1
-- OH	13424.0	97.27536231884058	3778.518378491915	2
-- VA	13309.0	100.82575757575758	4392.208275941228	3
-- MI	13235.0	100.26515151515152	4609.100149219466	4
-- WA	13204.0	100.03030303030303	4026.2718089990817	5
-- SC	13176.0	99.81818181818181	3903.9593663911855	6
-- IL	13092.0	99.18181818181819	3991.7017906336087	7
-- MO	12778.0	96.8030303030303	3262.7642332415053	8
-- TN	12764.0	96.6969696969697	3463.1505968778706	9
-- ID	12596.0	95.42424242424242	3220.7669880624426	10
-- Time taken: 446.961 seconds, Fetched: 10 row(s)

-- awesome now CTAS

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
