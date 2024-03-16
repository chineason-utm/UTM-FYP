#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 8 #--ntasks-per-node 1 (debug) --ntasks-per-node 36 (cpu) --ntasks-per-node 8 (gpu) 
#SBATCH --job-name=arr3
#SBATCH --array=9-24%1

ID=$SLURM_ARRAY_TASK_ID
scontrol show hostnames ${SLURM_JOB_NODELIST} > 3.$ID.hostfile

mkdir /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/3.$ID
cp -r /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/fgz.* /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/3.$ID
mkdir -p /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/3.$ID/_ph0/fgz.phsave
cp -r /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/_ph0/fgz.phsave/* /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/3.$ID/_ph0/fgz.phsave
du -sh /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/

mpirun -np 8 -hostfile 3.$ID.hostfile /home/software/qe-7.1/bin/ph.x -nk 4 -in input.3.$ID > output.3.$ID
du -sh /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/
rm -rvf /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/3.$ID/fgz.save /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/3.$ID/fgz.wfc* /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/3.$ID/_ph0/fgz.wfc*
