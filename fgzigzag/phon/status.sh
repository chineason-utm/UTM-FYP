
#! /bin/bash
# Phonon of Graphene
#############################################
grn=`tput setab 2`
yel=`tput setab 3`
rst=`tput sgr 0`
#for irr in `seq 10 24` ; do
#sbatch 2.$irr.slurm
#done

for q in `seq 1 16` ; do
printf "%2s | " "$q"
for irr in `seq 1 24` ; do
if [ ! -f output.$q.$irr ]; then
printf $rst"x "
else if [ `tail -n 2 output.$q.$irr | grep -ic 'JOB DONE.'` -eq 1 ]; then
printf $grn"1 "
else
printf $yel"0 "
fi
fi

if [ $((irr % 5)) -eq 0 ]
then
printf $rst'| '
fi

#sbatch $q.$irr.slurm

#sbatch --nodelist=hpcslurm-cpu-ghpc-3 8.$irr.slurm
#sbatch --nodelist=hpcslurm-cpu-ghpc-3 16.$irr.slurm
done
printf $rst"\n"
done
echo `tail -n 2 output.* | grep -ic JOB`'/384'
du -sh ../tmp/
