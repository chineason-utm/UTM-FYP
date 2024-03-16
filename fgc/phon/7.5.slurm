#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 8 #--ntasks-per-node 1 (debug) --ntasks-per-node 36 (cpu) --ntasks-per-node 16 (gpu) 
#SBATCH --job-name=7-5

scontrol show hostnames ${SLURM_JOB_NODELIST} > 7.5.hostfile

mpirun -np 8 -hostfile 7.5.hostfile /home/software/qe-7.1/bin/ph.x -npool 1 -bgrp 4 -in input.7.5 > output.7.5
