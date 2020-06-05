#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from scipy.io import FortranFile
import matplotlib
import os.path
from matplotlib.ticker import ScalarFormatter

# TODO: add comparision to amdahl's / gustav's law, plot weak and strong scaling

path_to_output = "measurements"
timings = []

sizes = [128,256,512,1024,2048]
thread_counts = [1,2,4,8,16,32,64,128,256,512,1024]
# read image data
with FortranFile(path_to_output, 'r') as f:
    for size in sizes:
        timings_row = []
        for nthreads in thread_counts:
            time = f.read_reals('f4')
            timings_row.append(time[0])

        timings.append(timings_row)

speedups = []

# calculate speedup for each row
for i in range(len(timings)):
    speedups_row = []
    for j in range(len(timings[i])):
        speedups_row.append(timings[i][0]/timings[i][j])
    speedups.append(speedups_row)

# calculate speedup using amdahls law and asuming 100% parallelizable code
amdahl_row = []
for i in range(len(thread_counts)):
    amdahl_row.append(1 / (1/thread_counts[i]))

# create dataframe
df = pd.DataFrame(data=speedups, index=sizes,columns=thread_counts)
df = df.T

print(df)

# plot dataframe
fig, ax = plt.subplots()

sns.lineplot(data=df, ax=ax, dashes=False, markers=True, palette=sns.cubehelix_palette(len(sizes)))

ax.set_title("Strong scaling speedup with OpenMP \n compared to ideal speed up (dashed)")

ax.set(xlabel='Number of threads')
ax.set(ylabel='Speedup')
ax.legend(title='Sim size NxN')
plt.yscale('log', basey=2)
plt.xscale('log', basex=2)
#ax.yaxis.set_major_formatter(ScalarFormatter())
#ax.autoscale(False)
plt.plot(amdahl_row,thread_counts, color='black', ls='--')
plt.show()

    