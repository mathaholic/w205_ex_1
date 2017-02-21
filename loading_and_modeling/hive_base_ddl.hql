-- exercise 1 build hive tables
--“hive_base_ddl.hql”
--by Nikki Haas
-- run this as hive -f hive_base_ddl.hql

-- step 0: run load_data_lake.sh first

--step 1: create a database for exercise 1
CREATE DATABASE IF NOT EXISTS exercise1;

-- step 2: use exercise1, to cut down on typing later
use exercise1;


-- step 3: create tables from important csv's

-- create hospitals, looks like a dim table
DROP TABLE IF EXISTS exercise1.hospitals;
CREATE TABLE IF NOT EXISTS exercise1.hospitals(provider_id STRING, hospital_name STRING, address STRING, city STRING, state STRING, zip_code STRING, county STRING, phone STRING, hospital_type STRING, ownership STRING, emergecy_svs STRING) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' WITH SERDEPROPERTIES("separatorChar" = ",", "quoteChar" = '"', "escapeChar" = '\\') STORED AS TEXTFILE LOCATION '/user/w205/hospitals';

-- create effective_care, looks like a fact table
DROP TABLE IF EXISTS exercise1.effective_care;
CREATE TABLE IF NOT EXISTS exercise1.effective_care(provider_id STRING,hospital_name STRING,address STRING,city STRING,state STRING,zip_code STRING,county STRING,phone STRING,condition STRING,measure_id STRING,measure_name STRING,score STRING,sample STRING,footnote STRING,measure_start_date STRING,measure_end_date STRING) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' WITH SERDEPROPERTIES("separatorChar" = ",", "quoteChar" = '"', "escapeChar" = '\\') STORED AS TEXTFILE LOCATION '/user/w205/effective_care';

-- crate readmissions, looks like a fact table
DROP TABLE IF EXISTS exercise1.readmissions;
CREATE TABLE IF NOT EXISTS exercise1.readmissions(provider_id STRING,hospital_name STRING,address STRING,city STRING,state STRING,zip_code STRING,county STRING,phone STRING,measure_name string,measure_id string,compared_to_national string,denominator string,score string,lower_estimate string,higher_estimate string,footnote string,measure_start_date string,measure_end_date string) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' WITH SERDEPROPERTIES("separatorChar" = ",", "quoteChar" = '"', "escapeChar" = '\\') STORED AS TEXTFILE LOCATION '/user/w205/readmissions';

-- create measures, looks like a dim table
DROP TABLE IF EXISTS exercise1.measures;
CREATE TABLE IF NOT EXISTS exercise1.measures(measure_name string,measure_id string,measure_start_quarter string,measure_start_date string,measure_end_quarter string,measure_end_date string) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' WITH SERDEPROPERTIES("separatorChar" = ",", "quoteChar" = '"', "escapeChar" = '\\') STORED AS TEXTFILE LOCATION '/user/w205/measures';

-- create survey responses, looks like a dim table
DROP TABLE IF EXISTS exercise1.survey_responses;
CREATE TABLE IF NOT EXISTS exercise1.survey_responses(provider_number string, hospital_name string, address string, city string, state string, zip_code string, county_name string, communication_with_nurses_achievement_points string, communication_with_nurses_improvement_points string, communication_with_nurses_dimension_score string, communication_with_doctors_achievement_points string, communication_with_doctors_improvement_points string, communication_with_doctors_dimension_score string, responsiveness_of_hospital_staff_achievement_points string, responsiveness_of_hospital_staff_improvement_points string, responsiveness_of_hospital_staff_dimension_score string, pain_management_achievement_points string, pain_management_improvement_points string, pain_management_dimension_score string, communication_about_medicines_achievement_points string, communication_about_medicines_improvement_points string, communication_about_medicines_dimension_score string, cleanliness_and_quietness_of_hospital_environment_achievement_points string, cleanliness_and_quietness_of_hospital_environment_improvement_points string, cleanliness_and_quietness_of_hospital_environment_dimension_score string, discharge_information_achievement_points string, discharge_information_improvement_points string, discharge_information_dimension_score string, overall_rating_of_hospital_achievement_points string, overall_rating_of_hospital_improvement_points string, overall_rating_of_hospital_dimension_score string, hcahps_base_score string, hcahps_consistency_score string) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' WITH SERDEPROPERTIES("separatorChar" = ",", "quoteChar" = '"', "escapeChar" = '\\') STORED AS TEXTFILE LOCATION '/user/w205/surveys_responses';

-- add supplementary measure file, is a dim table
DROP TABLE IF EXISTS exercise1.measure_supp;
CREATE TABLE IF NOT EXISTS exercise1.measure_supp(measure_id string, qualifier string) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' WITH SERDEPROPERTIES("separatorChar" = ",", "quoteChar" = '"', "escapeChar" = '\\') STORED AS TEXTFILE LOCATION '/user/w205/measure_supplement';
