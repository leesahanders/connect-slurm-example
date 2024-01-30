write_fake_data_folds <- function(
    n_patients = 100,
    folds = 10,
    file = "fake_data_folds.RDS"
) 
{
  population <- tibble(
    patient_id = 1:n_patients,
    dummy_measurement = runif(n_patients),
    fold = sample( 1 + ((0:(n_patients-1)) %% folds))
  )
  
  saveRDS(population, file=file)
} 

write_fake_data <- function(
    n_patients = 100,
    file = "fake_data.RDS"
) 
{
  population <- tibble(
    patient_id = 1:n_patients,
    dummy_measurement = runif(n_patients)
  )
  
  saveRDS(population, file=file)
} 

set.seed(1337)
write_fake_data()
write_fake_data_folds()