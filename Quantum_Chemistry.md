# Computational Chemistry

### _**Tutorial 6**_

> Courtesy of **Anika**, **Bhole** and all the **other people** who wrote stuff in the google doc

### 3 Levels

#### Level 1 <br>
1. Knowing which buttons to press and when to press

HAVE PATIENCE<br>
THINK BEFORE YOU CLICK<br>
IF YOU CLICK<br>   

```bash
ssh -X sc4102.13@abacus.iiit.ac.in

sint4 -c 10
module add Gaussian/09revC
gview

# if core dumped, change core number and try again
```

2. Click on Element Fragments
3. Click on the purple screen to add the molecule
4. Click on add Ring Fragment
5. Clear everthing and add a Methane molecule
6. go to Calculate->Gaussian Calculation setup and just follow the procedure
>.chk checkpoint file<br>
>.log output file<br>
7. Right click on the new output window and click on results

> A hartree is a unit of energy used in molecular orbital calculations. A hartree is equal to 2625.5 kJ/mol, 627.5 kcal/mol, 27.211 eV, and 219474.6 cm<sup>-1</sup>.

>Eg :- methane energy-> -39.97640585 <br>
>&nbsp; &nbsp; &nbsp; eth-> -78.67096855 <br>

>Z matrix:(internal coordinates)<br>
>    ->Length<br>
 >   ->Angle<br>
  >  ->dihedral<br>

### Gaussian
- uses both-cart and internal
- Job type->optimization
- Scan - tells how energy changes with dihedral angle, for example
- Right click>edit>red coord
- change the following 
- - Add > change to dihedral
- - select 4 atoms in a row
- - change to scan
- Ok
- Calc gauss setup

> Class 2)
- Energy
- Optimsizing
- Scan
- Vibrational frequency analysis
- Intrinsic reaction coordinate
- E(RHF)-Spin restricted hartree fock
- Rigid scan - only the chosen collective variable changes
- Relaxed - everything else can change

>### Rigid and Relaxed<br>
>Rigid means you give it a configuration to evaluate over<br>
>Relaxed means that the other bonds can change as they want but the one that you want unchanged does not change. <br>

### Gaussian scan commands:
- right click on the molecul group screen (the purple thing) > edit > redundant coordinate > add
- in add, choose in the drop down table, select any parameter (Dihedral in for example)
- select the atoms in the molecule relevant to the parameter selected
- Now after submit, right click > calculate > Gaussian Calculation set up
- Job type > Scan > Redundant (relaxed)
- Change Job title and save it
- after that, run the file in gaussian > right click > results > scan > plot

MOs
edit>MOs>new Mos>load>visualise>update>choose the mos we want

Gaussian Frequency commands:
> right click > calculate > Gaussian Calculation setup
> Job Type > Frequency
> Change Job title and save
> Run file in Gaussian > right click > results > vibrations 
> spectrum > IR Spectrum graph

## IRC run:
> We can only model S<sub>N</sub>2 in Gaussian

- Additional keywords: opt=noeigentest

### Gaussian IRC run:
-  Create the Transition state (TS) in the file
-  Modify the TS to be close to the optimised nature
-  right click > calculate > Gaussian Calculation Setup
-  JobType = Opt+freq
-  Change charge = (net charge) in Method
-  in Job Type select TS (Berny)
- Select Force Constant = Once
- Write in the text box below :  opt=noeigentest
-  Save
-  Run the file 
-  Create a copy of the new optimized molecule as follows
- - Optimized file -> file -> new -> molecule group
- - Optimized file -> cntrl+C on the blue surface (copied the group of molecules to the grey clipboard)
- Now make other run (on the .log file of optimized file)
- Job type-> IRC -> specify calculate more points -> (say 20)
- Recalculate every -> (say 3)
- Right Click on molecule -> Calculate -> Link 0 ->
- First box (idr the name) -> 1024mb
- Shared processors -> 8
- Open the log file -> look at the animation.

