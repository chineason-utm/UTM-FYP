#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 24 #--ntasks-per-node 1 (debug) --ntasks-per-node 24 (cpu) --ntasks-per-node 16 (gpu)
#SBATCH --job-name=fgckp
#SBATCH --mail-type=ALL
#SBATCH --mail-user=chineason@graduate.utm.my

echo "k-points convergence"
#!/bin/bash
# Convergence test of k-points grid.
# Set a variable k-point from 3 to 21.
for k in 3 4 6 9 12 15 18 21; do
# Make input file for the SCF calculation.
# k-points grid is assigned by variable n.
cat > kpoint.$k.in << EOF
&CONTROL
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
ecutwfc      = 500
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
${k} ${k} 1 0 0 0
EOF
# Run pw.x for SCF calculation.
mpirun -np 24 -hostfile hostfile /home/software/qe-7.1/bin/pw.x -npool 6 -in kpoint.$k.in>kpoint.$k.out
# Write the number of k-points and
# the total energy in calc-kpoint.dat
awk '/!/ {printf"%d %s\n",'$k',$5}' kpoint.$k.out >> calc-kpoint.dat
# End of for loop.
done

tar czvf /home/ext_chineason_graduate_utm_my/fgc/convk.tar.gz ./
