#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from scipy.io import FortranFile
import matplotlib
import os.path

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

while(True):
    # check if file exists
    path_to_output = "output_" + str(i).zfill(5)+"."+str(0).zfill(5)
    if (not os.path.isfile(path_to_output)):
        break

    # read image data
    with FortranFile(path_to_output, 'r') as f:
        t, gamma = f.read_reals('f4')
        nx, ny, nvar, nstep = f.read_ints('i')
        dat = f.read_reals('f4')

        # reshape the output
        dat = np.array(dat)
        dat = dat.reshape(nvar, ny, nx)

    # gnerate image plot
    im = ax.imshow((dat[0, :, :]).T, interpolation='nearest', origin='lower', vmin=0, vmax=5, cmap="inferno")
    ims.append([im])

    # increment counter, repeat and search for next file
    i += 1

# generate animation
ani = animation.ArtistAnimation(fig,ims,interval=50,blit=True,repeat_delay=0)

# output animation
plt.show()
