#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 24 #--ntasks-per-node 1 (debug) --ntasks-per-node 36 (cpu) --ntasks-per-node 16 (gpu) 
#SBATCH --job-name=endPHON

scontrol show hostnames ${SLURM_JOB_NODELIST} > hostfile
. /home/ext_chineason_graduate_utm_my/fgc/env_var

#
#  Collecting all results in a single directory:
#

#for q in `seq 1 12 ` ; do

#for irr in `seq 1 12` ; do

#\cp -f $TMP_DIR/$q.$irr/_ph0/fgc.phsave/dynmat.$q.$irr.xml $TMP_DIR/_ph0/fgc.phsave 2> /dev/null

#done
#
#  collect also the representation 0 (contribution to the dynamical
#  matrix independent from the induced charge).
#
#\cp -f $TMP_DIR/$q.1/_ph0/fgc.phsave/dynmat.$q.0.xml $TMP_DIR/_ph0/fgc.phsave 2> /dev/null

#done
#
# cp electric field part
#
#\cp -f $TMP_DIR/1.1/_ph0/fgc.phsave/tensors.xml $TMP_DIR/_ph0/fgc.phsave

cat > ph.in << EOF
 &inputph
  tr2_ph=1.0d-12,
  prefix='fgc',
  ldisp=.true.,
  nq1=9, nq2=9, nq3=1
  recover=.true.,
  outdir='$TMP_DIR/',
  fildyn='fgc.dyn'
 /
EOF

echo "  collecting phonon results ...\c"
mpirun -np 24 -hostfile hostfile /home/software/qe-7.1/bin/ph.x -npool 6 -bgrp 6 -in ph.in > ph.out
echo "  done"

cat > q2r.in <<EOF
 &INPUT
fildyn = 'fgc.dyn'
zasr   = 'crystal'
flfrc  = 'fgc.fc'
loto_2d = .true.
/
EOF

echo "  calculating q2r ...\c"
mpirun -np 24 -hostfile hostfile /home/software/qe-7.1/bin/q2r.x -in q2r.in > q2r.out
echo "  done"

cat > matdyn.in <<EOF
 &INPUT
asr            = 'crystal'
flfrc          = 'fgc.fc'
flfrq          = 'fgc.freq'
flvec          = 'fgc.modes'
loto_2d        = .true.
q_in_band_form = .true.
/
4
gG 50
K  30
M  40
gG 1
EOF

echo "  calculating omega(q) ...\c"
mpirun -np 24 -hostfile hostfile /home/software/qe-7.1/bin/matdyn.x -in matdyn.in > matdyn.out
echo "  done"

cat > phdos.in <<EOF
 &input
    asr='crystal',  dos=.true. 
	loto_2d = .true.
    flfrc='fgc.fc', fldos='fgc.phdos', nk1=18,nk2=18,nk3=1
 /
EOF

echo "  calculating phonon DOS ...\c"
mpirun -np 24 -hostfile hostfile /home/software/qe-7.1/bin/matdyn.x -in phdos.in > phdos.out
echo "  done"

tar czvf /home/ext_chineason_graduate_utm_my/fgc/phon.tar *.slurm input.* output.* fgc.* *.in *.out
