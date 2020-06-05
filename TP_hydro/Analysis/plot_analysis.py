import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
from scipy.io import FortranFile
import matplotlib
import os.path
from matplotlib.ticker import ScalarFormatter

path_to_output = "measurements"
strong_scaling_timings = []
weak_scaling_timings = []

sizes = [64, 128, 256, 512, 1024, 2048, 4096]
nproc_counts = [ 1, 2, 4, 8, 16, 32, 36]

# read measruement data
with FortranFile(path_to_output, 'r') as f:
    for nproc in nproc_counts:
        strong_scaling_timings.append(f.read_reals('f4')[0])
    
    for size in sizes: 
        weak_scaling_timings.append(f.read_reals('f4')[0])

print(strong_scaling_timings)
print(weak_scaling_timings)
