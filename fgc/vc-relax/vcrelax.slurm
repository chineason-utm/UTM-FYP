#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 24 #--ntasks-per-node 1 (debug) --ntasks-per-node 24 (cpu) --ntasks-per-node 16 (gpu)
#SBATCH --job-name=fgcVC
#SBATCH --mail-type=ALL
#SBATCH --mail-user=chineason@graduate.utm.my

echo "vc-relaxation"
mpirun -np 24 -hostfile hostfile /home/software/qe-7.1/bin/pw.x -npool 6 -in vc-relax.in > vc-relax.out
grep -A 9 PARAMETERS vc-relax.out | cat >> report.txt
tar czvf /home/ext_chineason_graduate_utm_my/fgc/vc-relax.tar.gz ./
