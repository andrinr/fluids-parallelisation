# HYDRO | Hybrid

This is the HYBRID version of the hydro project.

## Compile & Run

Run make from the /Bin folder in order to compile the project. Depending on the environment F90 in the makefile needs to be set to F90 = mpifort or F90 = gfortran. When using F90 = mpifort the simulation can be executed with mpirun ./hydro.

## Visualize

Execute the render_sequence.py script from the /Output folder. It will automaticially render all output files and stitch together the outputs from the different processors. The script takes the number of processors as argument. e.g: python simple_mpi.py 4


## Speedup
![Alt text](TP_hydro/Analysis/scaling_hybrid.svg)

The ideal speed-up for the strong scaling was calculated using Amdahl's law and a coefficient for p = 0.4, for the weak scaling Gustafson's law with a coefficient of 0.6 was used. 

### Reproduce measurements

1. Set ``ptest = .TRUE.`` in ``hydro_commun``
2. Run ``make`` from the ``Bin`` directory
3. Run ``Analysis/analysis.sh`` (only works for slurm environments)
4. Run ``python plot_analysis.py`` inside the ``Analysis`` directory