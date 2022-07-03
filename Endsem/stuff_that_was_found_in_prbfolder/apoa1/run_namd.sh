#!/bin/bash

#PBS -A youracct
#PBS -N test
#PBS -q debug
#PBS -j oe
#PBS -l walltime=0:30:00
#PBS -l nodes=100

module load namd/2.12
which namd2


export MPICH_PTL_SEND_CREDITS=-1
export MPICH_MAX_SHORT_MSG_SIZE=8000
export MPICH_PTL_UNEX_EVENTS=80000
export MPICH_UNEX_BUFFER_SIZE=100M


NPROC=$((PBS_NUM_NODES))

cd $PBS_O_WORKDIR

aprun -n $NPROC -N 1 -d 8 namd2 ++ppn 7 +setcpuaffinity \
                                +pemap 0,2,4,6,8,10,12 +commap 14 +idlepoll +devices 0 \
                                apoa1.namd >& apoa1_test.log
