library(profvis)
f <- function() {
  pause(0.5)
  for (i in seq_len(3)) {
    g()
  }
}
g <- function() {
  pause(0.5)
}
prof <- profvis({f()})
print(prof)