rm measurements
# Weak scaling

# Enables running the programm dynamicially, improves speed
#salloc --account=uzh8 --partition=normal --constraint=mc --ntasks=36 --time=00:20:00

for i in 64 128 256 512 1024 2048 4096; do
    sed -i "s/nx=.*$/nx=$i/g" ../Input/input.nml;
    sed -i "s/ny=.*$/ny=$i/g" ../Input/input.nml;
    for j in 36; do 
        srun ../Bin/hydro
    done
done
