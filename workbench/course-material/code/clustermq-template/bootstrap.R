bootstrap_worker_setup_function <- default_worker_setup(
  additional_source_files = c("bootstrap.R"),
  additional_setup = function(working_dir) 
  {
    ## Load fake data into the worker environment _once_ at the beginning
    fake_data <<- readRDS("fake_data.RDS")
  }
)

run_bootstrap <- function(experiment, experiment_args, job_id, replication_index)
{
  # Simulate a population and compute some stats - replace this dummy with your actual simulation study
  bootstrap_data_rows <- sample(
    x = seq_len(nrow(fake_data)), 
    size = experiment_args$bootstrap_size,
    replace = TRUE
  )
  bootstrapped_fake_data <- fake_data[bootstrap_data_rows, ]
  
  # The result is expected to be a list
  result <- list(
    "computed_output" = experiment_args$computation(bootstrapped_fake_data$dummy_measurement)
  )
  
  # Pre-computing a tibble with stats for each simulation study 
  # on the workers allows for rapid result aggregation on the master node
  result$output_tibble <- tibble(
    "job_id" = job_id,
    "computed_output" = result$computed_output
  )
  
  return(result)
  
}

simulate_error <- function()
{
  stop("This is a simulated error")
}