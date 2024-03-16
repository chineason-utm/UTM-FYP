#!/bin/bash
# Convergence test of k-points grid.
# Set a variable k-point from 3 to 21.
for k in 3 4 6 9 12 15 18 21; do
# Make input file for the SCF calculation.
# k-points grid is assigned by variable n.
cat > kpoint.$k.in << EOF
&CONTROL
calculation  = 'scf'
etot_conv_thr =   1.0000000000d-05
forc_conv_thr =   1.0000000000d-04
restart_mode = 'from_scratch'
pseudo_dir   = '../pseudo/'
outdir       = '../tmp/'
prefix       = 'fgz'
tstress		 = .true.
tprnfor		 = .true.
verbosity	 = 'high'		! extended output
/
&SYSTEM
ibrav        = 0
nat          = 8
ntyp         = 2
occupations  = 'smearing'
smearing     = 'mv'
degauss      = 0.02
ecutwfc      = 700
/
&ELECTRONS
mixing_beta  = 0.7
conv_thr     = 1.0D-8
/
ATOMIC_SPECIES
C 12.0107 c_pbe_v1.2.uspp.F.UPF
F 18.9984 f_pbe_v1.4.uspp.F.UPF

ATOMIC_POSITIONS (crystal)
C             0.5000000000        0.1415439458        0.0349648566
C            -0.0000000000        0.6415439458       -0.0349648566
C            -0.0000000000        0.3584560542        0.0349648566
C             0.5000000000        0.8584560542       -0.0349648566
F             0.5000000000       -0.0060101030       -0.1212880599
F             0.0000000000        0.4939898970        0.1212880599
F            -0.0000000000        0.5060101030       -0.1212880599
F             0.5000000000        0.0060101030        0.1212880599

CELL_PARAMETERS (angstrom)
   2.630136397   0.000000000   0.000000000
   0.000000000   4.192934272   0.000000000
   0.000000000   0.000000000  14.571830239

K_POINTS (automatic)
${k} ${k} 1 0 0 0
EOF
# Run pw.x for SCF calculation.
mpirun -np 50 -hostfile hostfile /home/software/qe-7.1/bin/pw.x -in kpoint.$k.in>kpoint.$k.out
# Write the number of k-points and
# the total energy in calc-kpoint.dat
awk '/!/ {printf"%d %s\n",'$k',$5}' kpoint.$k.out >> calc-kpoint.dat
# End of for loop.
done
#analyse kpoint.dat, get threshold
cat > plotk.gnu << EOF
set term pngcairo lw 1.5
set xrange [0:]
set output "k.png"
plot "calc-kpoint.dat" w p ps 2
unset output 
EOF
#gnuplot plotk.gnu
#git add ./calc-kpoint.dat
#git add ./k.png
#git add ./convk.sh
#git commit -m "Job complete."
#git push
