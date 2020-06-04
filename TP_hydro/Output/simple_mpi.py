#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from scipy.io import FortranFile
import matplotlib

nproc = 4
totalx = 200
totaly = 200

numframes = 98
# path the the file
dimx = 0
dimy = 0

my_dpi = 96
fig, ax = plt.subplots(figsize=(800/my_dpi, 200/my_dpi), dpi=my_dpi)
ax.set_xlabel("ny")
ax.set_ylabel("nx")

ims = []

for i in range(numframes):


    path_to_output = "output_" + str(i).zfill(5)+"."+str(0).zfill(5)
    print(path_to_output)

    # read image data
    with FortranFile(path_to_output, 'r') as f:
        t, gamma = f.read_reals('f4')
        nx, ny, nvar, nstep = f.read_ints('i')
        dat = f.read_reals('f4')

        # reshape the output
        dat = np.array(dat)
        dat = dat.reshape(nvar, ny, nx)


    im = ax.imshow((dat[0, :, :]).T, interpolation='nearest', origin='lower')
    ims.append([im])

ani = animation.ArtistAnimation(fig,ims,interval=50,blit=True,repeat_delay=0)

plt.show()
