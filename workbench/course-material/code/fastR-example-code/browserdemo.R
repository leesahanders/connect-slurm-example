f <- function(x) g(x)
g <- function(x) {
  if (!is.numeric(x)) {
    browser()
  }
  2 * x
}

f(1)
f("I am not numeric")
