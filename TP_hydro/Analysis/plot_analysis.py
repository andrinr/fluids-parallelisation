#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from scipy.io import FortranFile
import matplotlib
import os.path

path_to_output = "measurements"

by_size = []

sizes = [128,256,512,1024]
thread_counts = [1,2,4,8,16,32,64,128,256,512,1024]
# read image data
with FortranFile(path_to_output, 'r') as f:

    for size in sizes:
        by_nthread = []
        for nthreads in thread_counts:
            time = f.read_reals('f4')
            by_nthread.append(time[0])

        by_size.append(by_nthread)

# create dataframe
df = pd.DataFrame(data=by_size, index=sizes,columns=np.log(thread_counts))
df = df.T

print(df)

# plot dataframe
fig, ax = plt.subplots()

sns.lineplot(data=df, ax=ax).set_title("Computation time by number of threads with openmp")

ax.set(xlabel='Log number of threads')
ax.set(ylabel='Execution time in seconds')
ax.legend(title='Simulation size NxN')
plt.show()

    