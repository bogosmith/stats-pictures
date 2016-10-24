#!/bin/bash

usage() { echo "Usage: $0 -o <output_dir> -i <input_file> -s <start_date> -e <end_date> (-d <bounding_box_side_in_kilometers>) (-f <hour|day|week|month>)" 1>&2; exit 1; }
nodir() { echo "Output directory has to exist." 1>&2; exit 1; }
noinput() { echo "Input file has to exist." 1>&2; exit 1; }
dirnotempty() { echo "Output directory has to be empty." 1>&2; exit 1; }

while getopts ":o:i:s:e:f:d:" o; do
    case "${o}" in
       i) 
          input_file="${OPTARG}"
          ;;
       d) 
          bbox_side="${OPTARG}"
          ;;
       o) 
          outdir="${OPTARG}"
          ;;
       s) 
          start_date="${OPTARG}"
          ;;
       e) 
          end_date="${OPTARG}"
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

if [ -z "${start_date}" ]; then
  usage
fi

if [ -z "${end_date}" ]; then
  usage
fi

if [ ! -d "${outdir}" ]; then
  nodir
fi

if [ ! -e "${input_file}" ]; then
  noinput
fi

if [ "$(ls -A $outdir)" ]; then
  dirnotempty
fi
extract_script=$(dirname $(cd "$( dirname "$0" )" && pwd))/bash/extract_flickr.sh

oldifs=$IFS
IFS=$'\r\n'
lines=($(cat ${input_file}))
IFS=$oldifs

for l in "${lines[@]}"
do
  #Extract the first symbol of the line to test if it is a number. If it isn't skip assuming that this is a header line.
  p=${l:0:1}
  if [[ !  $p =~ ^[0-9]+$ ]]
  then
    continue
  fi
  toks=($(echo $l))
  id=${toks[0]}
  lat=${toks[1]}
  lon=${toks[2]}
  dir_for_point=$outdir/$id
  mkdir $dir_for_point 
  cmd="bash $extract_script -o $dir_for_point -a $lat -g $lon -s $start_date -e $end_date -d $bbox_side -f $freq"
  echo $cmd
  $cmd 
  exit 1;
done
