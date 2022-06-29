#!/bin/bash

# {-12.873000144958496 -14.180999755859375 -12.545999526977539}
# {17.691999435424805 13.520999908447266 24.785999298095703}
# centre = 2.4745631217956543 -0.3732631206512451 6.175095558166504;

# General Comments
# 1.Change the directory path of the NAMD as on your system

# number of replicas
repls=10

# number of production steps when doing the swapping thing.
prodss=10

### DO ONLY ONCE
# number of backup folders
backups=5

mkdir main
mkdir ./main/min

unzip files.zip -d files

cp -a files/parallel_temp/. main/

for ((i = 1; i <= $repls; i++)); do
    mkdir main/output_$i
    mkdir main/output_$i/eq
    for ((j = 0; j <= $prodss; j++)); do
        mkdir main/output_$i/prod_$j
    done

done

### Will contain the information on when did the swapping happen...

for ((i = 1; i <= $prodss; i++)); do
    touch ./main/par_temp_$i.txt
done

touch ./main/energy_values.txt

# # ### END of directory creation

# # ### MAIN STUFF

#### Variables
minimize_steps=10000
steps=20000
temp_step=10
curr_temp=300

# #### Minimization

sed -i "134s/5000/$minimize_steps/g" main/min.inp

/home/radhikesh/Documents/sem2/CiS1/namd/namd2 main/min.inp

# #### Equilibration
sed -i '1s+1bhp_wb.psf+./decaalanine_solvated.psf+g' main/eq.inp
sed -i '2s+1bhp_wb.pdb+./decaalanine_solvated.pdb+g' main/eq.inp
sed -i '13s+min+./min/deca_min+g' main/eq.inp
sed -i "145s/25000000/$steps/g" main/eq.inp
sed -i '5s+eq+./output_0/eq/eq+g' main/eq.inp

pre_temp=$curr_temp

for ((i = 1; i <= $repls; i++)); do
    j=$((i - 1))
    sed -i "5s+./output_$j/eq/eq+./output_$i/eq/eq+g" main/eq.inp
    sed -i "4s/$pre_temp/$curr_temp/g" main/eq.inp
    /home/radhikesh/Documents/sem2/CiS1/namd/namd2 main/eq.inp
    pre_temp=$curr_temp
    ((curr_temp += $temp_step))
done

#### Production

curr_temp=300
pre_temp=$curr_temp

sed -i '1s+decaalanine_solvated.psf+./../decaalanine_solvated.psf+g' main/prod.inp
sed -i '2s+decaalanine_solvated.pdb+./../decaalanine_solvated.pdb+g' main/prod.inp
sed -i '5s+prod+./prod_0/prod+g' main/prod.inp
sed -i '12s+eq+./eq/eq+g' main/prod.inp
sed -i "146s/100000000/$steps/g" main/prod.inp

for ((i = 1; i <= $repls; i++)); do
    sed -i "4s/$pre_temp/$curr_temp/g" main/prod.inp
    pre_temp=$curr_temp
    ((curr_temp += $temp_step))
    cp ./main/prod.inp ./main/output_$i/prod.inp
done

for ((i = 1; i <= $repls; i++)); do
    /home/radhikesh/Documents/sem2/CiS1/namd/namd2 main/output_$i/prod.inp | tee ./main/output_$i/prod_0/energy_out.log
done

for ((i = 1; i <= $backups; i++)); do
    mkdir run_$i
    cp -a main/. run_$i/
done

### Parallel Tempering

## swap function

find_energy() {
    count=$(grep -o ENERGY ./main/output_$1/prod_$2/energy_out.log | wc -l)
    line=$(awk "/ENERGY/{++n; if (n==$count) { print NR; exit}}" ./main/output_$1/prod_$2/energy_out.log)
    temp=$(awk "NR==$line{ print; exit }" ./main/output_$1/prod_$2/energy_out.log)
    value=(${temp})
    energy=${value[11]}
    echo $energy
}

for ((i = 1; i <= $repls; i++)); do
    sed -i "12s+./eq/eq+./../output_$i/prod_0/prod+g" main/output_$i/prod.inp
done

declare -a array
declare -a prev_array

for ((j = 1; j <= $repls; j += 1)); do
    array[$j]=$j
    prev_array[$j]=$j
done

for ((i = 1; i <= $prodss; i++)); do
    
    mod=$((i % 2))
    k=$((i - 1))
    
    if [[ $mod -eq 0 ]]; then
        for ((j = 1; j < $repls; j += 2)); do
            j_temp=$((j + 1))
            
            energy1=$(find_energy $j $k)
            energy2=$(find_energy $j_temp $k)
            
            echo $energy1 " " $energy2 " " >>./main/par_temp_$i.txt
            
            if (( $(echo "$energy1 > $energy2" |bc -l) )); then
                temp=${array[$j]}
                array[$j]=${array[$j_temp]}
                array[$j_temp]=$temp
            fi
        done
    else
        for ((j = 2; j < $repls; j += 2)); do
            j_temp=$((j + 1))
            energy1=$(find_energy $j $k)
            energy2=$(find_energy $j_temp $k)
            
            echo $energy1 " " $energy2 " " >>./main/par_temp_$i.txt
            
            if (( $(echo "$energy1 > $energy2" |bc -l) )); then
                temp=${array[$j]}
                array[$j]=${array[$j_temp]}
                array[$j_temp]=$temp
            fi
        done
    fi
    
    echo ${array[*]} >>./main/par_temp_$i.txt
    
    for ((l = 1; l <= $repls; l++)); do
        sed -i "5s+./prod_$k/prod+./prod_$i/prod+g" main/output_$l/prod.inp
        sed -i "12s+./../output_${prev_array[l]}/prod_$k/prod+./../output_${array[l]}/prod_$k/prod+g" main/output_$l/prod.inp
    done
    
    for ((j = 1; j <= $repls; j += 1)); do
        prev_array[$j]=${array[j]}
    done
    
    for ((j = 1; j <= $repls; j++)); do
        /home/radhikesh/Documents/sem2/CiS1/namd/namd2 main/output_$j/prod.inp | tee ./main/output_$j/prod_$i/energy_out.log
    done
done
# 1. Make Directories
# 2. Minimize
# 3. For Loop over replicas
# 4. For Loop over replicas for production. output to .log file
# 5. Make a function to update energies for all energies

### Will create different txt files and output energy values for all temprature as comma seperated lists, like [1,2,3]
mkdir data

for ((i = 1; i <= $repls; i++)); do
    touch ./data/data_$i
    echo "[" >>./data/data_$i
done

find_energy_2() {
    count=$(grep -o ENERGY ./main/output_$1/prod_$2/energy_out.log | wc -l)
    for ((pp = 11; pp <= $count; pp++)); do
        line=$(awk "/ENERGY/{++n; if (n==$pp) { print NR; exit}}" ./main/output_$1/prod_$2/energy_out.log)
        temp=$(awk "NR==$line{ print; exit }" ./main/output_$1/prod_$2/energy_out.log)
        value=(${temp})
        energy=${value[11]}
        echo $energy"," >>./data/data_$1
    done

}

for ((i = 1; i <= $repls; i++)); do
    for ((j = 0; j <= $prodss; j++)); do
        find_energy_2 $i $j
    done
    echo "]" >>./data/data_$i
done
