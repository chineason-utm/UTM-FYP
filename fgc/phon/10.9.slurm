#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 8 #--ntasks-per-node 1 (debug) --ntasks-per-node 36 (cpu) --ntasks-per-node 16 (gpu) 
#SBATCH --job-name=10-9

scontrol show hostnames ${SLURM_JOB_NODELIST} > 10.9.hostfile

mpirun -np 8 -hostfile 10.9.hostfile /home/software/qe-7.1/bin/ph.x -npool 1 -bgrp 4 -in input.10.9 > output.10.9
