library(tidyverse)
library(data.table)
library(profvis)

n_patients <- 1000
bootstrap_n <- 5000
bootstrap_size <- 100

set.seed(1337)
population <- data.table(
  patient_id = 1:n_patients,
  dummy_measurement = runif(n_patients),
  analysis_flag = rbinom(n_patients, 1, 0.8) > 0
)

implementations <- list(
  impl_1 = function(population) {
    result <- NULL
    for (i in seq_len(bootstrap_n)) {
      bootstrap_data_rows <- sample(
        x = seq_len(nrow(population)), 
        size = bootstrap_size,
        replace = TRUE
      )
      current_bootstrap <- population[bootstrap_data_rows, ]
      analysis_pop <- filter(current_bootstrap, analysis_flag == T)
      current_result <- tibble(
        bootstrap_index = i,
        computed_output = median(analysis_pop$dummy_measurement)
      )
      result <- bind_rows(result, current_result)
    }
    return(result)
  },
  impl_2 = function(population) {
    result <- NULL
    for (i in seq_len(bootstrap_n)) {
      bootstrap_data_rows <- sample(
        x = seq_len(nrow(population)), 
        size = bootstrap_size,
        replace = TRUE
      )
      current_bootstrap <- population[bootstrap_data_rows][(analysis_flag)]
      current_result <- tibble(
        bootstrap_index = i,
        computed_output = median(current_bootstrap$dummy_measurement)
      )
      result <- bind_rows(result, current_result)
    }
    return(result)
  },
  impl_3 = function(population) {
    result <- list()
    for (i in seq_len(bootstrap_n)) {
      bootstrap_data_rows <- sample(
        x = seq_len(nrow(population)), 
        size = bootstrap_size,
        replace = TRUE
      )
      current_bootstrap <- population[bootstrap_data_rows][(analysis_flag)]
      current_result <- tibble(
        bootstrap_index = i,
        computed_output = median(current_bootstrap$dummy_measurement)
      )
      result[[i]] <- current_result
    }
    return(bind_rows(result))
  },
  impl_4 = function(population) {
    computed_output <- numeric(bootstrap_n)
    for (i in seq_len(bootstrap_n)) {
      bootstrap_data_rows <- sample(
        x = seq_len(nrow(population)), 
        size = bootstrap_size,
        replace = TRUE
      )
      current_bootstrap <- population[bootstrap_data_rows][(analysis_flag)]
      computed_output[i] <- median(current_bootstrap$dummy_measurement)
    }
    return(
      tibble(
        bootstrap_index = seq_len(bootstrap_n),  
        computed_output = computed_output
      )
    )
  },
  impl_5 = function(population) {
    computed_output <- numeric(bootstrap_n)
    analysis_indices <- which(population$analysis_flag)
    for (i in seq_len(bootstrap_n)) {
      bootstrap_data_rows <- sample(
        x = seq_len(nrow(population)), 
        size = bootstrap_size,
        replace = TRUE
      )
      current_bootstrap_indices <- bootstrap_data_rows[bootstrap_data_rows %in% analysis_indices]
      computed_output[i] <- median(population$dummy_measurement[current_bootstrap_indices])
    }
    return(
      tibble(
        bootstrap_index = seq_len(bootstrap_n),  
        computed_output = computed_output
      )
    )
  }

)

results <- list()
profiles <- list()
for (i in seq_along(implementations)) {
  profiles[[i]] <- profvis({set.seed(1337); results[[i]] <- implementations[[i]](population)})
  stopifnot(all(results[[i]] == results[[1]]))
}


for (i in seq_along(profiles)) {
  print(profiles[[i]])
  
  # Or export:
  # htmlwidgets::saveWidget(profiles[[i]], paste0("profile-",i,".html"))
}

