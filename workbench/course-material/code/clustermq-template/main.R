source("load_packages.R")
source("cluster_engine.R")
source("simulate_trial.R")
source("cv.R")
source("bootstrap.R")

replications <- 10

# Define experiments to run - this dummy analysis needs to be adjusted to your use case
experiments <- tribble(
 ~experiment,      ~computation, ~seed, ~n_patients,
  "compute_median", median,       123,   50,
  "compute_mean"  , mean,         123,   50
)


# Simulation example ------------------------------------------------------
result_sim <- run_batch(
  experiments = experiments,
  batch_replications = replications,
  job_function = simulate_trial,
  worker_setup_function = default_worker_setup(additional_source_files = c("simulate_trial.R"))
  #, test_single_job_per_experiment = TRUE # Use this option to debug a single job per experiment
  #, test_single_job_index = c(1) # Use this option to debug single jobs that fail
)

reduce_to_tibble(result_sim)

# Cross-validation example ------------------------------------------------
result <- run_batch(
  experiments = experiments,
  batch_replications = replications,
  job_function = simulate_trial,
  worker_setup_function = cv_worker_setup_function
  #, test_single_job_per_experiment = TRUE # Use this option to debug a single job per experiment
  #, test_single_job_index = c(1) # Use this option to debug single jobs that fail
)


# Bootstrap example -------------------------------------------------------
result <- run_batch(
  experiments = experiments,
  batch_replications = replications,
  job_function = simulate_trial,
  worker_setup_function = bootstrap_worker_setup_function
  #, test_single_job_per_experiment = TRUE # Use this option to debug a single job per experiment
  #, test_single_job_index = c(1) # Use this option to debug single jobs that fail
)