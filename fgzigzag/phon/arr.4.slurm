#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 8 #--ntasks-per-node 1 (debug) --ntasks-per-node 36 (cpu) --ntasks-per-node 16 (gpu) 
#SBATCH --job-name=arr4
#SBATCH --array=1-24%1

ID=$SLURM_ARRAY_TASK_ID
scontrol show hostnames ${SLURM_JOB_NODELIST} > 4.$ID.hostfile

mkdir /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/4.$ID
cp -r /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/fgz.* /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/4.$ID
mkdir -p /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/4.$ID/_ph0/fgz.phsave
cp -r /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/_ph0/fgz.phsave/* /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/4.$ID/_ph0/fgz.phsave
du -sh /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/

mpirun -np 8 -hostfile 4.$ID.hostfile /home/software/qe-7.1/bin/ph.x -nk 4 -in input.4.$ID > output.4.$ID
du -sh /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/
rm -rvf /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/4.$ID/fgz.save /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/4.$ID/fgz.wfc* /home/ext_chineason_graduate_utm_my/fgzigzag/tmp/4.$ID/_ph0/fgz.wfc*
