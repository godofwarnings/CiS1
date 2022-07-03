# ColorCoord 1.0
# --------------
# routines for coloring of the structure according to the coordination
# intended for analysis of ice structures
# water molecules are colored according to the number of h-bonded neighbors
# lubos vrbka, 2006

# *********************************************************************************

# this file is heavily commented so you shouldn't have any problems with it
# however feel free to contact me in case of any problems

# usage:
# set all CC_water... variables according to your simulation
# modify the topology/psf names if applicable
# you have to have NAMD topology and psf file for your system - you can use autopsf for it
# then you can run the analysis itself

# create the array containing number of hbonds per water molecule in the unit cell
# this can take really long time!
# parameters are distance/angle criterion for hbonds, first and last frame (starting
# from 1)
# array set n_hbonds_array [GetMolBonds 3.0 20 1 10]

# you can save/restore the results of the analysis to/from a file
# the following proc will save the n_hbonds array and the global variables
# to a file
# WriteMolHbondsFile [array get n_hbonds_array] n_hbonds_filename

# it can be later safely retrieved
# array set loaded_n_bonds_array [ReadMolHbondsFile n_hbonds_filename]

# you can perform a kind of averaging (pseudo-running average) on the arrays with hbonds
# check the code of the proc
# array set n_hbonds_array_averaged [

# set the user field according to the number of hbonds
# SetMolHbondsUser [array get n_hbonds_array]

# you can use something like user > 3.5 in the selection field for graphical representation

# *********************************************************************************

puts "tools for the analysis of the number of h-bonded neighbors"
puts "lubos vrbka, 2006"
puts ""
puts "defined procedures/functions are:"
puts "GetMolHbonds {distance angle first last} (returns array)"
puts "WriteMolHbondsFile {n_hbonds_array filename}"
puts "ReadMolHbondsFile {filename} (returns array)"
puts "AverageMolHbonds {n_hbonds_array average} (returns array)"
puts "SetMolHbondsUser {n_hbonds_array}"
puts ""
puts "check the source/docs for usage / more info"

# the following global variables control the analysis
# identification of frames in the trajectory
# these are overwritten from the procedure GetMolHbonds/ReadMolHbondsFile
set CC_first_frame 1
set CC_last_frame 1
set CC_total_frames 1
set CC_mol_id 0

# you need to change the following to change the names, ...
# names for atom selections
set CC_water_resname "NE6"
set CC_water_oxygen_name "OW"
# you can set more, e.g., the lone pairs, ...
set CC_water_all "OW \"HW.\""
# total number of particles per residue according to CC_water_all selection
set CC_water_all_nparticles 3

# variables for PBC handling and analysis
# name of the temporary file - you need to have a write access to its location!
set CC_tmpname "_temporary.pdb"
set CC_psfname "_ne6_namd.psf"
set CC_topname "_ne6_namd.top"
set CC_pbc_threshold 4.0


# *********************************************************************************
# *********************************************************************************


proc GetMolHbonds { distance angle first last} {
  # get water coordination numbers and return an "array" with the data
  # parameters:
  # criteria for the hbond, first/last frame information
  # note that first frame has number 1

  global CC_first_frame
  global CC_last_frame
  global CC_total_frames
  global CC_mol_id
  global CC_water_resname
  global CC_water_oxygen_name
  global CC_water_all
  global CC_tmpname
  global CC_psfname
  global CC_topname
  global CC_pbc_threshold

  # get ID of the currently active molecule
  # if you need another molecule -> set it here
  set mol_ID [molinfo top]
  set CC_mol_id $mol_ID

  # ************************************************************************

  # handle frame selection
  # set global variables to zero
  set CC_first_frame 0
  set CC_last_frame 0
  set CC_total_frames 0
  
  # get number of frames
  set numframes [molinfo $mol_ID get numframes]
  puts "total number of frames in trajectory: $numframes"
  set startframe $first
  set endframe $last
  if {$startframe <= 0 || $startframe > $numframes} {
    puts "illegal value of startframe, changing to first frame"
    set startframe 1
  }
  if {$endframe < $startframe || $endframe > $numframes} {
    puts "illegal value of endframe, changing to last frame"
    set endframe $numframes
  }

  set totframes [expr ($endframe - $startframe + 1)]
  puts "analysis will be performed on $totframes frame(s) ($startframe to $endframe)"

  # set the global variables
  set CC_first_frame $startframe
  set CC_last_frame $endframe
  set CC_total_frames $totframes

  # now subtract 1 from all frame indexes - numbering starts with 0
  set startframe [expr $startframe - 1]                                                   
  set endframe [expr $endframe - 1]

  # ************************************************************************

  # set some selections
  set wat [atomselect $mol_ID "resname $CC_water_resname"]
  set cell_oxygen [atomselect $mol_ID "name $CC_water_oxygen_name"]
  set cell_water [atomselect $mol_ID "name $CC_water_all"]

  # create array (a dictionary) that will store number of hbonds for every oxygen
  # for every frame, i.e.
  # oxygen1 [ no_frame1 no_frame2 ...] oxygen2 [ no_frame1 no_frame2 ...]  ...
  # commented out:
  # also create array that will contain all hbonds
  # oxygen1 [{indexes_frame1} {indexes_frame2} {indexes_frame3} ...] oxygen2 [...] ...
  # maybe there will be some use for it in the future :)
  foreach ox_index [$cell_oxygen list] {
    array set n_hbonds [list $ox_index ""]
  }

  # repeat analysis for all required frames
  for {set i $startframe} {$i <= $endframe} {incr i} {
    # update selections for the original geometry and get some residue mapping
    $wat frame $i
    $wat update
    set wat_unique_res [lsort -unique -integer [$wat get resid]]
    set wat_res [$wat get resid]
    set wat_name [$wat get name]

    $cell_oxygen frame $i
    $cell_oxygen update
    $cell_water frame $i
    $cell_water update
    
    set box [molinfo $mol_ID get {a b c}]

    # ************************************************************************
    # handle the PBC - create the images of the central unit cell
    # requires psfgen to work
    package require psfgen

    # read the psf with topology for our system
    # has to be created beforehand
    mol load psf $CC_psfname
    # read the topology (was used to construct the psf file)
    topology $CC_topname

    set psf_ID [molinfo top]

    set n 0
    set seglist {}

    # force segid original structure - if empty then it doesn't work
    # $wat set segid R$n

    # for all 27 different combinations of central cell shift
    foreach x [list 0.0 -1.0 1.0] {
      foreach y [list 0.0 -1.0 1.0] {
        foreach z [list 0.0 -1.0 1.0] {
          set vec [list [expr {$x * [lindex $box 0]} ] [expr {$y * [lindex $box 1]} ] [expr {$z * [lindex $box 2]}]]
          $wat moveby $vec
          puts "shifting by $vec"
          segment R$n {
            first NONE
            last NONE
            foreach res $wat_unique_res {
              residue $res NE6
            }  
          }
          lappend seglist R$n
          foreach resid $wat_res name $wat_name pos [$wat get {x y z}] {
            coord R$n $resid $name $pos
          }
          incr n
          $wat moveby [vecinvert $vec]
	  # clean up
	  unset vec
        }
      }
    }

    # just to be sure and clean up
    unset seglist
 
    # write the structure to a temporary file
    writepdb $CC_tmpname
    # load the temporary file
    mol load pdb $CC_tmpname

    # ************************************************************************
    # do the analysis

    # write a message to indicate the progress
    # the following part takes the longest time...
    puts "analyzing frame [expr $i + 1] ([expr $i - $startframe + 1] of $totframes; requested frames [expr $startframe + 1] - [expr $endframe + 1])"
    
    # create the necessary atom selections
    # oxygens in the central cell
    set cc_oxygen [atomselect top "segid R0 and name $CC_water_oxygen_name"]
    # all oxygens in the system
    # we need to decrease the complexity -> we are taking into account only
    # oxygens within some distance of the central cell since we're interested only
    # in the hydrogen bonds of the central cell anyway
    # set $CC_pbc_threshold to something large to 'turn' this simplication off
    set restricted_oxygen [atomselect top "name $CC_water_oxygen_name and within $CC_pbc_threshold of (resname $CC_water_resname and segid R0)"]

    foreach o_index [$cc_oxygen list] {
    #foreach o_index [list 5] {}
      # set target oxygen in the central cell - we calculate number of
      # hbonds for this species
      set tgt_oxygen [atomselect top "index $o_index"]
      # measure hbonds requires list of donors and acceptors to be "orthogonal"
      # we choose all but the target oxygen; this is done for all cells
      # to ensure that hbonds at cell boundaries are correctly treated
      set exc_oxygen [atomselect top [format "%s %s %s" "([$restricted_oxygen text])" "and not" "([$tgt_oxygen text])"]]

      # do the hbond measurement
      # first, target oxygen acts as donor
      foreach {d_donor d_acceptor d_hydrogen} [measure hbonds $distance $angle $tgt_oxygen $exc_oxygen] break
      # second it acts as an acceptor
      foreach {a_donor a_acceptor a_hydrogen} [measure hbonds $distance $angle $exc_oxygen $tgt_oxygen] break

      # merge results to get total number of hbonds for the molecule
      set tot_hbonds [concat $d_acceptor $a_donor]
      lappend n_hbonds([$tgt_oxygen list]) [llength $tot_hbonds]

      # clean up
      unset a_donor a_acceptor a_hydrogen d_donor d_acceptor d_hydrogen
      unset tot_hbonds
      $tgt_oxygen delete
      $exc_oxygen delete
    }
    
    # clean up
    resetpsf
    unset wat_unique_res
    unset wat_res
    unset wat_name
    $cc_oxygen delete
    $restricted_oxygen delete
    # remove the molecule with PBC and psf
    mol delete top
    mol delete $psf_ID

  # repeat for another frame
  }

  # clean up
  $wat delete
  $cell_oxygen delete
  $cell_water delete
  
  puts "done"
  array set CC_n_hbonds [array get n_hbonds]
  return [array get n_hbonds]
}


# *********************************************************************************
# *********************************************************************************


proc WriteMolHbondsFile {n_hbonds_array filename} {
  # stores the global variables and n_hbonds array in a file

  # 'export' global variables
  global CC_first_frame
  global CC_last_frame
  global CC_total_frames
  global CC_mol_id
  global CC_water_resname
  global CC_water_oxygen_name
  global CC_water_all
  global CC_water_all_nparticles
  global CC_tmpname
  global CC_psfname
  global CC_topname
  global CC_pbc_threshold

  array set n_hbonds $n_hbonds_array

  # open the file
  set fw [open $filename w]
  
  puts $fw "MolHbondsCoord"
  puts $fw "$CC_first_frame $CC_last_frame $CC_total_frames $CC_mol_id"
  puts $fw $CC_water_resname
  puts $fw $CC_water_oxygen_name
  puts $fw $CC_water_all
  puts $fw $CC_water_all_nparticles
  puts $fw $CC_tmpname
  puts $fw $CC_psfname
  puts $fw $CC_topname
  puts $fw $CC_pbc_threshold
  
  puts $fw "numatoms [llength [array name n_hbonds]]"
  
  foreach {o_index h_bonds_list} [array get n_hbonds] {
    puts $fw $o_index
    puts $fw $h_bonds_list
  }
  
  close $fw
  
  puts "variables stored"
}


# *********************************************************************************
# *********************************************************************************


proc ReadMolHbondsFile {filename} {
  # restores the global variables and n_hbonds array from a file

  # 'export' global variables
  global CC_first_frame
  global CC_last_frame
  global CC_total_frames
  global CC_mol_id
  global CC_water_resname
  global CC_water_oxygen_name
  global CC_water_all
  global CC_water_all_nparticles
  global CC_tmpname
  global CC_psfname
  global CC_topname
  global CC_pbc_threshold


  # open the file
  set fr [open $filename r]
  
  # check the header
  gets $fr line
  if [eof $fr] {
    puts "premature eof in header"
    close $fr
    return
  }
  if {$line != "MolHbondsCoord"} {
    puts "unrecognized header"
    close $fr
    return
  }

  # read and set frame/molecule related variables
  gets $fr line
  if [eof $fr] {
    puts "premature eof in frame info"
    close $fr
    return
  }
  if {[llength $line] != 4} {
    puts "error in frame info line"
    close $fr
    return
  }
  set CC_first_frame [lindex $line 0]; set CC_last_frame [lindex $line 1]
  set CC_total_frames [lindex $line 2];
  # set the CC_mol_id to the id of the TOP molecule
  # i.e., the stored value is ignored
  set CC_mol_id [molinfo top]

  # read and set the selection strings
  gets $fr CC_water_resname
  if [eof $fr] {
    puts "premature eof in water_resname string"
    close $fr
    return
  }
  gets $fr CC_water_oxygen_name
  if [eof $fr] {
    puts "premature eof in water_oxygen_name string"
    close $fr
    return
  }
  gets $fr CC_water_all
  if [eof $fr] {
    puts "premature eof in water_all string"
    close $fr
    return
  }
  gets $fr CC_water_all_nparticles
  if [eof $fr] {
    puts "premature eof in water_all_nparticles"
    close $fr
    return
  }

  # read and set the filenames etc...
  gets $fr CC_tmpname
  if [eof $fr] {
    puts "premature eof in tmpname"
    close $fr
    return
  }
  gets $fr CC_psfname
  if [eof $fr] {
    puts "premature eof in psfname"
    close $fr
    return
  }
  gets $fr CC_topname
  if [eof $fr] {
    puts "premature eof in topname"
    close $fr
    return
  }
  gets $fr CC_pbc_threshold
  if [eof $fr] {
    puts "premature eof in pbc_threshold"
    close $fr
    return
  }

  # read the n_hbonds array
  #firstly, the number of stored records
  gets $fr line
  if [eof $fr] {
    puts "premature eof in pbc_threshold"
    close $fr
    return
  }
  if {[llength $line] != 2} {
    puts "error in number of molecules (records) line"
    close $fr
    return
  }
  set n_records [lindex $line 1]

  for {set i 1} {$i <= $n_records} {incr i} {
    gets $fr o_index
    if [eof $fr] {
      puts "premature eof hbonds (atom index in set $i)"
      close $fr
      return
    }
    gets $fr h_bonds_list
    if [eof $fr] {
      puts "premature eof hbonds (atom index in set $i)"
      close $fr
      return
    }
    array set n_hbonds [list $o_index $h_bonds_list]
  }

  close $fr

  puts "variables restored:"
  puts ""
  puts "frames - first: $CC_first_frame last: $CC_last_frame total: $CC_total_frames mol_ID: $CC_mol_id"
  puts "water resname selection string: $CC_water_resname"
  puts "water oxygen name selection string: $CC_water_oxygen_name"
  puts "water all atoms selection string $CC_water_all"
  puts "number of particles in all_atoms per molecule: $CC_water_all_nparticles"
  puts "temporary file name: $CC_tmpname"
  puts "psf file name: $CC_psfname"
  puts "topology file name: $CC_topname"
  puts "PBC threshold for hbonds analysis: $CC_pbc_threshold"

  return [array get n_hbonds]
}


# *********************************************************************************
# *********************************************************************************


proc AverageMolHbonds {n_hbonds_array average} {
  # does a kind of running average
  # 'average' gives the number of samples that should be taken
  # it takes the respective value +- average values
  # if there are less values than required, average over smaller number of samples is used
  # returns an array with averaged data

  global CC_total_frames

  array set n_hbonds $n_hbonds_array

  # set some values
  set totframes $CC_total_frames
  set average_half [expr $average / 2]

  puts "averaging total $totframes frames, running average over $average samples"

  foreach {o_index n_hbonds_list} [array get n_hbonds] {
    # averaging is done for all oxygen atoms

    # create new array for the averaged values
    array set avg_n_hbonds [list $o_index ""]
    # check whether the list is ok - it should have $totframes samples
    # where totframes is the total number of analyzed frames
    if { [llength $n_hbonds_list] != $totframes } {
      puts "critical error - not enough samples in the h_bonds list!"
      return
    }
    
    # go through the list
    for {set i 0} {$i < $totframes} {incr i} {
      # set limits for averaging
      set start [expr $i - $average_half]
      if {$start < 0} {
        set start 0
      }
      set stop [expr $i + $average_half]
      if {$stop >= $totframes} { 
        set stop [expr $totframes - 1]
      }
      set samples [expr $stop - $start + 1]

      # do the respective average
      set nhb_value 0.0
      for {set n $start} {$n <= $stop} {incr n} {
        set nhb_value [expr $nhb_value + [lindex $n_hbonds_list $n]]
      }  
      set nhb_value [expr $nhb_value / $samples]

      # add the value to the new array
      lappend avg_n_hbonds($o_index) $nhb_value
    }
  }
  # return the averaged array
  return [array get avg_n_hbonds]
}


# *********************************************************************************
# *********************************************************************************


proc SetMolHbondsUser {n_hbonds_array} {
  # set the user field for the selected molecules/atoms to the value of n_hbonds

  global CC_first_frame
  global CC_last_frame
  global CC_total_frames
  global CC_mol_id
  global CC_water_all
  global CC_water_all_nparticles

  array set n_hbonds $n_hbonds_array

  # get frame info from global variable and
  # subtract 1 from all frame indexes - numbering starts with 0
  set startframe [expr $CC_first_frame - 1]                                                 
  set endframe [expr $CC_last_frame - 1]
  set totframes [expr ($endframe - $startframe + 1)]

  set mol_ID $CC_mol_id

  # set some selections
  set cell_water [atomselect $mol_ID "name $CC_water_all"]

  # go over the trajectory
  # set original molecule user field according to the analysis
  for {set i $startframe; set listindex 0} {$i <= $endframe} {incr i; incr listindex} {
    # process the n_hbonds array
    # replicate the appropriate record (n_hbonds for the given oxygen and frame)
    # to provide CC_water_all_nparticles (the same) numbers.
    # we expect oxygens and hydrogens to be at the same
    # place in the topology, so if we have
    # atomselect "name OW" and atomselect "name OW \"HW.\""
    # then the indexes for atoms belonging to the same molecule will be grouped
    # together and we can just use n_hbonds to mark the appropriate hydrogens(lone pairs,...) as well
    # if they are put to the same selection
    $cell_water frame $i
    $cell_water update
    set frame_user {}
    foreach o_index [lsort -integer [array name n_hbonds]] {
      set nhb_value [lindex $n_hbonds($o_index) $i]
      for {set x 0} {$x < $CC_water_all_nparticles} {incr x} {
        set frame_user [concat $frame_user $nhb_value]
      }
    }														      

    $cell_water set user $frame_user
  
    # clean up
    unset nhb_value frame_user
   
   # repeat for next frame
  }
  
  $cell_water delete
}
