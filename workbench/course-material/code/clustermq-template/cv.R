cv_worker_setup_function <- default_worker_setup(
  additional_source_files = c("cv.R"),
  additional_setup = function(working_dir) 
  {
    ## Load fake data into the worker environment _once_ at the beginning
    fake_data_folds <<- readRDS("fake_data_folds.RDS")
  }
)

run_cv <- function(experiment, experiment_args, job_id, replication_index)
{
  # Simulate a population and compute some stats - replace this dummy with your actual simulation study
  current_fold <- replication_index
  
  assert_that(current_fold %in% fake_data_folds$fold)
  
  cv_fake_data <- fake_data_folds[fake_data_folds$fold != current_fold, ]
  
  # The result is expected to be a list
  result <- list(
    "computed_output" = experiment_args$computation(cv_fake_data$dummy_measurement)
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