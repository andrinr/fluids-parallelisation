rm measurements

# Strong scaling

# Set simulation size
sed -i "s/nx=.*$/nx=1024/g" ../Input/input.nml;
sed -i "s/ny=.*$/ny=1024/g" ../Input/input.nml;
sed -i  's/job-name=.*"/job-name="strong_scaling_test" /g' job.sh;

# Iterate over processors counts
for j in 1 2 4 8 16 32; do 
    sed -i  "s/nodes=.*$/nodes=$j/g" job.sh;
    sbatch job.sh
done

sed -i  's/job-name=.*"/job-name="weak_scaling_test" /g' job.sh;
sed -i  "s/nodes=.*$/nodes=8/g" job.sh;

for i in 128 256 512 1024 2048 4096; do
    sed -i "s/nx=.*$/nx=$i/g" ../Input/input.nml;
    sed -i "s/ny=.*$/ny=$i/g" ../Input/input.nml;
    sbatch job.sh
done