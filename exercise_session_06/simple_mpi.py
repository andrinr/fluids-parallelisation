#!/usr/bin/env python3

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import  LogNorm
from scipy.io import FortranFile
import sys

# path the the file
path_to_output = "poisson_solver/Output/"
path_to_exact  = "poisson_solver/Output/"

_, n, outn = sys.argv

n = int(n)

nx = []
ny = []
nstep = []
diff = []
error = []
exact = []
dat = []

# read image data
for i in np.arange(n):
    path_to_output = "poisson_solver/Output/output_"+str(outn).zfill(5)+"."+str(i).zfill(5)
    path_to_exact = "poisson_solver/Output/exact_solution_"+str(i).zfill(5)

    with FortranFile(path_to_output, 'r') as f:
        nstep_tmp, diff_tmp, error_tmp = f.read_reals('f4')
        nx_tmp, ny_tmp = f.read_ints('i')
        dat_tmp = f.read_reals('f4')
    nstep.append(nstep_tmp)
    diff.append(diff_tmp)
    error.append(error_tmp)
    nx.append(nx_tmp)
    ny.append(ny_tmp)
    dat.append(dat_tmp)

    with FortranFile(path_to_exact, 'r') as f:
        nx_tmp, ny_tmp = f.read_ints('i')
        exact_tmp = f.read_reals('f4')
    exact.append(exact_tmp)

# reshape the output
for i in np.arange(n):
    dat[i] = np.array(dat[i])
    dat[i] = dat[i].reshape(ny[i], nx[i])

    # reshape the exact solution
    exact[i] = np.array(exact[i])
    exact[i] = exact[i].reshape(ny[i], nx[i])

datdat = dat[0]
exactexact = exact[0]
for i in np.arange(1,n):
    datdat = np.concatenate((datdat, dat[i]), axis=1)
    exactexact = np.concatenate((exactexact, exact[i]), axis=1)

dat = datdat
exact = exactexact

vmin = np.min(exact)
vmax = np.max(exact)

error = np.abs(exact-dat)

# plot the map
fig, ax = plt.subplots(1,3, figsize=(10,3), sharex=True)
fig.subplots_adjust(left=0.02, bottom=0.06, right=0.95, top=0.94, wspace=0.05)


im1 = ax[0].imshow(exact[1:-1, 1:-1].T, vmin=vmin, vmax=vmax, origin='lower')
im2 = ax[1].imshow(  dat[1:-1, 1:-1].T, vmin=vmin, vmax=vmax, origin='lower')
im3 = ax[2].imshow(error[1:-1, 1:-1].T, origin='lower', norm=LogNorm())

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
