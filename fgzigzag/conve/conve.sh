#!/bin/bash
# Convergence test of cut-off energy.
# Set a variable ecut from 40 to 1600 Ry.
for ecut in 100 200 300 400 500 600 700 800 900 1000 1200 1400 1600 1800; do
# Make input file for the SCF calculation.
# ecutwfc is assigned by variable ecut.
cat > ecut.$ecut.in << EOF
&CONTROL
calculation  = 'scf'
etot_conv_thr =   1.0000000000d-05
forc_conv_thr =   1.0000000000d-04
restart_mode = 'from_scratch'
pseudo_dir   = '../pseudo/'
outdir       = '../tmp/'
prefix       = 'fgz'
tstress          = .true.
tprnfor          = .true.
!verbosity        = 'high'               ! extended output
/
&SYSTEM
ibrav        = 0
nat          = 8
ntyp         = 2
occupations  = 'smearing'
smearing     = 'mv'
degauss      = 0.02
ecutwfc      = ${ecut}
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
9 9 1 0 0 0
EOF
# Run SCF calculation.
mpirun -np 75 -hostfile hostfile /home/software/qe-7.1/bin/pw.x -in ecut.$ecut.in> ecut.$ecut.out
# Write cut-off and total energies in calc-ecut.dat.
awk '/!/ {printf"%d %s\n",'$ecut',$5}' ecut.$ecut.out >> calc-ecut.dat
# End of for loop
done
#analyse ecut.dat, get threshold
cat > plote.gnu << EOF
set term pngcairo lw 1.5
set xrange [0:]
set output "e.png"
plot "calc-ecut.dat" w p ps 2
unset output 
EOF
#gnuplot plote.gnu
#git add ./calc-ecut.dat
#git add ./e.png
#git add ./conve.sh
#git commit -m "Converge to 1e-4 Ry."
#git push
