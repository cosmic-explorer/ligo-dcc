#!/usr/bin/tclsh

set ::TEXTSIZELIMIT 500000

set ::SHADOW /usr2/GLIMPSE/shadow

set ::DEBUG 0

#set ::REPORTFILE /var/log/httpd/glimpse-prefilter.REPORT.[ clock seconds ]
set ::REPORTFILE ""

set ::xmlish [ list xml uml html htm shtml uml ]

set ::ts [ clock format [ clock seconds ] -format "%m/%d/%y-%r %Z" ]

namespace eval ::extension {}

proc countfiles { dir } {
   foreach item [ glob -nocomplain $dir/* ] {
      if { [ file isdir $item ] } {
         incr ::dc
         set test [ regsub -all {/} $dir {} tmp ]
         if { $test > $::lc } { set ::lc $test }
         countfiles $item
      } else {
         incr ::fc
         histogram $item
         set type [ string trim [ file extension $item ] . ]
         set type [ string tolower $type ]
         if { [ string length $type ] == 0 } { set type NOEXTENSION }
         if { [ regexp {([a-f0-9]){40}} $type ] } { set type e-traveler }
         if { ! [ info exists ::N($type) ] } { set ::N($type) 0 }
         incr ::N($type)
         if { [ lsearch $::xmlish $type ] > -1 } {
            set type xml
         }
         if { [ update $item ] } {
            if { [ catch { ::extension::$type $item } err ] } {
               lappend ::UNKNOWN($type) "countfiles choked on '$item'. Error: '$err'."
            }
         }   
      }
   }
}

proc onefile { file } {
     set type [ string trim [ file extension $file ] . ]
     set type [ string tolower $type ]
     if { [ lsearch $::xmlish $type ] > -1 } {
        set type xml
     }
     if { [ update $file ] } {
        if { [ catch { ::extension::$type $file } err ] } {
           return -code error "prefilter.tcl onefile error: '$err'" 
        }
     }   
}

proc histogram { file } {
   set file [ file tail $file ]
   foreach char [ split $file {} ] {
      if { ! [ info exists ::histbin($char) ] } {
         set ::histbin($char) 0
      }
      incr ::histbin($char)
   }
}

proc ::extension::pdf { file } {
   set oops {^To view the full contents of this document}
   set type [ fileType $file ]
   if { [ lsearch $type pdf ] < 0 } {
      lappend ::ERR(pdf) "'$file' is type '$type'"
   } elseif { [ lsearch $type text ] > -1 } {
      copy $file
   } else {
      if { [ catch { exec pdftotext -fixed 6 $file - } text ] } {
         foreach line [ split $text "\n" ] {
            if { [ regexp {Error:.{0,60}} $line err ] } {
               lappend ::ERR(pdf) "$file (pdftotext): '$err'"
               break
            }
         }   
      }
      if { [ regexp $oops $text ] } {
         set text [ inflatepdf $file ]
      }
      if { [ string length $text ] < 20 } {
         catch { exec /usr/bin/strings -n 20 $file } more
         append text $more
      }   
      write $file $text
   }
}

proc inflatepdf { file } {
     set text [ list ]
     catch { exec /usr/local/bin/inflatepdf.sh $file } text
     return $text
}

proc ::extension::ps { file } {
   # catch { exec ps2ascii $file } text
   # try to deal with known pathological docs 
   # /usr1/www/html/DocDB/0020/P1000112/027/H1H2paper_12022014.ps
   catch {
   	catch { exec ps2ascii $file } text
   }
   write $file $text
}

proc ::extension::hdf5 { file } {
   set er_rx {command not found}
   catch { exec h5dump --header $file } text
   if { [ regexp -- $er_rx $text ] } {
      lappend ::ERR(hdf5) "$file (hdf5): '$text'"
   } else {
      write $file $text
   }
}

proc ::extension::doc { file } {
   set er_rx {(fast-saved|sheet is not flushed|Format a4 is)}
   if { [ catch { exec catdoc $file } text ] } {
      foreach line [ split $text "\n" ] {
         if { [ regexp -- $er_rx $line ] } {
            lappend ::ERR(doc) "$file (catdoc): '$line'"
            break
         }
      }
   }   
   write $file $text
}

proc ::extension::xls { file } {
   set er_rx {(fast-saved|sheet is not flushed|Format a4 is|child killed)}
   if { [ catch { exec xls2csv $file } text ] } {
      foreach line [ split $text "\n" ] {
         if { [ regexp -- $er_rx $line ] } {
            lappend ::ERR(xls) "$file (xls2csv): '$line'"
            break
         }
      }
   }
   write $file $text
}

proc ::extension::odt { file } {
   catch { exec unzip -p $file content.xml } text
   regsub -all {<[^>]+>} $text { } text
   regsub -all {\s+}     $text { } text
   write $file $text
}

proc ::extension::docx { file } {
   catch { exec unzip -p $file word/document.xml } text
   regsub -all {<[^>]+>} $text { } text
   regsub -all {\s+}     $text { } text
   write $file $text
}

proc ::extension::docm { file } {
   catch { exec unzip -p $file word/document.xml } text
   regsub -all {<[^>]+>} $text { } text
   regsub -all {\s+}     $text { } text
   write $file $text
}

proc ::extension::pptx { file } {
   catch { exec unzip -p $file ppt/slides/slide*.xml } text
   regsub -all {<[^>]+>} $text { } text
   regsub -all {\s+}     $text { } text
   write $file $text
}

proc ::extension::xlsm { file } {
   catch { exec unzip -p $file xl/worksheets/sheet*.xml } text
   regsub -all {<[^>]+>} $text { } text
   regsub -all {\s+}     $text { } text   
   write $file $text
}
proc ::extension::xlsx { file } {
   catch { exec unzip -p $file xl/worksheets/sheet*.xml } text
   regsub -all {<[^>]+>} $text { } text
   regsub -all {\s+}     $text { } text   
   write $file $text
}

# Special handling for ppt files - They sometimes segv catppt
proc ::extension::ppt { file } {
  set text [ list ]
  set more [ list ]
  set seg_rx {child\s+killed:\s+segmentation\s+violation}
  if { [ catch { exec catppt $file } text ] } {
     lappend ::ERR(ppt) "$file (catppt): '$text' (I will run 'strings' to index it.)"
     catch { exec /usr/bin/strings -n 20 $file } text
     write $file $text
  } elseif { [ regexp $seg_rx $text ] } {
     lappend ::ERR(ppt) "$file (catppt): '$text' (I will run 'strings' to index it.)"
     catch { exec /usr/bin/strings -n 20 $file } text
     write $file $text
  } else {
     catch { exec /usr/bin/strings -n 20 $file } more
     append text $more
     write $file $text
  }   
}

proc ::extension::zip { file } {
   # We only look at the index, sorry!
   catch { exec unzip -Z -2 $file } text
   write $file $text
}

proc ::extension::key { file } {
   # We only look at the index, sorry!
   catch { exec unzip -Z -2 $file } text
   write $file $text
}

proc ::extension::xml { file } {
   set text [ readfile $file ]
   regsub -all {<[^>]+>} $text { } text
   regsub -all {\s+}     $text { } text
   write $file $text
}

proc unknown { ext file } {
     set ext [ lindex [ split $ext : ] end ]
     set type [ fileType $file ]
     if { [ lsearch $type pdf ] > -1 } {
        lappend ::UNKNOWN(pdf) "'$file' is a pdf - So it will be indexed."
        ::extension::pdf $file 
     } elseif { [ lsearch $type binary ] > -1 } {
        lappend ::UNKNOWN($ext) "'$file' '$type'"
     } elseif { [ file size $file ] > $::TEXTSIZELIMIT } {
        truncate $file
     } else {
        copy $file
     }
}

proc readfile { file } {
   set fid  [ open $file r ]
   set text [ read $fid [ file size $file ] ]
   close $fid
   return $text
}

proc copy { file } {
     file mkdir $::SHADOW/[ file dirname $file ]
     file copy -force $file $::SHADOW/$file
}

proc truncate { file } {
     set fid  [ open $file r ]
     set text [ read $fid $::TEXTSIZELIMIT ]
     close $fid
     write $file $text
}

proc write { file data } {
     if { ! [ info exists ::ERR(DEBUG) ] } {
        set ::ERR(DEBUG) [ list ]
     }
     file mkdir $::SHADOW/[ file dirname $file ]
     set fid [ open $::SHADOW/$file w ]
     puts $fid $data
     close $fid
     if { $::DEBUG } {
        lappend ::ERR(DEBUG) "[ string length $data ] bytes written to shadow $file"
     }
}

# don't analyze a file that's already in the shadow
# tree if the real file hasn't been updated.
proc update { file } {
   set bool 1
   set shadow $::SHADOW/$file
   if { [ file readable $file ] } {
      set t1 [ file mtime $file ]
      if { [ file exists $shadow ] } {
         set t2 [ file mtime $shadow ]
         if { $t1 < $t2 } {
            set bool 0
         }
      }
   } else {
      lappend ::UNKNOWN(unreadable) "File unreadable: $file"
      set bool 0
   }   
   return $bool
}

# fileTypeInternal --
#
#	Do some simple heuristics to determine file type.
#
#
# Arguments:
#	filename        Name of the file to test.
#
# Results
#	type            Type of the file.  May be a list if multiple tests
#                       are positive (eg, a file could be both a directory 
#                       and a link).  In general, the list proceeds from most
#                       general (eg, binary) to most specific (eg, gif), so
#                       the full type for a GIF file would be 
#                       "binary graphic gif"
#
#                       At present, the following types can be detected:
#
#                       directory
#                       empty
#                       binary
#                       text
#                       script <interpreter>
#                       executable [elf, dos, ne, pe]
#                       binary graphic [gif, jpeg, png, tiff, bitmap, icns]
#                       ps, eps, pdf
#                       html
#                       xml <doctype>
#                       message pgp
#                       compressed [bzip, gzip, zip, tar]
#                       audio [mpeg, wave]
#                       gravity_wave_data_frame
#                       link
#			doctools, doctoc, and docidx documentation files.
#                  

proc fileTypeInternal {filename} {
    ;## existence test
    if { ! [ file exists $filename ] } {
        set err "file not found: '$filename'"
        return -code error $err
    }
    ;## directory test
    if { [ file isdirectory $filename ] } {
        set type directory
        if { ! [ catch {file readlink $filename} ] } {
            lappend type link
        }
        return $type
    }
    ;## empty file test
    if { ! [ file size $filename ] } {
        set type empty
        if { ! [ catch {file readlink $filename} ] } {
            lappend type link
        }
        return $type
    }
    set bin_rx {[\x00-\x08\x0b\x0e-\x1f]}

    if { [ catch {
        set fid [ open $filename r ]
        fconfigure $fid -translation binary
        fconfigure $fid -buffersize 1024
        fconfigure $fid -buffering full
        set test [ read $fid 1024 ]
        fconfigure $fid -buffersize 262144
        set Btest [ read $fid 262144 ]
        ::close $fid
    } err ] } {
        catch { ::close $fid }
        return -code error "fileType: $err"
    }

    if { [ regexp $bin_rx $Btest ] } {
        set type binary
        set binary 1
    } else {
        set type text
        set binary 0
    }

    if { [ regexp {^\#\!\s*(\S+)} $test -> terp ] } {
        lappend type script $terp
    } elseif {[regexp "\\\[manpage_begin " $test]} {
	lappend type doctools
    } elseif {[regexp "\\\[toc_begin " $test]} {
	lappend type doctoc
    } elseif {[regexp "\\\[index_begin " $test]} {
	lappend type docidx
    } elseif { $binary && [ regexp {^[\x7F]ELF} $test ] } {
        lappend type executable elf
    } elseif { $binary && [string match "MZ*" $test] } {
        if { [scan [string index $test 24] %c] < 64 } {
            lappend type executable dos
        } else {
            binary scan [string range $test 60 61] s next
            set sig [string range $test $next [expr {$next + 1}]]
            if { $sig == "NE" || $sig == "PE" } {
                lappend type executable [string tolower $sig]
            } else {
                lappend type executable dos
            }
        }
    } elseif { $binary && [string match "BZh91AY\&SY*" $test] } {
        lappend type compressed bzip
    } elseif { $binary && [string match "\x1f\x8b*" $test] } {
        lappend type compressed gzip
    } elseif { $binary && [string range $test 257 262] == "ustar\x00" } {
        lappend type compressed tar
    } elseif { $binary && [string match "\x50\x4b\x03\x04*" $test] } {
        lappend type compressed zip
    } elseif { $binary && [string match "\xd0\xcf\x11*" $test] } {
        lappend type microsoft proprietary
    } elseif { $binary && [string match "GIF*" $test] } {
        lappend type graphic gif
    } elseif { $binary && [string match "icns*" $test] } {
        lappend type graphic icns bigendian
    } elseif { $binary && [string match "snci*" $test] } {
        lappend type graphic icns smallendian
    } elseif { $binary && [string match "\x89PNG*" $test] } {
        lappend type graphic png
    } elseif { $binary && [string match "\xFF\xD8\xFF*" $test] } {
        binary scan $test x3H2x2a5 marker txt
        if { $marker == "e0" && $txt == "JFIF\x00" } {
            lappend type graphic jpeg jfif
        } elseif { $marker == "e1" && $txt == "Exif\x00" } {
            lappend type graphic jpeg exif
        }
    } elseif { $binary && [string match "MM\x00\**" $test] } {
        lappend type graphic tiff
    } elseif { $binary && [string match "BM*" $test] && [string range $test 6 9] == "\x00\x00\x00\x00" } {
        lappend type graphic bitmap
    } elseif { [string match "\%PDF\-*" $test] } {
        lappend type pdf
    } elseif { [string match "\x89\x48\x44\x46\x0d\x0a\x1a\x0a" $test] } {
        lappend type hdf
    } elseif { ! $binary && [string match -nocase "*\<html\>*" $test] } {
        lappend type html
    } elseif { [string match "\%\!PS\-*" $test] } {
       lappend type ps
       if { [string match "* EPSF\-*" $test] } {
           lappend type eps
       }
    } elseif { [string match -nocase "*\<\?xml*" $test] } {
        lappend type xml
        if { [ regexp -nocase {\<\!DOCTYPE\s+(\S+)} $test -> doctype ] } {
            lappend type $doctype
        }
    } elseif { [string match {*BEGIN PGP MESSAGE*} $test] } {
        lappend type message pgp
    } elseif { $binary && [string match {IGWD*} $test] } {
        lappend type gravity_wave_data_frame
    } elseif {[string match "JL\x1a\x00*" $test] && ([file size $filename] >= 27)} {
	lappend type metakit smallendian
    } elseif {[string match "LJ\x1a\x00*" $test] && ([file size $filename] >= 27)} {
	lappend type metakit bigendian
    } elseif { $binary && [string match "RIFF*" $test] && [string range $test 8 11] == "WAVE" } {
        lappend type audio wave
    } elseif { $binary && [string match "ID3*" $test] } {
        lappend type audio mpeg
    } elseif { $binary && [binary scan $test S tmp] && [expr {$tmp & 0xFFE0}] == 65504 } {
        lappend type audio mpeg
    }

    ;## lastly, is it a link?
    if { ! [ catch {file readlink $filename} ] } {
        lappend type link
    }
    return $type
}

proc fileType { filename } {
     if { [ catch {
        set type [ fileTypeInternal $filename ]
     } err ] } {
        lappend ::UNKNOWN(fileType) $err
        set type [ list ]
     }
     return $type
}

proc report { args } {
     if { [ string length $::REPORTFILE ] } {
        set fid [ open $::REPORTFILE w ]
     } else {
        set fid stdout
     }
     puts $fid "REPORT DATE: $::ts\n\n"
     puts $fid "[ join $::scanreport "\n" ]\n"
     foreach ext [ lsort -dictionary [ array names ::N ] ] {
       puts $fid "$ext: $::N($ext)"
       if { [ info exists ::ERR($ext) ] } {
         puts $fid "[ join $::ERR($ext) "\n" ]\n"
       }
     }
     foreach ext [ lsort -dictionary [ array names ::UNKNOWN ] ] {
       puts $fid "$ext:\n[ join $::UNKNOWN($ext) "\n" ]\n"
     }
     puts $fid "Filename character frequency (N):\n"
     foreach char [ lsort -dictionary [ array names ::histbin ] ] {
        set code [ scan $char %c ]
        puts $fid "$char \[$code\] $::histbin($char)"
     }
     if { [ info exists ::ERR(DEBUG) ] } {
       puts $fid [ join [ lsort -dictionary $::ERR(DEBUG) ] "\n" ]
     }
}

set ::scanreport [ list ]

foreach dir $argv {
   if { [ file isdir $dir ] } {
      set ::fc 0
      set ::dc 1
      set ::lc 0
      set start [ clock clicks -milliseconds ]
      countfiles $dir
      set end [ clock clicks -milliseconds ]
      lappend ::scanreport "scanned $dir in [ expr $end - $start ] ms"
      lappend ::scanreport "$dir has $::fc files in $::dc dirs in $::lc level(s)"
   } elseif { [ file exists $dir ] } {
      onefile $dir
   }
}

if { [ info exists ::fc ] } {
    report
}
