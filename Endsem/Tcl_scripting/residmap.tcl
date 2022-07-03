#
# ResidMap - converts resids between different numbering schemes
#
# Sometimes the resid numbers in the crystal structure and in the model
# used in a simulation do not match. This package provides routines
# to convert back and forth between the numbering. All you need is a
# map file with the correspondence between the two in the following
# format:
#
# # segname resid_model resid_xtal
# 16S  1007 1029
# 16S  1008 1030
# 16S  1009 1030A
# 16S  1010 1030B
# 16S  1011 1030C
# 16S  1012 1030D
# 16S  1013 1031
# 16S  1014 1032
# ...
#
# The resids don't have to be numbers, so you can use insertion codes
# like the above example.
#
# Usage:
#
# source residmap.tcl
# residmap <map file>
#
# Now the following functions are available:
#
# model2xtal <resid> <segname>
# xtal2model <resid> <segname>
#
# If a given resid and segname are not found in the map file, the same
# resid is returned. This means that you do not necessarily need to 
# provide a mapping of all resids, but only the ones that change. 
#
# Leonardo Trabuco <ltrabuco@ks.uiuc.edu> - Sun Mar 18 01:16:36 CDT 2007

package provide residmap 1.0

namespace eval ::ResidMap:: {

  variable model2xtalMap
  variable xtal2modelMap
  variable segnameList {}
  variable readmap 0

}

proc residmap { args } { return [eval ::ResidMap::residmap $args] }
proc model2xtal { args } { return [eval ::ResidMap::model2xtal $args] }
proc xtal2model { args } { return [eval ::ResidMap::xtal2model $args] }

proc ::ResidMap::residmap_usage { } {
  puts "Usage: residmap <map file>"
}

# read the map with the correspondence between resids
proc ::ResidMap::residmap { args } {

  variable model2xtalMap
  variable xtal2modelMap
  variable segnameList
  variable readmap

  set nargs [llength $args]
  if { $nargs != 1 } {
    residmap_usage
    error ""
  }
  set mapfile [lindex $args 0]

  if { $readmap == 1 } {
    reset_map
    set readmap 0
  }
  
  set file [open $mapfile r]
  while { ![eof $file] } {
    gets $file line
    # ignore comment and blank lines
    if {![regexp {^#} $line]} {
      if { ![regexp -expanded -- {^[\t ]*$} $line]} {
        set segname [lindex $line 0]
        set resid_model [lindex $line 1]
        set resid_xtal [lindex $line 2]
        set model2xtalMap($segname$resid_model) $resid_xtal 
        set xtal2modelMap($segname$resid_xtal) $resid_model
        if { [lsearch -exact $segnameList $segname] == -1 } {
          lappend segnameList $segname
        }
      }
    }
  }

  close $file
  set readmap 1

  return

}

proc ::ResidMap::reset_map { } {

  variable model2xtalMap
  variable xtal2modelMap
  variable segnameList
  variable readmap

  foreach key [array names model2xtalMap] {
    unset model2xtalMap($key)
  }
  foreach key [array names xtal2modelMap] {
    unset xtal2modelMap($key)
  }
  for {set i 0} {$i < [llength $segnameList]} {incr i} {
    lvarpop segnameList
  }

  return 

}

proc ::ResidMap::convert_resid_usage { } {
  puts "Usage: convert_resid <resid> <segname> \[xtal2model|model2xtal\]"
  return
}

proc ::ResidMap::convert_resid { args } {

  variable model2xtalMap
  variable xtal2modelMap
  variable segnameList
  variable readmap

  set nargs [llength $args]
  if { $nargs != 3 } {
    convert_resid_usage
    error ""
  }
  set resid [lindex $args 0]
  set segname [lindex $args 1]
  set mode [lindex $args 2]

  # return an error if no map was read
  if { $readmap == 0 } {
    error "No map has been read. Use 'residmap <map file> to provide a map."
  }

  # if the segname is not in the list, return the same resid
  if { ![lsearch segnameList $segname] == -1 } {
    return $resid
    return
  } else {
    if { $mode == "model2xtal" } {
      if { ![info exists model2xtalMap($segname$resid)] } {
        #error "resid $resid and segname $segname are not present in the map."
        # if a resid is not in the map, return the same resid
        return $resid
      } else {
        return $model2xtalMap($segname$resid)
      }
    } elseif { $mode == "xtal2model" } {
      if { ![info exists xtal2modelMap($segname$resid)] } {
        # if a resid is not in the map, return the same resid
        return $resid
      } else {
        return $xtal2modelMap($segname$resid)
      }
    } else {
      convert_resid_usage
      error "unrecognized mode: use xtal2model or model2xtal"
    }
  }
  
  return

}

proc ::ResidMap::xtal2model_usage { } {
  puts "Usage: xtal2model resid segname"
  return
}

proc ::ResidMap::xtal2model { args } {

  set nargs [llength $args]
  if { $nargs != 2 } {
    xtal2model_usage
    error ""
  }
  set resid [lindex $args 0]
  set segname [lindex $args 1]
  return [convert_resid $resid $segname xtal2model]

}

proc ::ResidMap::model2xtal_usage { } {
  puts "Usage: model2xtal resid segname"
  return
}

proc ::ResidMap::model2xtal { args } {
  
  set nargs [llength $args]
  if { $nargs != 2 } {
    model2xtal_usage
    error ""
  }
  set resid [lindex $args 0]
  set segname [lindex $args 1]
  return [convert_resid $resid $segname model2xtal]

}

