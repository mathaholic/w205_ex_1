-- table_transformations.hql
-- w205 exercise1 
-- By Nikki Haas

-- run using 'hive -f table_transformations.hql'

-- Given the data is raw, transform it to the desired data types and shape

-- step 0: run all files in loading_and_modeling directory first

-- step 1: set directory

use exercise1;

--Formatting note:  Cases in text fields are just annoying.  To save myself a ton of WHERE UPPER(field) LIKE.... 
--I will use UPPER in all transformations.

-- step 2: Groom hospitals table into correct datatypes using CTAS

DROP TABLE IF EXISTS hospitals_t;
CREATE TABLE IF NOT EXISTS hospitals_t AS 
	SELECT CAST(provider_id as int) provider_id,
	UPPER(hospital_name) hospital_name,
	UPPER(address) address,
	UPPER(city) city,
	UPPER(state) state,
	CAST(zip_code as int) zip_code,
	UPPER(county) as county,
	phone phone,
	UPPER(hospital_type) hospital_type,
	UPPER(ownership) ownership,
	-- so I can get proportions per state
	CASE WHEN emergecy_svs = 'Yes' THEN 1 ELSE 0 END emergency_svs 
	FROM hospitals;

--step 3: Groom effective_care table into correct datatypes using CTAS
-- note:  there is some malformed data in this set that will cause some of the hospitals to not be considered in analysis

DROP TABLE IF EXISTS effective_care_t;
CREATE TABLE IF NOT EXISTS effective_care_t AS
	SELECT CAST(provider_id as int) provider_id,
	UPPER(hospital_name) hospital_name,
	UPPER(address) address,
	UPPER(city) city,
	UPPER(state) state,
	CAST(zip_code as int) zip_code,
	UPPER(county) as county,
	phone phone,
	UPPER(condition) condition,
	UPPER(measure_id) measure_id,
	UPPER(measure_name) measure_name,
	-- There is some malformed data in this column that will return as NULL in this column
	CAST(score as int) score, 
	-- There is some malformed data in this column that will return as NULL in this column
	CAST(sample as int) sample, 
	-- there are numerous entries with multiple footnotes, create an array of each footnote numeral
	split(regexp_replace(footnote, "[^0-9,]+", ""), ',') footnote,
	from_unixtime(unix_timestamp(measure_start_date,'MM/dd/yyyy'), 'yyyy-MM-dd') measure_start_date,
	from_unixtime(unix_timestamp(measure_end_date,'MM/dd/yyyy'), 'yyyy-MM-dd') measure_end_date
	FROM effective_care;

-- step 4: Groom measures table into correct datatypes using CTAS

DROP TABLE IF EXISTS measures_t;
CREATE TABLE IF NOT EXISTS measures_t AS
	SELECT
	UPPER(measure_name) measure_name,
	UPPER(measure_id) measure_id,
	UPPER(measure_start_quarter) measure_start_quarter,
	to_date(measure_start_date) measure_start_date,
	UPPER(measure_end_quarter) measure_end_quarter,
	to_date(measure_end_date) measure_end_date
	FROM measures;

-- step 5: Groom readmissions table into correct datatypes using CTAS

DROP TABLE IF EXISTS readmissions_t;
CREATE TABLE IF NOT EXISTS readmissions_t AS
	SELECT CAST(provider_id as int) provider_id,
	UPPER(hospital_name) hospital_name,
	UPPER(address) address,
	UPPER(city) city,
	UPPER(state) state,
	CAST(zip_code as int) zip_code,
	UPPER(county) as county,
	phone phone,
	UPPER(condition) condition,
	UPPER(measure_id) measure_id,
	UPPER(measure_name) measure_name,
	-- there is a 'Not Available' option for compared_to_national.  Let's change that to NULL for sanity purposes
	-- in addition, let's give a numerical scale
		-- Better than the National Rate
		-- No different than the National Rate
		-- Not Available
		-- Number of Cases Too Small
		-- Worse than the National Rate
	CASE WHEN compared_to_national = 'Not Available' THEN NULL 
	     WHEN compared_to_national = 'Number of Cases Too Small' THEN NULL
	     WHEN compared_to_national = 'No different than the National Rate' THEN 0
	     WHEN compared_to_national = 'Better than the National Rate' THEN 1
	     WHEN compared_to_national = 'Worse than the National Rate' THEN -1 END compared_to_national,
	CAST(denominator AS INT) denominator,
	CAST(score AS FLOAT) score,
	CAST(lower_estimate AS FLOAT) lower_estimate,
	CAST(higher_estimate AS FLOAT) higher_estimate,
	split(regexp_replace(footnote, "[^0-9,]+", ""), ',') footnote,
	from_unixtime(unix_timestamp(measure_start_date,'MM/dd/yyyy'), 'yyyy-MM-dd') measure_start_date,
	from_unixtime(unix_timestamp(measure_end_date,'MM/dd/yyyy'), 'yyyy-MM-dd') measure_end_date
	FROM readmissions;


-- step 6: Groom survey_responses into correct datatypes using CTAS
-- spend extra time making sure the headers are the same as the headers in the other tables

DROP TABLE IF EXISTS survey_responses_t;
CREATE TABLE IF NOT EXISTS survey_responses_t AS
	SELECT CAST(provider_number as int) provider_id,
	UPPER(hospital_name) hospital_name,
	UPPER(address) address,
	UPPER(city) city,
	UPPER(state) state,
	CAST(zip_code as int) zip_code,
	UPPER(county_name) as county,
	-- I will not include the individual survey scores (recorded as '4 out of 10', etc etc)
	-- See http://www.hcahpsonline.org/files/HCAHPS%20Fact%20Sheet%20May%202012.pdf
	CAST(hcahps_base_score as int) hcahps_base_score,
	CAST(hcahps_consistency_score as int) hcahps_consistency_score
	FROM survey_responses;


--Name Linking Quality to Payment: Hospital Value-Based Purchasing (HVBP) Program
-- Description/
-- Background
-- The HVBP program is part of CMS’ long-standing effort to link Medicare’s payment system to quality. The
-- program implements value-based purchasing to the payment system that accounts for the largest share of
-- Medicare spending, affecting payment for inpatient stays in over 3,500 hospitals across the country. Hospitals are
-- paid for inpatient acute care services based on the quality of care, not just quantity of the services they provide.
-- The Fiscal Year 2015 HVBP adjusts hospitals’ payments based on their performance on four domains that reflect
-- hospital quality: the Clinical Process of Care Domain, the Patient Experience of Care domain, the Outcome
-- domain, and the Efficiency domain. The Total Performance Score (TPS) is comprised of the Clinical Process of
-- Care domain score (weighted as 20% of the TPS), the Patient Experience of Care domain score (weighted as 30%
-- of the TPS), the Outcome domain score (weighted as 30% of the TPS), and the Efficiency domain score
-- (weighted as 20% of the TPS).
-- Reporting Cycle Collection period: Approximately 12 months. Refreshed annually.