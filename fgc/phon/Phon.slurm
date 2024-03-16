#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 24 #--ntasks-per-node 1 (debug) --ntasks-per-node 36 (cpu) --ntasks-per-node 16 (gpu) 
#SBATCH --job-name=fgcPHON

mpirun -np 24 -hostfile hostfile /home/software/qe-7.1/bin/pw.x -npool 6 -bgrp 3 -in scf.in > scf.out
mpirun -np 24 -hostfile hostfile /home/software/qe-7.1/bin/ph.x -npool 6 -bgrp 3 -in ph.in > ph.out
#mpirun -np 4 -hostfile hostfile /home/software/qe-7.1/bin/q2r.x -in q2r.in > q2r.out
#mpirun -np 4 -hostfile hostfile /home/software/qe-7.1/bin/matdyn.x -in matdyn.in > matdyn.out

#tar czvf /home/ext_chineason_graduate_utm_my/fgc/phon.tar ./
