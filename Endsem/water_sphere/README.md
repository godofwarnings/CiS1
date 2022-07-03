# How to get sphere from solvation

# > Courtesy of Ujjwal

1. Do the usual stuff to the protein.pdb file (autopsf stuff)
2. Open the script and change the first line
```tcl
set molname molecule_name_without_extensions
```
This name is the name of the file that you get after autopsf builder. <br>
3. Open the autopsf files and when solvating them, go to tk console and type
```tcl
source water-sphere.tcl
```
4. Voila! You will get files with name like protein_ws.pdb and protein_ws.psf, where ws stands for water sphere.
