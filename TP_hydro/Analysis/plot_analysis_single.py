# ANDRIN REHMANN
# UZH HPC 2020
# andrinrehman@gmail.com

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from scipy.io import FortranFile
import matplotlib
import os.path
from matplotlib.ticker import ScalarFormatter
from scipy.optimize import curve_fit

path_to_output = "measurements"
nsproc = [1, 2, 4, 8, 16, 32]


##### READ DATA #####
raw_timings = []
raw_order = []

with FortranFile(path_to_output, 'r') as f:
    for nproc in nsproc: 
        raw_timings.append(f.read_reals('f4')[0])
        raw_order.append(f.read_ints('i')[0])

raw_order = np.array(raw_order)
raw_timings = np.array(raw_timings)
sort_indices = np.argsort(raw_order)

strong_timings = raw_timings[sort_indices][0:6]

print(strong_timings)


##### VISUALIZE STRONG RESULT #####

fig, axs = plt.subplots()
fig.suptitle("Single node execution time with MPI")
#axs.set_yscale('log', basey=2)
axs.set_xscale('log', basex=2)

sns.lineplot(ax=axs, x=nsproc, y=strong_timings, markers=True, palette=sns.cubehelix_palette(len(nsproc)))
#axs.set_title("Strong scaling")

axs.set(xlabel='Number of ranks')
axs.set(ylabel='Execution time (s)')

plt.show()
