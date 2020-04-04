#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
from scipy.io import FortranFile
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("file", help="enter filename output_00025")
args = parser.parse_args()
print("Reading "+args.file)

# path the the file
path_to_output = "Output/"+args.file+".00000"

# read image data
with FortranFile(path_to_output, 'r') as f:
    t, gamma = f.read_reals('f4')
    nx, ny, nvar, nstep = f.read_ints('i')
    dat = f.read_reals('f4')

# reshape the output
dat = np.array(dat)
dat = dat.reshape(nvar, ny, nx)
# plot the map
my_dpi = 96
fig, ax = plt.subplots(figsize=(800/my_dpi, 200/my_dpi), dpi=my_dpi)

ax.imshow(dat[0, :, :].T, interpolation='nearest', origin='lower')
ax.set_xlabel("ny")
ax.set_ylabel("nx")
plt.show()
