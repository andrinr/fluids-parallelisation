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
strong_timings = []
weak_timings = []

with FortranFile(path_to_output, 'r') as f:
    for nproc in nsproc: 
        strong_timings.append(f.read_reals('f4')[0])
        nproc = f.read_ints('i')
        print(nproc)
    
    for nproc in nsproc: 
        weak_timings.append(f.read_reals('f4')[0])
        nproc = f.read_ints('i')
        print(nproc)


##### PREPROCESS DATA #####
strong_speedup = []
weak_speedup = []

for j in range(len(nsproc)):
    strong_speedup.append( strong_timings[0] / strong_timings[j] )
    weak_speedup.append( weak_timings[0] / weak_timings[j] )


##### FIT IDEAL SPEEDUP CURVES #####

strong_ideal_seepdup = []
weak_ideal_speedup = []

def amdahl(x, p=0.95):
    return( 1 / (1-p) + p / x )

def gustav(x, p=0.95):
    return( (1-p) + p * x )

popt_strong, pcov_strong = curve_fit(amdahl, nsproc, strong_speedup)
popt_weak, pcov_weak = curve_fit(gustav, nsproc, weak_speedup)


##### VISUALIZE RESULT #####

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