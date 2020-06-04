rm measurements

for  i in 128 256 512 1024 ; do
      sed -i "s/nx=[0-9][0-9][0-9][0-9]*$/nx=$i/g" ../Input/input.nml;
      sed -i "s/ny=[0-9][0-9][0-9][0-9]*$/ny=$i/g" ../Input/input.nml;
      for j in 1 2 4 8 16 32 64 128 256 512 1024; do 
          export OMP_NUM_THREADS="$j"
          ../Bin/hydro
          #((tim=($i/256)/$j))
          #sleep $tim ;    
      done
done
#128 256 512 1024
#1 4 16 36