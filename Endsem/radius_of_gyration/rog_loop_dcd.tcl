mol new /home/devanandt/Documents/RAS/1C1Y/DATA/1C1Y/ANALYSIS/fitted_DCD/APO/1C1Y_APO_RAS_200ns_fitted.psf
mol addfile /home/devanandt/Documents/RAS/1C1Y/DATA/1C1Y/ANALYSIS/fitted_DCD/APO/1C1Y_APO_RAS_200ns_fitted.dcd first 0 last -1 step 100 waitfor all

# load necessary tcl functions  (Ref : http://www.ks.uiuc.edu/Research/vmd/vmd-1.7.1/ug/node182.html )
source gyr_radius.tcl
source center_of_mass.tcl

set outfile [open radius_of_gyration.dat w]
puts $outfile "i rad_of_gyr"
set nf [molinfo top get numframes] 
set i 0

set prot [atomselect top "protein"]
while {$i < $nf} {

    $prot frame $i
    $prot update

    set i [expr {$i + 1}]
    set rog [gyr_radius $prot]

    puts $outfile "$i $rog"

} 

close $outfile
exit
