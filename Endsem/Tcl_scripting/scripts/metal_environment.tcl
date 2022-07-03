
#VMD  --- start of VMD description block
#Name:
# Metal Environment
#Synopsis:
# Finds the propensity of residues near given ions
#Version:
# 1.0
#Uses VMD version:
# 1.7 or later
#Ease of use:
# 4
#Procedures:
# <li>myincr varname value -- adds 'value' (a float) to varname.
# <li> find_nearby_residues -- finds residues near an ion
# <li> analyze_ion_propensity -- main driver
#Description:
#  An example of how to use VMD to write analysis scripts.  This
# analyzes the propensity for various residues to be near a set of
# ions.  It takes as input a list of PDB entries and ion names.
# It uses the "mol pdbload" command to ftp the entries automatically
# from the PDB ftp site.  For each ion, it searchs "within" a given
# number of &Aring;ngstroms and adds the hits to a search bin.
#Example:
# <pre>
# vmd> analyze_ion_propensity {1trz 1lnd 1ezm} ZN
# ALA :****
# ARG :***
# ASN :****
# ASP :***
# CYS :**
# GLN :
# GLU :******
# GLY :
# HIS :***********
# ILE :
# LEU :*
# LYS :**
# MET :
# PHE :*
# PRO :
# SER :****
# THR :
# TRP :
# TYR :***
# VAL :****
# </pre>
#Comments:
# Assumes the ions can be determined by name and lack of bonds.
# The output only works for standard residues within 7A of Zn.
# This script must be modified to be of more general use.
#Files: 
# <a href="metal_environment.vmd">metal_environment.vmd</a>
#See also:
# The VMD User's manual
#Author: 
# Andrew Dalke &lt;dalke@ks.uiuc.edu&gt;
#\VMD  --- end of block

# adds the given (floating point) value to the value
# if the value doesn't exist, sets it to 0
# This procedure is used because "incr" fails if the variable doesn't exist
proc myincr {var val} {
  regexp {^[^(]*} $var prefix
  global $prefix
  if {![info exists $var]} {
    set $var 0
  }
  set $var [eval "expr \$$var + $val"]
}

# given the atom index, find the ions within the given distance
# return 
proc find_nearby_residues {index ion distance} {
  set nearby [atomselect top "(within $distance of index $index) \
			and not index $index"]
 
 # I need to count each residue once, but I need to distinguish
 # two successive residues, so using just the residue name is not
 # enough.  "resname residue" is unique and, since atoms on the
 # same residue have successive indicies, the luniq gets just one
 # of them.
 foreach res_pair [lsort -unique [$nearby get {resname residue}]] {
   lassign $res_pair resname
   myincr count($ion,$distance,$resname) 1
 }
}


proc analyze_ion_propensity {pdblist metals} {
  global count
  # get each of the entries from the list of PDB files
  foreach entry $pdblist {
    # load them from the PDB ftp site
    mol pdbload $entry
    # go through the search list of metal names
    foreach ion $metals {
      set sel [atomselect top "name $ion and numbonds == 0"]
      foreach atom [$sel list] {
        # find neighbors for each of the test ranges
        find_nearby_residues $atom $ion 3
        find_nearby_residues $atom $ion 5
        find_nearby_residues $atom $ion 7
      }
      # save memory space by forcing the deletion of the 
      # temporary selection.  (Otherwise they wouldn't be purged
      # until the end of the procedure.)
      $sel delete
    }
    mol delete top
  }
  # the array ``count'' contains the data in the form
  # (ion name,distance,residue name)
  # For now just print the values for the normal residues within
  # 7A of a Zn.  Use a histogram of '*'
  set resnames {ALA ARG ASN ASP CYS GLN GLU GLY HIS ILE LEU LYS MET \
          PHE PRO SER THR TRP TYR VAL}
  foreach resname $resnames {
    puts -nonewline "$resname :"
    myincr count(ZN,7,$resname) 0
    for {set strcnt 0} {$strcnt < $count(ZN,7,$resname)} {incr strcnt 1} {
      puts -nonewline "*";
    }
    puts "";
  }
}
