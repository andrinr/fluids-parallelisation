#!/usr/bin/env python3

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import  LogNorm
from scipy.io import FortranFile

# path the the file
path_to_output = "poisson_solver/Output/output_00040.00000"
path_to_exact  = "poisson_solver/Output/exact_solution"


# read image data
with FortranFile(path_to_output, 'r') as f:
    nstep, diff, error = f.read_reals('f4')
    nx, ny = f.read_ints('i')
    dat = f.read_reals('f4')

with FortranFile(path_to_exact, 'r') as f:
    nx, ny = f.read_ints('i')
    exact = f.read_reals('f4')


# reshape the output
dat = np.array(dat)
dat = dat.reshape(ny, nx)

# reshape the exact solution
exact = np.array(exact)
exact = exact.reshape(ny, nx)

vmin = np.min(exact)
vmax = np.max(exact)

error = np.abs(exact-dat)

# plot the map
fig, ax = plt.subplots(1,3, figsize=(10,3), sharex=True)
fig.subplots_adjust(left=0.02, bottom=0.06, right=0.95, top=0.94, wspace=0.05)


im1 = ax[0].imshow(exact[1:-1, 1:-1].T, vmin=vmin, vmax=vmax, origin='lower')
im2 = ax[1].imshow(  dat[1:-1, 1:-1].T, vmin=vmin, vmax=vmax, origin='lower')
im3 = ax[2].imshow(error[1:-1, 1:-1].T, origin='lower', norm=LogNorm(), vmin=1e-8)

ax[0].set_xlabel("ny")
ax[1].set_xlabel("ny")
ax[2].set_xlabel("ny")

ax[0].set_ylabel("nx")

ax[0].set_title("Exact Solution")
ax[1].set_title("Approx. Solution".format(nstep))
ax[2].set_title("Error".format(nstep))

fig.colorbar(im1, ax=ax[0])
fig.colorbar(im2, ax=ax[1])
fig.colorbar(im3, ax=ax[2])

plt.tight_layout()

plt.show()
