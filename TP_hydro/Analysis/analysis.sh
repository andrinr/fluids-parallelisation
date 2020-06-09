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
sed -i "s/time=.*$/time=00:02:00 /g" analysis.job.sh;

# Iterate over processors counts 
# 1 - 32
for j in 0 1 2 3 4 5; do 
    sed -i  "s/job-name=.*$/job-name=\"strong-$j\" /g" analysis.job.sh;
    declare -i pow
    pow=$((2**$j))
    echo $pow
    # set number of nodes
    sed -i  "s/ntasks-per-node=.*$/ntasks-per-node=$pow/g" analysis.job.sh;
    # Set job name
    sed -i  "s/srun.*$/srun ..\/Bin\/hydro test.nml $j/g" analysis.job.sh;
    # run script
    sbatch analysis.job.sh
done


##### Weak scaling #####
# Increase number of processors and simulation size

sed -i "s/nx=.*$/nx=1024/g" test.nml;
sed -i "s/time=.*$/time=00:04:00 /g" analysis.job.sh;

# Iterate over processors counts 
# 1 - 32
for j in 0 1 2 3 4 5; do 
    sed -i  "s/job-name=.*$/job-name=\"weak-$j\" /g" analysis.job.sh;
    declare -i pow
    pow=$((2**$j))
    echo $pow
    # copy file
    cp test.nml test_$j.nml
    declare -i JOBID
    JOBID=$j+6
    sed -i  "s/srun.*$/srun ..\/Bin\/hydro test_$j.nml $JOBID/g" analysis.job.sh;
    # set number of nodes
    sed -i  "s/ntasks-per-node=.*$/ntasks-per-node=$pow/g" analysis.job.sh;
    # set simualtion size
    declare -i SIZE
    SIZE=$pow*256
    sed -i "s/ny=.*$/ny=$SIZE/g" test_$j.nml;
    # run script
    sbatch analysis.job.sh
done
