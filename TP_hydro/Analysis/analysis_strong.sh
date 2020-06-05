rm measurements

# Strong scaling

# Set simulation size
sed -i "s/nx=.*$/nx=1024/g" ../Input/input.nml;
sed -i "s/ny=.*$/ny=1024/g" ../Input/input.nml;

# Iterate over processors counts
for j in 1 2 4 8 16 32 36; do 
    sed -i  's/job-name=.*"/job-name="strong scaling"/g' job.sh;
    sed -i  "s/cpus-per-task=.*$/cpus-per-task=$j/g" job.sh;
    sbatch job.sh
done