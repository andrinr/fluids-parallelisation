# Remove old data
rm measurements
rm slurm*
rm core*


##### Strong scaling #####
# Only increase number of processors, keep problem size fixed 

# Limit number of iterations
sed -i '6 i\nstepmax=10' ../Input/input.nml;

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

# Add wait statement to job script
sed -i '11 i\#SBATCH --wait' analysis.job.sh;

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


# Remove wait statement from job script
sed -i '11d' analysis.job.sh;
# Remove iteration limit from input file
sed -i '6d' ../Input/input.nml;