#!/bin/bash

# rm -rf files
# rm -rf main

for (( i=1 ; i<=10 ; i++ ))
do
    rm ./main/output_$i/prod.inp
done

rm ./main/prod.inp

cp ./files/parallel_temp/prod.inp ./main/prod.inp

clear
