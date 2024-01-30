# Do local debugging for 2 values of x ------------------------------------
options(clustermq.scheduler = "LOCAL")
library(clustermq) 

fx_debug <- function(x) {browser(); x * 2}
Q(fx_debug, x = 1:2)

# Run on 3 cores locally via 3 R processes --------------------------------
fx <- function(x) {x * 2}
options(clustermq.scheduler = "multiprocess")
Q(fx, x = 1:6, n_jobs = 3)