# README #

This is the mpi version of the hydro project. 

Pretty much all the magic happens inside the ``hydro_mpi`` module. 

## Main functions

- The function ``init_mpi`` initializes a 2D cartesian grid which makes sure processors are aware of their neighbours and know their slabsize.
- The function ``init_surround`` defines the mpi subarray types which allows to send 2D array between different processors. This is neceassary since we are splitting the full domain in two axes, therefore we cannot only send columns (fortran is column major).
- The function ``get_surround`` fetches the surrounding cells from other processors along the defined axis. 

## Speedup plots