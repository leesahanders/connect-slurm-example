library(batchtools)
makeRegistry(file.dir=NA)
fx = function(x) x * 2
batchMap(fun = fx, x = 1:6)
submitJobs(); waitForJobs()
reduceResultsList()
removeRegistry()
