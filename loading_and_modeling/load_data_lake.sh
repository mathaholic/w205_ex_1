#exercise_1
#“load_data_lake.sh”
#by Nikki Haas

#step 1 (from local): run this script to remove all spaces in files in the directory

for file in *; do mv "$file" `echo $file | tr ' ' '_'` ; done

#step 2 (from local): move all pertinent files into their own directory to appease the Hive gods

find . -name "*.csv" -exec sh -c 'NEWDIR=`basename "$1" .csv` ; mkdir "$NEWDIR" ; mv "$1" "$NEWDIR" ' _ {} \;

#step 3 (from local): put this onto github so it can be reached by my AWS: https://github.com/mathaholic/w205_exercise_1

#step 4: go to my AWS, and clone the repo
git clone https://github.com/mathaholic/w205_exercise_1

#step 5: remove the header for all .csv files in the directory


for d in *; do
  if [ -d "$d" ]; then         
    ( cd "$d" && for x in *.csv; do sed '1d' "$x" > tmpfile; mv tmpfile "$x"; done )
  fi
done

#step 6: write the data into HDFS

#from the w205 user:
hdfs dfs -mkdir hospitals
hdfs dfs -put /data/w205_exercise_1/Hospital_General_Information/Hospital_General_Information.csv hospitals

hdfs dfs -mkdir effective_care
hdfs dfs -put /data/w205_exercise_1/Timely_and_Effective_Care_-_Hospital/Timely_and_Effective_Care_-_Hospital.csv effective_care


hdfs dfs -mkdir readmissions
hdfs dfs -put /data/w205_exercise_1/Readmissions_and_Deaths_-_Hospital/Readmissions_and_Deaths_-_Hospital.csv readmissions

hdfs dfs -mkdir measures
hdfs dfs -put /data/w205_exercise_1/Measure_Dates/Measure_Dates.csv measures

hdfs dfs -mkdir surveys_responses
hdfs dfs -put /data/w205_exercise_1/hvbp_hcahps_05_28_2015/hvbp_hcahps_05_28_2015.csv surveys_responses

hdfs dfs -mkdir measure_supplement
hdfs dfs -put /data/w205_exercise_1/measure_score_supplement/measure_score_supplement.csv measure_supplement
#step 7: get into Hive

# as the root user
./start-hadoop.sh
# as root user
sudo -u hdfs hdfs dfs -chmod 777 /
cd /data
./start_postgres.sh 
./start_metastore.sh 

#jump back to w205 user
cd ..
su - w205
hive


