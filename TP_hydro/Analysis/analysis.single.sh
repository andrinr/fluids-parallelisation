# Remove previous files
rm measurements
rm slurm*
rm core*
rm test_*

##### Strong scaling #####
# Only increase number of processors, keep problem size fixed 

# Set simulation size
sed -i "s/nx=.*$/nx=1024/g" test.nml;
sed -i "s/ny=.*$/ny=1024/g" test.nml;

# Iterate over processors counts 
# 1 - 32
for j in 0 1 2 3 4 5; do 
    sed -i  "s/job-name=.*$/job-name=\"single-$j\" /g" analysis.single.job.sh;
    declare -i pow
    pow=$((2**$j))
    echo $pow
    # set number of nodes
    sed -i  "s/ntasks-per-node=.*$/ntasks-per-node=$pow/g" analysis.single.job.sh;
    # Set job name
    sed -i  "s/srun.*$/srun ..\/Bin\/hydro test.nml $j/g" analysis.single.job.sh;
    # run script
    sbatch analysis.single.job.sh
done
