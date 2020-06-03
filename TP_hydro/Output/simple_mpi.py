#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
from scipy.io import FortranFile
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("file", help="enter filename output_00025")
args = parser.parse_args()
print("Reading "+args.file)

nproc = 4

totalx = 100
totaly = 150
total = []

for i in range(nproc):
    list = []

    for j in range(nproc):
        list.append(None)

    total.append(list)

# path the the file
dimx = 0
dimy = 0

for x in range(nproc):
    if (x / 10 < 1):
        path_to_output = args.file+".0000" + str(x)
    else:
        path_to_output = args.file+".000" + str(x)


    # read image data
    with FortranFile(path_to_output, 'r') as f:
        t, gamma = f.read_reals('f4')
        nx, ny, nvar, nstep, coordx, coordy, dimx, dimy = f.read_ints('i')
        dat = f.read_reals('f4')

        # reshape the output
        dat = np.array(dat)
        dat = dat.reshape(nvar, ny, nx)
        # plot the map

        total[coordx][coordy] = dat

print(total)
cols = []
final = []

for col in total:
    cols.append(np.concatenate(col[0:dimx],0))


print(cols)
total = np.concatenate(cols,1)


my_dpi = 96
fig, ax = plt.subplots(figsize=(800/my_dpi, 200/my_dpi), dpi=my_dpi)
ax.imshow(total[0, :, :].T, interpolation='nearest', origin='lower')
ax.set_xlabel("ny")
ax.set_ylabel("nx")
plt.show()
