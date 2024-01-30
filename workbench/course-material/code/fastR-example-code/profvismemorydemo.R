library(profvis)
prof <- profvis({
  x <- integer()
  for (i in 1:1e4) {
    x <- c(x, i)
  }
})
print(prof)