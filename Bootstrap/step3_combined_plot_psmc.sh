#!/bin/bash
#=============================================================================#
# RUN PSMC : write and launch a script for each sample
# STEP 3 : combine all psmc files and create file for plotting all repetition
#=============================================================================#

# Get a list of basename of your samples
Basename_samples="sample_1 sample_2 sample_3 sample_4"

# get local dir 
Local_Dir="/Your/PATH_TO/PSMC_FOLDER"

# create one script by samples to run PSMC and launch it on the cluster
for name in $Basename_samples
do
    cd ${name}_masked_PSMC

    cat > ${name}_plot_PSMC.sh << EOF
#!/bin/bash
#SBATCH --clusters=mesopsl1
#SBATCH --account=gay
#SBATCH --partition=def
#SBATCH --qos=mesopsl1_def_long
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --job-name=plot_${name}
#SBATCH --time=02:00:00
#SBATCH -o plot_40_${name}.o
#SBATCH -e plot_40_${name}.e

# IMPORT MODULE
module load gcc/9.2.0
module load samtools/1.10
module load psmc

# combine all repetition of PSMC 
cat round*_${name}_bootstrap.psmc >> ${name}_bootstrap_combined.psmc

# get table for PSMC plot
# R =  do not remove temporary files
# n = which iteration to take (the last one preferably)
# u = mutation rate
# g = generation time
# -T = initial divergence time
psmc_plot.pl -R -n 30 -u 1.93e-08 -g 11 -T ${name}_bootstrap -p ${name}_bootstrap_plot ${name}_bootstrap_combined.psmc
EOF
    sbatch ${name}_plot_PSMC.sh
    cd ${Local_Dir}
done

