# HYDRO | OpenMP

This is the OpenMP version of the hydro project.

## Compile & Run

Run make from the /Bin folder in order to compile the project. 

## Visualize

Execute the render_sequence.py script from the ``/Output`` folder. e.g. ``python render_sequence.py``


## Speedup
![Alt text](TP_hydro/Analysis/scaling_openmp.svg)

The ideal speed-up for the strong scaling was calculated using Amdahl's law and a coefficient for p = 0.85, for the weak scaling Gustafson's law with a coefficient of p=0.6 was used. The node has 36 processors, which explains the sharp drop after 

### Reproduce measurements

1. Set ``ptest = .TRUE.`` in ``hydro_commun``
2. Run ``make`` from the ``Bin`` directory
3. Run ``Analysis/analysis.sh`` (only works for slurm environments)
4. Run ``python plot_analysis.py`` inside the ``Analysis`` directory