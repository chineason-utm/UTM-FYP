mpirun -np 4 pw.x < vc-relax.in > vc-relax.out
grep -A 9 PARAMETERS vc-relax.out | cat > report.txt
git add ./report.txt
git add ./vc-relax.in
git add ./vc-relax.out
git commit -m "Job done."
git push
