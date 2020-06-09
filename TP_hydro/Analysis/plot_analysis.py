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
    
    for nproc in nsproc: 
        raw_timings.append(f.read_reals('f4')[0])
        raw_order.append(f.read_ints('i')[0])

raw_order = np.array(raw_order)
raw_timings = np.array(raw_timings)
sort_indices = np.argsort(raw_order)

strong_timings = raw_timings[sort_indices][0:6]
weak_timings = raw_timings[sort_indices][6:12]

print(strong_timings)
print(weak_timings)


##### PREPROCESS DATA #####
strong_speedup = []
weak_speedup = []

for j in range(len(nsproc)):
    strong_speedup.append( strong_timings[0] / strong_timings[j] )
    weak_speedup.append( weak_timings[0] / weak_timings[j] * nsproc[j])

print(strong_speedup)
print(weak_speedup)


##### FIT IDEAL SPEEDUP CURVES #####

strong_ideal_seepdup = []
weak_ideal_speedup = []

def amdahl(x, p):
    return( 1 / ((1-p) + p / x) )

def gustav(x, p):
    return( (1-p) + p * x )

popt_strong, pcov_strong = curve_fit(amdahl, nsproc, strong_speedup, bounds=(0.01,1))
popt_weak, pcov_weak = curve_fit(gustav, nsproc, weak_speedup, bounds=(0,1))

print(popt_strong)
print(popt_weak)

for j in range(len(nsproc)):
    strong_ideal_seepdup.append(amdahl(nsproc[j],popt_strong[0]))
    weak_ideal_speedup.append(gustav(nsproc[j],0.6))

print(strong_ideal_seepdup)
print(weak_ideal_speedup)


##### VISUALIZE STRONG RESULT #####

fig, axs = plt.subplots(1,2)
fig.suptitle("Measured scaling compared to fitted ideal scaling (dashed)")
axs[0].set_yscale('log', basey=2)
axs[0].set_xscale('log', basex=2)

sns.lineplot(ax=axs[0], x=nsproc, y=strong_speedup, markers=True, palette=sns.cubehelix_palette(len(nsproc)))
axs[0].plot(nsproc, strong_ideal_seepdup, color='black', ls='--')
axs[0].set_title("Strong scaling")

#axs[0].set(xlabel='Number of nodes')
axs[0].set(ylabel='Speedup')



##### VISUALIZE WEAK RESULT #####

sns.lineplot(ax=axs[1], x=nsproc, y=weak_speedup, markers=True, palette=sns.cubehelix_palette(len(nsproc)))
axs[1].plot(nsproc, weak_ideal_speedup, color='black', ls='--')
axs[1].set_title("Weak scaling")

axs[1].set(xlabel='Number of nodes')
axs[1].set(ylabel='Scaled speedup')
axs[1].set_yscale('log', basey=2)
axs[1].set_xscale('log', basex=2)
plt.show()
