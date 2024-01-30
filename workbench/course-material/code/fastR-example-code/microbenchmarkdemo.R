library("microbenchmark")
library("ggplot2")
x <- c()
microbenchmark(for(i in 1:1000) {x[i] <- sin(i/100)})
microbenchmark(x[1:1000] <- sin(1:1000/100))
result <- microbenchmark(
  {for(i in 1:1000) {x[i] <- sin(i/100)}}, 
  {x[1:1000] <- sin(1:1000/100)}, 
  times = 1000
)
print(result)
print(autoplot(result))
