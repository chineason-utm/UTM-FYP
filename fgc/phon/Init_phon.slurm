#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 24 #--ntasks-per-node 1 (debug) --ntasks-per-node 36 (cpu) --ntasks-per-node 16 (gpu) 
#SBATCH --job-name=fgcPHON

scontrol show hostnames ${SLURM_JOB_NODELIST} > hostfile
. /home/ext_chineason_graduate_utm_my/fgc/env_var

# clean TMP_DIR
echo "  cleaning $TMP_DIR...\c"
rm -rf $TMP_DIR/fgc*
rm -rf $TMP_DIR/_ph0/fgc*
for q in `seq 1 12 ` ; do
for irr in `seq 1 12` ; do
rm -rf $TMP_DIR/$q.$irr
done
done
echo " done"

# initial scf run with dense k-grid
echo "  calculating scf ...\c"
mpirun -np 24 -hostfile hostfile /home/software/qe-7.1/bin/pw.x -npool 6 -bgrp 6 -in scf.in > scf.out

# initial ph run with start_irr and last_irr = 0
cat > ph0.in <<EOF
&INPUTPH
tr2_ph = 1d-12
prefix = 'fgc'
ldisp  = .true.
verbosity = 'high' 
start_irr = 0
last_irr  = 0
nq1    = 9
nq2    = 9
nq3    = 1
outdir = '$TMP_DIR/'
fildyn = 'fgc.dyn'
/
EOF

echo "  initialising phonon run ...\c"
mpirun -np 24 -hostfile hostfile /home/software/qe-7.1/bin/ph.x -npool 6 -bgrp 6 -in ph0.in > ph0.out

echo "  generating 144 separate tasks ...\c"
for q in `seq 1 12` ; do
for irr in `seq 1 12` ; do

cat > input.$q.$irr << EOF
&INPUTPH
tr2_ph = 1d-12
prefix = 'fgc'
ldisp  = .true.
verbosity = 'high'
start_q = $q
last_q  = $q
start_irr = $irr
last_irr  = $irr
recover = .true.
nq1    = 9
nq2    = 9
nq3    = 1
outdir = '$TMP_DIR/$q.$irr'
fildyn = 'fgc.dyn'
/
EOF

cat > $q.$irr.slurm << EOF
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 8 #--ntasks-per-node 1 (debug) --ntasks-per-node 36 (cpu) --ntasks-per-node 16 (gpu) 
#SBATCH --job-name=$q-$irr

scontrol show hostnames \${SLURM_JOB_NODELIST} > $q.$irr.hostfile

mpirun -np 8 -hostfile $q.$irr.hostfile /home/software/qe-7.1/bin/ph.x -npool 1 -bgrp 4 -in input.$q.$irr > output.$q.$irr
EOF

mkdir $TMP_DIR/$q.$irr
cp -r $TMP_DIR/fgc.* $TMP_DIR/$q.$irr
mkdir -p $TMP_DIR/$q.$irr/_ph0/fgc.phsave
cp -r $TMP_DIR/_ph0/fgc.phsave/* $TMP_DIR/$q.$irr/_ph0/fgc.phsave

echo "    queue calculation for q= "$q" irr= "$irr "...\c"
sbatch $q.$irr.slurm

done
done
