#!/bin/bash
# Convergence test of cut-off energy.
# Set a variable ecut from 40 to 1600 Ry.
for ecut in 100 200 300 400 500 600 700 800 900 1000 1200 1400 1600; do
# Make input file for the SCF calculation.
# ecutwfc is assigned by variable ecut.
cat > ecut.$ecut.in << EOF
&&CONTROL
calculation  = 'scf'
etot_conv_thr =   5.0000000000d-06
forc_conv_thr =   5.0000000000d-05
restart_mode = 'from_scratch'
pseudo_dir   = '../pseudo/'
outdir       = '../tmp/'
prefix       = 'fgc'
tstress          = .true.
tprnfor          = .true.
verbosity        = 'high'               ! extended output
/
&SYSTEM
ibrav        = 4
a            = 2.605061048
c            = 18.5001714167
nat          = 4
ntyp         = 2
occupations  = 'smearing'
smearing     = 'mv'
degauss      = 0.001
ecutwfc      = ${ecut}
/
&ELECTRONS
mixing_beta  = 0.7
conv_thr     = 1.0D-12
/
ATOMIC_SPECIES
C 12.0107 c_pbe_v1.2.uspp.F.UPF
F 18.9984 f_pbe_v1.4.uspp.F.UPF

ATOMIC_POSITIONS crystal
C         0.8333333330      0.6666666660     -0.0132084794
C         0.1666666660      0.3333333330      0.0132084794
F         0.8333333330      0.6666666660     -0.0877973871
F         0.1666666660      0.3333333330      0.0877973871

K_POINTS (automatic)
9 9 1 0 0 0
EOF
# Run SCF calculation.
mpirun -np 24 -hostfile hostfile /home/software/qe-7.1/bin/pw.x -npool 6 -in ecut.$ecut.in> ecut.$ecut.out
# Write cut-off and total energies in calc-ecut.dat.
awk '/!/ {printf"%d %s\n",'$ecut',$5}' ecut.$ecut.out >> calc-ecut.dat
# End of for loop
done

