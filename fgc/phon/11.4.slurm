#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 8 #--ntasks-per-node 1 (debug) --ntasks-per-node 36 (cpu) --ntasks-per-node 16 (gpu) 
#SBATCH --job-name=11-4

scontrol show hostnames ${SLURM_JOB_NODELIST} > 11.4.hostfile

mpirun -np 8 -hostfile 11.4.hostfile /home/software/qe-7.1/bin/ph.x -npool 1 -bgrp 4 -in input.11.4 > output.11.4
