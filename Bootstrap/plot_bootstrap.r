#========================#
# PSMC Bootstrap Plot CI
#========================#

library(ggplot2)
library(stringr)

# Set directory with all bootstrap files
setwd("path_to_bootstrap_files/")

# Sample prefix for bootstrap files (everything before "_bootstrap_plot")
sample_name <- "_Q_S_A_S1"

# Whole genome PSMC file (without bootstrap)
wg_file <- "_Q_S_A_S1_plot.0"  # your real whole genome file

# Load whole genome data
wg_data <- read.table(wg_file)[,1:2]
wg_data$Ne <- wg_data$V2 * 10000  # scale

# List all bootstrap files for this sample
lof <- list.files()
lof_boot <- lof[grep(paste0(sample_name, "_bootstrap_plot"), lof)]

# Create matrix for time bins and Ne
tmp_time <- NULL
tmp_NE <- NULL

# Define common time vector for interpolation
vecteur_temps <- seq(from = 0, to = max(wg_data$V1), by = 100)

for (bfile in lof_boot) {
  data <- read.table(bfile)[,1:2]
  
  # Interpolate to common time vector
  indices <- sapply(vecteur_temps, function(t) which.min(abs(data[,1]-t)))
  data_new <- data[indices,]
  
  tmp_time <- cbind(tmp_time, data_new[,1])
  tmp_NE   <- cbind(tmp_NE, data_new[,2])
}

# Compute 95% CI from bootstrap replicates
psmc_CI_95 <- apply(tmp_NE, 1, quantile, probs = 0.95)
psmc_CI_5  <- apply(tmp_NE, 1, quantile, probs = 0.05)

df_CI <- data.frame(
  time = tmp_time[,1],
  Ne_min = psmc_CI_5 * 10000,
  Ne_max = psmc_CI_95 * 10000
)

# Prepare whole genome PSMC data for plotting
df_wg <- data.frame(time = wg_data$V1, Ne = wg_data$Ne)

# Plot
ggplot() +
  geom_ribbon(data = df_CI, aes(x = time, ymin = Ne_min, ymax = Ne_max), fill = "lightblue", alpha = 0.3) +
  geom_line(data = df_wg, aes(x = time, y = Ne), color = "blue", size = 1) +
  scale_x_log10(name = "Years") +
  scale_y_continuous(name = "Effective population size") +
  theme_minimal(base_size = 15)
