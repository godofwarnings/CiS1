# Computing in Sciences 1

## Molecular Dynamics

<br>

### <b>Tutorial 1</b>

1. Create a new folder.
2. Copy the .pdb file
3. open terminal in the folder and run the command
```bash
vmd filename.pdb
```
4. go to extensions->modelling->automatic psf builder
5. Click one by one on all the 4 buttons in sequence
6. close all the files
7. open the new pdb file
8. load the psf file into the pdb file
9. go to extensions->modelling->solvation box
10. modify box padding to any suitable values like
    5  5  5
    0  0  5
    
  
-> pdb = protien data bank <br>
-> psf - protein structure file <br>
-> pmf = potential mean force<br>

<br>

### <b>Tutorial 2</b>

1. Minimization phase - by calculating in which direction energy decreases.
2. Equilibriation phase - calculate
3. Production phase - 

Process.
1. Open and modify the config file according to your need and then run the command

```bash
/home/radhikesh/Documents/sem2/CiS1/namd/namd2 ubq_wb_eq.conf
```

2. Load .dcd file into vmd.
3. Load .psf file into the .dcd file

<br>

### <b>Tutorial 3</b>
1. Load the .dcd file (made in part2)
2. Load .psf file into the .dcd file
3. Go to extensions->tkconsole

```tcl
#increases the font size
tkcon font courier 17
```



```tcl
set sel [atomselect top protien frame 34]
$sel writepdb test.pdb
$sel writepsf test.psf
```


4. Open test.db and load test.psf into it

5. 
```tcl
set sel1 [atomselect top "resid 1"]

set sel2 [atomselect top "resid 76"]

set con1 [measure center $sel1 weight mass]

set con2 [measure center $sel2 weight mass]

vecdist $con1 $con2

```

6. ssh into abacus
```bash
ssh sc4102.13@abacus.iiit.ac.in
Enter Password:
```

7. Copy the 3 files
first make a directory in the ssh 
```bash
mkdir tut
```

then

```bash
scp test.pdb sc4102.13@abacus.iiit.ac.in:~/tut/test.pdb
scp test.psf sc4102.13@abacus.iiit.ac.in:~/tut/test.psf
scp test_colvars.in sc4102.13@abacus.iiit.ac.in:~/tut/test_colvars.in
scp win0.conf sc4102.13@abacus.iiit.ac.in:~/tut/win0.conf
scp par_all27_prot_lipid.inp sc4102.13@abacus.iiit.ac.in:~/tut/par_all27_prot_lipid.inp

```

8.
```bash
#the ssh server
squeue -u sc4102.13

module add namd/2.12-multicore
```

9. go to the win0.conf and change the output path to something like /run1/center_40
40 is the 

<br>

### Tutorial 4

SSH
1. SSH and SSHD // client server protocol
2. SFTP // Secure file Transfer Protocol
3. Public key / Private key -> More secure way of logging into ssh
4. 
```bash
#Local terminal
cd ~/.ssh
cat known_hosts # lists the nodes
ssh-keygen
scp Public_key_name.pub sc4102.13@abacus.iiit.ac.in:~/tut
# go to home directory
vim .bashrc
#create alias in bashrc file
alias = abacus="ssh sc4102.13@abacus.iiit.ac.in"

source .bashrc

```

```bash
#SSH terminal
ssh sc4102.13@abacus.iiit.ac.in
cd ~/.ssh
touch authorized_keys
# Open vim and copy the contents of public key into authorized_keys
exit

```

### <b>Tutorial 5</b>

#### **Replica Exchange**
->stable states <br>
->metastable states <br>
->REMD : Replica Exchange Molecular Dynamics <br>
->REST : Replica Exchange Solute Tempering <br>

#### **Parellel Tampering**

Also known as Temperature Replica Exchange Molecular Dynamics

1. Start off with same state at several different tempratures
2. We'll switch if Energy of T<sub>1</sub> is greater thean Energy of T<sub>2</sub> where T<sub>1</sub> < T<sub>2</sub>
3. **$$P(T_1)W(T_2) = P(T_2)W(T_1)$$**

##### Topics to study
1. Parallel Tempering
2. Markov chains
3. Metropolis-Hastings Algorithm

<hr style="background-color: white">

### SOME ABACUS SHIT

[Abacus and Ada guide](http://hpc.iiit.ac.in/wiki/index.php/Main_Page)

```bash
# SSH Terminal
sinfo # gives info about nodes

sint4 -c 10 # s interactive 10 cpus

sint4 -c 5 -w node42 # 5cpus on node 42

squeue #

# try cd'ing randomly and you will find it some interesting things...

```

scratch is like some 1.5tb storage which is for nodes.


## <b>WHAM</b>
metafile
1. 3 inputs
   -> path to the trajectry files , center , spring constant <br>
2. For periodic collective variable, use the flag -p
eg:
```bash
wham -p #remaining command here
```
> (For Tutorial Exercise 1, take tolerance = 0.01, padding = 0)
3. wham [P|Ppi|Pval] hist_min hist_max num_bins tol temperature numpad metadatafile freefile [num_MC_trials randSeed]
```bash
wham 12 30 10 0.01 300 0 metafile
```
## <b>TK CONSOLE</b> 

1. Go to TK console
2. 
```tcl
#to wrap a trajectory:
pbc wrap -centersel "protein" -center com -compound residue -all 
```

```tcl
#to write to pdb file:
animate write pdb solvate.pdb
```

```tcl
# remove h-bonds
set decaalinine [atomselect top protein]
$decaalinine writepdb decaalinine2.pdb
```

#### pbc commands
```tcl
#pbc get -now
set every [atomselect top all]
measure minmax $every
measure center $every
```

Some examples
```tcl
# not useful as of now
set sel3 [atomselect top "resid 1 and nitrogen"]
set sel4 [atomselect top "resid 10 and hydrogen"]
set con3 [measure center $sel3 weight mass]
set con4 [measure center $sel4 weight mass]

vecdist $con3 $con4
```

To calculate distance between individual atom. Use index or serial
```tcl
set sel1 [atomselect top "serial 1"]
set sel2 [atomselect top "serial 104"]
set con1 [measure center $sel1 weight mass]
set con2 [measure center $sel2 weight mass]

vecdist $con1 $con2
```

### <b>Bash Scripting</b>
1) TO make folders like run1 run2 ....

```bash
mkdir run{1..8}
```
will make 8 folders


## <b><i>Tutorial Exercise 1</i></b>

### **_Part 1_**

1. Open the pdb file in some text editor (preferrably VSCode).
2. Identify the number of resids and atoms and which atom belongs to which residue.

### **_Part 2_**
1. Download the latest parameter files from [this](http://mackerell.umaryland.edu/charmm_ff.shtml) website
2. Download and extract the zip file.
3. Open the decaalinine.pdb in VMD and do autopsf build on it.
4. Close the current instance of decaalinine.pdb and open the new generated pdb.
5. Load the generated psf file into the pdb.
6. Solvate with max and min paddings, all set to 12. (You can try to change the box size and padding and see what it results in)
7. Close all the files and open the solvate.pdb generated and load solvate.psf into it
8. Run the commands to get max and min of the box and to obtain the origin.
```tcl
set every [atomselect top all]
measure minmax $every
measure center $every
```
Theses values will serve as cell basis vectors in the config file. <br>
For eg:
```tcl
set every [atomselect top all]
measure minmax $every
# OUTPUT = {-14.873000144958496 -16.180999755859375 -14.545999526977539} 
# {19.691999435424805 15 531000137329102 26.82200050354004}
measure center $every
# OUTPUT = 2.4093832969665527 -0.2639060318470001 6.1171875
``` 
The first set of values represent the minimum x,y,z values and the second max x,y,z values.<br>
We "kind of" require the box size so we will just take differences of minimum and maximum values. <br>
So the cell basis vectors will be<br>
| X                                       | Y                                       | Z                                      |
| --------------------------------------- | --------------------------------------- | -------------------------------------- |
| 19.691999435424805 + 14.873000144958496 | 0                                       | 0                                      |
| 0                                       | 15.531000137329102 + 16.180999755859375 | 0                                      |
| 0                                       | 0                                       | 26.82200050354004 + 14.545999526977539 |

Which can be approximated as

| X   | Y   | Z   |
| --- | --- | --- |
| 35  | 0   | 0   |
| 0   | 32  | 0   |
| 0   | 0   | 42  |
