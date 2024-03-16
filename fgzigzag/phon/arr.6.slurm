#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 8 #--ntasks-per-node 1 (debug) --ntasks-per-node 36 (cpu) --ntasks-per-node 16 (gpu) 
#SBATCH --job-name=arr6
#SBATCH --array=1-24%1

ID=$SLURM_ARRAY_TASK_ID
scontrol show hostnames ${SLURM_JOB_NODELIST} > 6.$ID.hostfile

mkdir /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/6.$ID
cp -r /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/fgz.* /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/6.$ID
mkdir -p /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/6.$ID/_ph0/fgz.phsave
cp -r /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/_ph0/fgz.phsave/* /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/6.$ID/_ph0/fgz.phsave

mpirun -np 8 -hostfile 6.$ID.hostfile /home/software/qe-7.1/bin/ph.x -nk 4 -in input.6.$ID > output.6.$ID
rm -rvf /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/6.$ID/fgz.save /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/6.$ID/fgz.wfc* /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/6.$ID/_ph0/fgz.wfc*
