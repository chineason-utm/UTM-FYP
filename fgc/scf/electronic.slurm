#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 24 #--ntasks-per-node 1 (debug) --ntasks-per-node 24 (cpu) --ntasks-per-node 16 (gpu) 
#SBATCH --job-name=fgcSCF

# Run SCF calculation.
mpirun -np 24 -hostfile hostfile /home/software/qe-7.1/bin/pw.x -npool 6 -in scf.in> scf.out

# Run nscf to get all bands information.
mpirun -np 24 -hostfile hostfile /home/software/qe-7.1/bin/pw.x -npool 6 -in nscf.in> nscf.out

# bands.x outputs band.dat.gnu for gnuplot 
mpirun -np 8 -hostfile hostfile /home/software/qe-7.1/bin/bands.x -in band.in> band.out

# dos.x processes nscf data and calculate edos
mpirun -np 8 -hostfile hostfile /home/software/qe-7.1/bin/dos.x -in dos.in> dos.out

# pdos with projwfc.x
mpirun -np 8 -hostfile hostfile /home/software/qe-7.1/bin/projwfc.x -in pdos.in> pdos.out

rm *rap
tar czvf /home/ext_chineason_graduate_utm_my/fgc/scf.tar.gz ./
