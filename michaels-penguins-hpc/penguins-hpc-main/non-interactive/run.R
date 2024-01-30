compute <- function(trials, cores) {
  # Setting options for clustermq (can also be done in .Rprofile)
  options(clustermq.scheduler = "slurm",
          clustermq.template = "slurm.tmpl")
  
  # Loading libraries
  library(clustermq)
  library(foreach)
  library(palmerpenguins)
  
  # Register parallel backend to foreach
  register_dopar_cmq(
    n_jobs = cores,
    memory = 1024,
    log_worker = FALSE,
    chunk_size = trials / 5 / cores
  )
  
  # Our dataset
  x <- penguins[c(4, 1)]
  
  # Number of trials to simulate
  trials <- trials
  
  # Main loop
  foreach(i = 1:trials, .combine = rbind) %dopar% {
    ind <- sample(344, 344, replace = TRUE)
    result1 <-
      glm(x[ind, 2] ~ x[ind, 1], family = binomial(logit))
    coefficients(result1)
  }
}

trials=100
cores=4
x<-compute(trials,cores)


