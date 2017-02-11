#exercise_1
#“load_data_lake.sh”
#by Nikki Haas

#step 1: run this script to remove all spaces in files in the directory

for file in *; do mv "$file" `echo $file | tr ' ' '_'` ; done

#step 2: move all pertinent files into their own directory to appease the Hive gods

find . -name "*.csv" -exec sh -c 'NEWDIR=`basename "$1" .csv` ; mkdir "$NEWDIR" ; mv "$1" "$NEWDIR" ' _ {} \;

#step 3: put this onto github so it can be reached by my AWS: https://github.com/mathaholic/w205_exercise_1

#step 4: go to my AWS, and clone the repo
git clone https://github.com/mathaholic/w205_exercise_1

#step 5: remove the header for all .csv files in the directory


for d in *; do
  if [ -d "$d" ]; then         
    ( cd "$d" && for x in *.csv; do sed '1d' "$x" > tmpfile; mv tmpfile "$x"; done )
  fi
done