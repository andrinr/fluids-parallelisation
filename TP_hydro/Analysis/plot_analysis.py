import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from scipy.io import FortranFile
import matplotlib
import os.path
from matplotlib.ticker import ScalarFormatter

path_to_output = "measurements"

strong_scaling_measured = []
strong_scaling_ideal = []
strong_scaling_speedup = []

weak_scalings_measured = []
weak_scalings_ideal = []
weak_scaling_speedup = []

nsproc = [1, 2, 4, 8, 16, 32]
sizes = [128, 256, 512, 1024, 2048, 4096]

# read measurement data
with FortranFile(path_to_output, 'r') as f:
    for nproc in nsproc: 
        strong_scaling_measured.append(f.read_reals('f4')[0])
        nx, ny, nproc = f.read_ints('i')
        print(nproc)

    for size in sizes: 
        weak_scalings_measured.append(f.read_reals('f4')[0])
        nx, ny, nproc = f.read_ints('i')
    
print(strong_scaling_measured)
print(weak_scalings_measured)

for j in range(len(strong_scaling_measured)):
    strong_scaling_speedup.append(strong_scaling_measured[0]/strong_scaling_measured[j])

for j in range(len(nsproc)):
    strong_scaling_ideal.append(1 / (1/nsproc[j]))

fig, ax = plt.subplots()

sns.lineplot(ax=ax, x=nsproc, y=strong_scaling_speedup, markers=True, palette=sns.cubehelix_palette(len(sizes)))

ax.set_title("Speedup plot with MPI \n compared to ideal speed up (dashed)")

ax.set(xlabel='Number of nodes')
ax.set(ylabel='Speedup')
plt.yscale('log', basey=2)
plt.xscale('log', basex=2)

plt.plot(strong_scaling_ideal,nsproc, color='black', ls='--')
plt.show()
