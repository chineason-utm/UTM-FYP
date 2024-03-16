#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 24 #--ntasks-per-node 1 (debug) --ntasks-per-node 36 (cpu) --ntasks-per-node 16 (gpu) 
#SBATCH --job-name=fgzPHON

scontrol show hostnames ${SLURM_JOB_NODELIST} > hostfile
. /home/ext_chineason_graduate_utm_my/fgzigzag/env_var

# clean TMP_DIR
echo "  cleaning $TMP_DIR...\c"
rm -rf $TMP_DIR/fgz*
rm -rf $TMP_DIR/_ph0/fgz*
for q in `seq 1 16 ` ; do
for irr in `seq 1 24` ; do
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
tr2_ph = 1d-14
prefix = 'fgz'
ldisp  = .true.
verbosity = 'high' 
start_irr = 0
last_irr  = 0
nq1    = 7
nq2    = 7
nq3    = 1
outdir = '$TMP_DIR/'
fildyn = 'fgz.dyn'
/
EOF

echo "  initialising phonon run ...\c"
mpirun -np 24 -hostfile hostfile /home/software/qe-7.1/bin/ph.x -npool 4 -bgrp 4 -in ph0.in > ph0.out

echo "  generating 384 separate tasks ...\c"
for q in `seq 1 16` ; do

for irr in `seq 1 24` ; do

cat > input.$q.$irr << EOF
&INPUTPH
tr2_ph = 1d-14
prefix = 'fgz'
ldisp  = .true.
verbosity = 'high'
start_q = $q
last_q  = $q
start_irr = $irr
last_irr  = $irr
recover = .true.
nq1    = 7
nq2    = 7
nq3    = 1
outdir = '$TMP_DIR/$q.$irr'
fildyn = 'fgz.dyn'
/
EOF

cat > $q.$irr.slurm << EOF
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 16 #--ntasks-per-node 1 (debug) --ntasks-per-node 36 (cpu) --ntasks-per-node 16 (gpu) 
#SBATCH --job-name=$q-$irr

scontrol show hostnames \${SLURM_JOB_NODELIST} > $q.$irr.hostfile

mkdir $TMP_DIR/$q.$irr
cp -r $TMP_DIR/fgz.* $TMP_DIR/$q.$irr
mkdir -p $TMP_DIR/$q.$irr/_ph0/fgz.phsave
cp -r $TMP_DIR/_ph0/fgz.phsave/* $TMP_DIR/$q.$irr/_ph0/fgz.phsave

mpirun -np 16 -hostfile $q.$irr.hostfile /home/software/qe-7.1/bin/ph.x -bgrp 4 -in input.$q.$irr > output.$q.$irr
rm -rvf $TMP_DIR/$q.$irr/fgz.save $TMP_DIR/$q.$irr/fgz.wfc* $TMP_DIR/$q.$irr/_ph0/fgz.wfc*
EOF

done
done
sed -i 's/node 16/node 24/' *.1.slurm
sed -i 's/-np 16/-np 24/' *.1.slurm

for q in `seq 1 8` ; do
for irr in `seq 1 24` ; do

sbatch --nodelist=hpcslurm-cpu-ghpc-0 $q.$irr.slurm
sbatch --nodelist=hpcslurm-cpu-ghpc-1 $(($q+8)).$irr.slurm
#sbatch --nodelist=hpcslurm-cpu-ghpc-3 $(($q+16)).$irr.slurm

done
done
