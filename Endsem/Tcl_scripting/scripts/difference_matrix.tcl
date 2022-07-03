# Makes a matrix of all residue center-of-mass to residue center-of-mass
# of two proteins.  Saves the output to a file in the form
#  residue_id1 residue_id2 distance
# which can be plotted with a variety of graphing packages.
# The input options are:
#      sel1 -- the first set of atoms to compare (the reference atoms)
#      sel2 -- the second set of atom (the comparison atoms)
#  filename -- the output file name (the default is "diffplot.dat"

proc difference_matrix {sel1 sel2 {filename "diffplot.dat"}} {
  # get the list of residues in each selection
  set reslist1 [lsort -integer -unique [$sel1 get residue]]
  set num_reslist1 [llength $reslist1]
  set reslist2 [lsort -integer -unique [$sel2 get residue]]
  set num_reslist2 [llength $reslist2]

  # make sure they have the same number of residues
  if { $num_reslist1 != $num_reslist2 } {
    error "First set of atoms has $num_reslist1 residues but the \
second has $num_reslist2]"
  }

  # compute the center of mass for each residue of the first selection
  foreach residue $reslist1 {
    set sel [atomselect [$sel1 molid] \
           "residue $residue" frame [$sel1 frame]]
    set com(1,$residue) [measure center $sel weight mass]
  }

  # compute the center of mass for each residue of the second selection
  foreach residue $reslist2 {
    set sel [atomselect [$sel2 molid] \
           "residue $residue" frame [$sel2 frame]]
    set com(2,$residue) [measure center $sel weight mass]
  }

  # open the file for output
  set outfile [open $filename w]

  # loop over each residue and print the matrix
  foreach res1 $reslist1 {
    foreach res2 $reslist2 {
      set dist  [veclength [vecsub $com(1,$res1) $com(2,$res2)]]
      puts $outfile "$res1 $res2 $dist"
    }
  }
  # close the file
  close $outfile
}

# a simple interface for comparing all the residues of two systems
proc whole_difference_matrix {mol1 mol2 {filename "diffplot.dat"}} {
  set sel1 [atomselect $mol1 all]
  set sel2 [atomselect $mol2 all]
  difference_matrix $sel1 $sel2 $filename
}
