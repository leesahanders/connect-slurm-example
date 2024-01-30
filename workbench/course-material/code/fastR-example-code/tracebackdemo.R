f <- function(x) g(x)
g <- function(x) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric")
  }
  2 * x
}

# f("I am not numeric")
