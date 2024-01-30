f <- function(x) g(x)
g <- function(x) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric")
  }
  2 * x
}
f(1)
options(error = recover)
f("I am not numeric")
options(error = NULL) # Set to error = NULL to undo error = recover