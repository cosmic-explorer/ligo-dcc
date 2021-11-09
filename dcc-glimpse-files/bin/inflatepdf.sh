#!/bin/ksh

IFS=$'\n'

if [[ -f "$1" ]]
then
   data=$(/usr/local/bin/readpdf.pl -dv "$1" 2>/dev/null)
fi

bin_rx='[\x00-\x08\x0b\x0e-\x1f]'
begin_rx='^>'

set -o noglob

for line in $data
do
   if [[ ! $line =~ $bin_rx ]] && [[ $line =~ $begin_rx ]]
   then
      #line=${line/<\/.+/}
      #line=${line##<}
      #line=${line%%>}
       print -- $line
   fi
done
