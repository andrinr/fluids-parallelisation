import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from scipy.io import FortranFile
import matplotlib
import os.path
from matplotlib.ticker import ScalarFormatter

path_to_output = "measurements"

measurements = []

nsproc = [1, 2, 4, 8, 16, 32]

# read measurement data
with FortranFile(path_to_output, 'r') as f:
    for nproc in nsproc: 
        measurements.append(f.read_reals('f4')[0])
        nproc = f.read_ints('i')
        print(nproc)

    

#fig, ax = plt.subplots()
#
#sns.lineplot(ax=ax, x=nsproc, y=strong_scaling_speedup, markers=True, palette=sns.cubehelix_palette(len(sizes)))
#
#ax.set_title("Speedup plot with MPI \n compared to ideal speed up (dashed)")
#
#ax.set(xlabel='Number of nodes')
#ax.set(ylabel='Speedup')
#plt.yscale('log', basey=2)
#plt.xscale('log', basex=2)
#
#plt.plot(strong_scaling_ideal,nsproc, color='black', ls='--')
#plt.show()
#