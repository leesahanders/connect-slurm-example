options(error = function() {
  if(!interactive()) {
    dump.frames(to.file = TRUE, include.GlobalEnv = TRUE) # Save dump 
    q(status = 1) # Quit with error status 
  } else {
    recover() # If we're working interactively, recover instead
  }
})
a <- 1
if (a == 1) {
  stop("I am a really bad error!")
}