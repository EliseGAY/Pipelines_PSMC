#==============================
# PSMC Plot with 95% CI Ribbon
#==============================

library(ggplot2)

# Set directory containing bootstrap files
setwd("path_to_bootstrap_files/")

# Sample name (single individual)
sample_name <- "IND1"  # Replace with your actual sample prefix

# List all bootstrap files for this individual
bootstrap_files <- list.files(pattern = paste0(sample_name, "_bootstrap"))

# Prepare empty matrices to store time and Ne
time_matrix <- NULL
ne_matrix <- NULL

# Define a common time grid (optional, helps align bootstrap replicates)
time_grid <- seq(0, 1e7, by = 10000)  # adjust max and bin size if needed

# Read all bootstrap replicates
for (file in bootstrap_files) {
  data_boot <- read.table(file)[, 1:2]  # columns: V1 = time, V2 = Ne
  # Align to common time grid
  indices <- sapply(time_grid, function(t) which.min(abs(data_boot$V1 - t)))
  time_matrix <- cbind(time_matrix, data_boot[indices, 1])
  ne_matrix   <- cbind(ne_matrix, data_boot[indices, 2])
}

# Calculate 95% confidence interval and mean
ci_lower <- apply(ne_matrix, 1, quantile, probs = 0.025) * 10000
ci_upper <- apply(ne_matrix, 1, quantile, probs = 0.975) * 10000
mean_ne  <- apply(ne_matrix, 1, mean) * 10000

plot_df <- data.frame(
  time = time_matrix[,1],
  Ne_mean = mean_ne,
  ymin = ci_lower,
  ymax = ci_upper
)

# Plot
ggplot(plot_df, aes(x = time, y = Ne_mean)) +
  geom_ribbon(aes(ymin = ymin, ymax = ymax), fill = "lightblue", alpha = 0.4) +
  geom_line(color = "blue", size = 1) +
  scale_x_log10(name = "Years") +
  scale_y_continuous(name = "Effective population size") +
  theme_minimal(base_size = 14)
