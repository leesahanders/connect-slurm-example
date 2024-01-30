# Use default configuration -----------------------------------------------
library(clustermq) 
fx = function(x) x * 2
Q(fx, x=1:6, n_jobs=3)
