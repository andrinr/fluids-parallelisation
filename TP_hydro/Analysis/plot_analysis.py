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
popt_weak, pcov_weak = curve_fit(gustav, nsproc, weak_speedup, bounds=(0.01,1))

print(popt_strong)
print(popt_weak)

for j in range(len(nsproc)):
    strong_ideal_seepdup.append(amdahl(nsproc[j],popt_strong[0]))
    weak_ideal_speedup.append(amdahl(nsproc[j],popt_weak[0]))

print(strong_ideal_seepdup)
print(weak_ideal_speedup)


##### VISUALIZE STRONG RESULT #####

fig, ax = plt.subplots()

sns.lineplot(ax=ax, x=nsproc, y=strong_speedup, markers=True, palette=sns.cubehelix_palette(len(nsproc)))

ax.set_title("Speedup plot with MPI \n compared to ideal speed up (dashed)")

ax.set(xlabel='Number of nodes')
ax.set(ylabel='Speedup')
plt.yscale('log', basey=2)
plt.xscale('log', basex=2)

plt.plot(nsproc, strong_ideal_seepdup, color='black', ls='--')
plt.show()
