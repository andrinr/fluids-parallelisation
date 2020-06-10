#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from scipy.io import FortranFile
import matplotlib
import argparse
import os.path

# read parameter
parser = argparse.ArgumentParser()
parser.add_argument("nproc", help="number of processors")
args = parser.parse_args()
print("Reading "+args.nproc)
nproc = int(args.nproc)

# init plot
my_dpi = 96
fig, ax = plt.subplots(figsize=(800/my_dpi, 200/my_dpi), dpi=my_dpi)
ax.set_xlabel("ny")
ax.set_ylabel("nx")


# init global variables
dimx = 0
dimy = 0
i = 0
ims = []


grid = []
for j in range(nproc):
    sublist = []
    for k in range(nproc):
        sublist.append(0)

    grid.append(sublist)

maxl = 200
while(i < maxl):

    path_to_output = "output_" + str(i).zfill(5)+"."+str(0).zfill(5)
    if (not os.path.isfile(path_to_output)):
        break

    for x in range(nproc):

        path_to_output = "output_" + str(i).zfill(5)+"."+str(x).zfill(5)
        print(path_to_output)

        # read image data
        with FortranFile(path_to_output, 'r') as f:
            t, gamma = f.read_reals('f4')
            nx, ny, nvar, nstep, coordx, coordy, dimx, dimy = f.read_ints('i')
            dat = f.read_reals('f4')
            # reshape the output
            dat = np.array(dat)
            dat = dat.reshape(nvar, ny, nx)
            grid[coordx][dimy-1-coordy] = dat

    cols = []

    for col in grid[0:dimx]:
        cols.append(np.concatenate(col[0:dimy],1))

    im = ax.imshow((np.concatenate(cols,2)[0, :, :]).T, interpolation='nearest', origin='lower', vmin=0, vmax=5, cmap="inferno")
    ims.append([im])

    i += 5


ani = animation.ArtistAnimation(fig,ims,interval=50,blit=True,repeat_delay=0)

plt.show()
