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

# mapfilter=true would remove many pictures for the purpose of not showing overlapping ones
#wget -O ${outdir}/file1.json http://www.panoramio.com/map/get_panoramas.php?set=full\&from=0\&to=100\&minx=$minlon\&miny=$minlat\&maxx=$maxlon\&maxy=$maxlat\&size=original\&mapfilter=false 

wget -O ${outdir}/initial.json http://www.panoramio.com/map/get_panoramas.php?set=full\&from=0\&to=0\&minx=$minlon\&miny=$minlat\&maxx=$maxlon\&maxy=$maxlat\&size=original\&mapfilter=false 
# beautify
cat ${outdir}/initial.json | python -m json.tool > ${outdir}/initial.pretty
cnt=$(cat ${outdir}/initial.pretty | grep "\"count\":" | awk '{print $2}' | tr -d ',')
#cnt=101
pages=$((cnt/100))
inexact=$((cnt%100!=0))
echo $cnt
echo $pages
for i in $(seq 0 $((pages+inexact-1)));
do
next=$(((i+1)*100))
low_inclusive=$((i*100))
high_exclusive=$((next<=cnt-1?next:cnt))
echo $low_inclusive" -> "$high_exclusive
wget -O ${outdir}/file$i.json http://www.panoramio.com/map/get_panoramas.php?set=full\&from=$low_inclusive\&to=$high_exclusive\&minx=$minlon\&miny=$minlat\&maxx=$maxlon\&maxy=$maxlat\&size=original\&mapfilter=false 
cat ${outdir}/file$i.json | python -m json.tool > ${outdir}/file$i.pretty
sleep $((RANDOM % 3))
done

