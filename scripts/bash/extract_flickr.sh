#!/bin/bash

usage() { echo "Usage: $0 -o <output_dir> -a <latitude> -g <longitude> -s <start_date> -e <end_date> (-d <bounding_box_side_in_kilometers>) (-f <hour|day|week|month>)" 1>&2; exit 1; }
nodir() { echo "Output directory has to exist." 1>&2; exit 1; }
dirnotempty() { echo "Output directory has to be empty." 1>&2; exit 1; }
datefull() { echo "Today's directory exists. Quitting.." 1>&2; exit 1; }


while getopts ":o:a:g:s:e:f:d:" o; do
    case "${o}" in
       d) 
          bbox_side="${OPTARG}"
          ;;
       o) 
          outdir="${OPTARG}"
          ;;
       a) 
          lat="${OPTARG}"
          ;;
       g) 
          lon="${OPTARG}"
          ;;
       s) 
          strt="${OPTARG}"
          ;;
       e) 
          end="${OPTARG}"
          ;;
       f) 
          freq="${OPTARG}"
          ;;
       *)
          usage
          ;;
    esac
done	
shift $((OPTIND-1))
# $1 now references the first non-option argument supplied to the script
if [ -z "${bbox_side}" ]; then
  bbox_side="2"
fi

if [ -z "${freq}" ]; then
  freq="month"
fi

if [ -z "${outdir}" ]; then
  usage
fi

if [ -z "${lat}" ]; then
  usage
fi

if [ -z "${lon}" ]; then
  usage
fi

if [ -z "${strt}" ]; then
  usage
fi

if [ -z "${end}" ]; then
  usage
fi

if [ ! -d "${outdir}" ]; then
  nodir
fi

if [ "$(ls -A $outdir)" ]; then
  dirnotempty
fi

box_script=$(dirname $(cd "$( dirname "$0" )" && pwd))/perl/getbox.pl
echo $lat
echo $lon
echo $bbox_side
bounds=($(echo "$lat" "$lon" "$bbox_side" | perl "$box_script"))
minlon=${bounds[0]}
minlat=${bounds[1]}
maxlon=${bounds[2]}
maxlat=${bounds[3]}
echo $minlon $minlat

#minlat=$(echo $lat-0.0045 | bc)
#maxlat=$(echo $lat+0.0045 | bc)
#minlon=$(echo $lon-0.007 | bc)
#maxlon=$(echo $lon+0.007 | bc)
api_key="a40c536d8c174c7a9499b00587975650"

#printf %f"\n"%f"\n"%f"\n"%f"\n" $minlat $maxlat $minlon $maxlon

currentdate=$(date -d "$strt")
enddate=$(date -d "$end")
currentstamp=$(date -d "$currentdate" "+%s")
endstamp=$(date -d "$enddate" "+%s")
tempfile=${outdir}/tempfile
seriesfile=${outdir}/series

echo $freq $minlon $minlat $maxlon $maxlat >> $seriesfile

while true;
do
  nextdate=$(date -d "$(date -d @${currentstamp}) + 1 $freq")
  nextstamp=$(date -d "$nextdate" "+%s")
  last_hour_of_period=$(date -d "$nextdate - 1 hour")
  last_hour_of_period_stamp=$(date -d "$last_hour_of_period" "+%s")
  wget -O $tempfile https://api.flickr.com/services/rest/?method=flickr.photos.search\&api_key=$api_key\&bbox=$minlon,$minlat,$maxlon,$maxlat\&min_taken_date=$currentstamp\&max_taken_date=$last_hour_of_period_stamp
  cnt=$(grep total= $tempfile | head -1 | perl -ne '$_ =~ /total=\"(\d*)\"/; print "$1\n"')
  echo $currentstamp $cnt >> $seriesfile
  sleep $((RANDOM % 3))
  #echo $currentstamp $last_hour_of_period_stamp
  currentstamp=$nextstamp
  if [ $currentstamp -gt $endstamp ]; then
    break
  fi
done
