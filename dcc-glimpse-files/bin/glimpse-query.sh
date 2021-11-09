#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

##
## Call this to do simple glimpse queries.
##
## A list of arguments will become and "and"
## query.
##
## keywords: allword anyword allsub anysub
##
## Phil Ehrens <pehrens@ligo.caltech.edu>
##

# Uncomment to debug input
#set fid [ open /tmp/foo w ]
#puts $fid '$argv'
#close $fid

set type  [ lindex $argv end ]
set words [ join [ lrange $argv 0 end-1 ] ]

if { ! [ regexp {^(allword|allsub|anyword|anysub)$} $type ] } {
   return -code error "Bad type: '$type'"
}

if { [ string match all* $type ] } {
   set ::words [ join $words "\\;" ]
} else {
   set ::words [ join $words "," ]
}

if { [ string match *word $type ] } {
   set ::opts -w
} else {
   set ::opts [ list ]
}

# Add '-L 100' to limit total number of matches to 100 files
set ::glimpse "env TMPDIR=/usr2/GLIMPSE /usr/local/bin/glimpse -W $::opts -i -l -z -y -H"
#set ::incremental "$::glimpse /usr2/GLIMPSE/dcc.glimpse.incremental $::words"
#catch { eval exec $::incremental } a
#puts $a 

set partitions [glob -directory "/usr2/GLIMPSE/" dcc.glimpse\[0-9\] ]
foreach item $partitions {
    set ::cron "$::glimpse $item  $::words"
    catch { eval exec $::cron } b
    puts $b
}


