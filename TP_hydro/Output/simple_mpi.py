#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from scipy.io import FortranFile
import matplotlib
matplotlib.use("Agg")

Writer = animation.writers['FFmpeg']
writer = Writer(fps=15, metadata=dict(artist='Me'), bitrate=1800)

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
    grid = []
    for j in range(nproc):
        list = []
        for k in range(nproc):
            list.append(0)
        grid.append(list)

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

            grid[coordx][coordy] = dat

    cols = []

    for col in grid[0:dimx]:
        print(np.shape(col[0:dimy]))
        cols.append(np.concatenate(np.flip(col[0:dimy],0),1))

    im = ax.imshow((np.concatenate(cols,2)[0, :, :]).T, interpolation='nearest', origin='lower')
    ims.append([im])

ani.save('im.mp4', writer=writer)


ani = animation.ArtistAnimation(fig,ims,interval=50,blit=True,repeat_delay=0)
print(len(ims))
plt.show()
