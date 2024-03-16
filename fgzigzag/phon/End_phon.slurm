#!/bin/bash
#SBATCH --nodes=1
#SBATCH --partition=cpu
#SBATCH --ntasks-per-node 8 #--ntasks-per-node 1 (debug) --ntasks-per-node 36 (cpu) --ntasks-per-node 16 (gpu) 
#SBATCH --job-name=endPHON

scontrol show hostnames ${SLURM_JOB_NODELIST} > hostfile
. /home/ext_chineason_graduate_utm_my/fgzigzag/env_var

#
#  Collecting all results in a single directory:
#

for q in `seq 1 16` ; do

for irr in `seq 1 24` ; do

\cp -f $TMP_DIR/$q.$irr/_ph0/fgz.phsave/dynmat.$q.$irr.xml $TMP_DIR/_ph0/fgz.phsave 2> /dev/null

done
#
#  collect also the representation 0 (contribution to the dynamical
#  matrix independent from the induced charge).
#
\cp -f $TMP_DIR/$q.1/_ph0/fgz.phsave/dynmat.$q.0.xml $TMP_DIR/_ph0/fgz.phsave 2> /dev/null

done
#
# cp electric field part
#
#\cp -f $TMP_DIR/1.1/_ph0/fgz.phsave/tensors.xml $TMP_DIR/_ph0/fgz.phsave

cat > ph.in << EOF
 &inputph
  tr2_ph=1.0d-14,
  prefix='fgz',
  ldisp=.true.,
  nq1=7, nq2=7, nq3=1
  recover=.true.,
  outdir='$TMP_DIR/',
  fildyn='fgz.dyn'
 /
EOF

echo "  collecting phonon results ...\c"
mpirun -np 8 -hostfile hostfile /home/software/qe-7.1/bin/ph.x -nk 4 -in ph.in > ph.out
echo "  done"

cat > q2r.in <<EOF
 &INPUT
fildyn = 'fgz.dyn'
zasr   = 'crystal'
flfrc  = 'fgz.fc'
loto_2d = .true.
/
EOF

echo "  calculating q2r ...\c"
mpirun -np 4 -hostfile hostfile /home/software/qe-7.1/bin/q2r.x -in q2r.in > q2r.out
echo "  done"

cat > matdyn.in <<EOF
 &INPUT
asr            = 'crystal'
flfrc          = 'fgz.fc'
flfrq          = 'fgz.freq'
flvec          = 'fgz.modes'
loto_2d        = .true.
q_in_band_form = .true.
/
  5
   0.500000     0.000000     0.000000   50  !X
   0.000000     0.000000     0.000000   30  !G
   0.000000     0.500000     0.000000   50  !Y
   0.500000     0.500000     0.000000   30  !S
   0.500000     0.000000     0.000000   1   !X
EOF

echo "  calculating omega(q) ...\c"
mpirun -np 4 -hostfile hostfile /home/software/qe-7.1/bin/matdyn.x -in matdyn.in > matdyn.out
echo "  done"

cat > phdos.in <<EOF
 &input
    asr='crystal',  dos=.true. 
	loto_2d = .true.
    flfrc='fgz.fc', fldos='fgz.phdos', nk1=21,nk2=21,nk3=1
 /
EOF

echo "  calculating phonon DOS ...\c"
mpirun -np 2 -hostfile hostfile /home/software/qe-7.1/bin/matdyn.x -in phdos.in > phdos.out
echo "  done"

tar -czvf /home/ext_chineason_graduate_utm_my/fgzigzag/phon.tar *.slurm input.* output.* fgz.* *.in *.out matdyn.*
