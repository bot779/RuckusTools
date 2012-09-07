#!/bin/sh

#http://www.bashguru.com/2010/05/how-to-read-file-line-by-line-in-shell.html
HEADER_PATH=./regdmn_chan.h
CSV_PATH=./country_matrix.csv

if [ ! -e ${HEADER_PATH} ]; then
  echo "The header file does NOT exist !!!"
  exit 1
fi

if [ ! -e ${CSV_PATH} ]; then
  echo "The CSV file does NOT exist !!!"
  exit 1
fi

data_header=""
data_csv=""

#read data_header < ${HEADER_PATH}

read data_header < ./test.h
echo ${data_header}

FILENAME=${HEADER_PATH}
count=0
cat $FILENAME | while read LINE
do
       count=$(($count+1))
       echo "$count $LINE"
done

echo -e "\nTotal $count Lines read

exit 0
