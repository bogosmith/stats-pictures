#!/bin/bash

usage() { echo "Usage: $0 -o <output_dir> -a <latitude> -g <longitude>" 1>&2; exit 1; }
nodir() { echo "Output directory has to exist." 1>&2; exit 1; }
dirnotempty() { echo "Output directory has to be empty." 1>&2; exit 1; }
datefull() { echo "Today's directory exists. Quitting.." 1>&2; exit 1; }


while getopts ":o:a:g:" o; do
    case "${o}" in
       o) 
          outdir=${OPTARG}
          ;;
       a) 
          lat=${OPTARG}
          ;;
       g) 
          lon=${OPTARG}
          ;;
       *)
          usage
          ;;
    esac
done	
shift $((OPTIND-1))
# $1 now references the first non-option argument supplied to the script

if [ -z "${outdir}" ]; then
  usage
fi

if [ -z "${lat}" ]; then
  usage
fi

if [ -z "${lon}" ]; then
  usage
fi

if [ ! -d "${outdir}" ]; then
  nodir
fi

if [ "$(ls -A $outdir)" ]; then
  dirnotempty
fi

minlat=$(echo $lat-0.0045 | bc)
maxlat=$(echo $lat+0.0045 | bc)
minlon=$(echo $lon-0.007 | bc)
maxlon=$(echo $lon+0.007 | bc)

printf %f"\n"%f"\n"%f"\n"%f"\n" $minlat $maxlat $minlon $maxlon

step=25
count=0
total_pics=0
while true;
do
  low_inclusive=$((count*step))
  high_exclusive=$(((count+1)*step))
  wget -O ${outdir}/file$count.json http://www.panoramio.com/map/get_panoramas.php?set=full\&from=$low_inclusive\&to=$high_exclusive\&minx=$minlon\&miny=$minlat\&maxx=$maxlon\&maxy=$maxlat\&size=original\&mapfilter=false 
  cat ${outdir}/file$count.json | python -m json.tool > ${outdir}/file$count.pretty
  cnt=$(grep '"has_more": true,' ${outdir}/file$count.pretty | wc -l )
  pics=$(grep ^[[:space:]]*\"height\": ${outdir}/file$count.pretty | wc -l)
  total_pics=$((total_pics + pics))
  if [ $cnt == 0 ]; then
    break
  fi
  sleep $((RANDOM % 3))
  count=$((count+1))
done

sum="Centre lat = "$lat"\n"
sum=$sum"centre lon = "$lon"\n"
sum=$sum"minlat = "$minlat"\n"
sum=$sum"maxlat = "$maxlat"\n"
sum=$sum"minlon = "$minlon"\n"
sum=$sum"maxlon = "$maxlon"\n"
sum=$sum"Total pics:"$total_pics
printf "$sum" > ${outdir}/summary.txt
