# Remove old data
rm measurements
rm slurm*
rm core*


##### Strong scaling #####
# Only increase number of processors, keep problem size fixed 

# Set simulation size
sed -i "s/nx=.*$/nx=1024/g" ../Input/input.nml;
sed -i "s/ny=.*$/ny=1024/g" ../Input/input.nml;
# Set job name
sed -i  's/job-name=.*"/job-name="hybrid_test" /g' analysis.job.sh;

# Iterate over processors counts 
for j in 1 2 4 8 16 32; do 
    # set number of nodes
    sed -i  "s/nodes=.*$/nodes=$j/g" analysis.job.sh;
    # run script
    sbatch analysis.job.sh
done


##### Weak scaling #####
# Increase number of processors and simulation size

sed -i "s/nx=.*$/ny=512/g" ../Input/input.nml;

# Iterate over processors counts 
for j in 1 2 4 8 16 32; do 
    # set nmber of nodes
    sed -i  "s/nodes=.*$/nodes=$j/g" analysis.job.sh;
    # set simualtion size
    declare -i SIZE
    SIZE=$j*128
    sed -i "s/nx=.*$/nx=$SIZE/g" ../Input/input.nml;
    # run script
    sbatch analysis.job.sh
done
