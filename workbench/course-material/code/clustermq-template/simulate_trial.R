simulate_trial <- function(experiment, experiment_args, job_id, replication_index)
{
  # Simulate a population and compute some stats - replace this dummy with your actual simulation study
  n_patients <- experiment_args$n_patients
  
  # simulate_error() # Simulate an error
  
  population <- tibble(
    patient_id = 1:n_patients,
    dummy_measurement = runif(n_patients)
  )
  
  # Pre-computing a tibble with stats for each simulation study 
  # on the workers allows for rapid result aggregation on the master node
  result <- list(
    output_tibble = tibble(
      "job_id" = job_id,
      "computed_output" = experiment_args$computation[[1]](population$dummy_measurement)
    )
    # Other list items could be added here
  )

  return(result)
}

simulate_error <- function()
{
  stop("This is a simulated error")
}