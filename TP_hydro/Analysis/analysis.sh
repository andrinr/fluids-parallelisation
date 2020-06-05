rm measurements

# Strong scaling
for i in 1024; do
    sed -i "s/nx=.*$/nx=$i/g" ../Input/input.nml;
    sed -i "s/ny=.*$/ny=$i/g" ../Input/input.nml;
    for j in 1 2 4 8 16 32 36; do 
        sed -i  's/job-name=.*"/job-name="strong scaling"/g' job.sh;
        sed -i  "s/cpus-per-task=.*$/cpus-per-task=$j/g" job.sh;
        sbatch job.sh
    done
done

#Weak scaling
for i in 64 128 256 512 1024 2048 4096; do
    sed -i "s/nx=.*$/nx=$i/g" ../Input/input.nml;
    sed -i "s/ny=.*$/ny=$i/g" ../Input/input.nml;
    for j in 36; do 
        sed -i  's/job-name=.*"/job-name="weak scaling"/g' job.sh;
        sed -i  "s/cpus-per-task=.*$/cpus-per-task=$j/g" job.sh;
        sbatch job.sh
    done
done
