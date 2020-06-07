rm measurements
rm slurm*
rm core*

# Set simulation size
sed -i "s/nx=.*$/nx=1024/g" ../Input/input.nml;
sed -i "s/ny=.*$/ny=1024/g" ../Input/input.nml;
sed -i  's/job-name=.*"/job-name="hybrid_test" /g' job.sh;

# Iterate over processors counts
for j in 1 2 4 8 16; do 
    sed -i  "s/nodes=.*$/nodes=$j/g" job.sh;
    for i in 1 2 4 8 16 32 36; do
        sed -i  "s/cpus-per-task.*$/cpus-per-task=$j/g" job.sh;
        sbatch job.sh
    done
done
