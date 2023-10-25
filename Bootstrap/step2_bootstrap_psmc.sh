#=============================================================================#
# RUN PSMC : write and launch a script for each sample
# STEP 2 : run psmc with '-b' option to do repetition in splitted fasta file
#=============================================================================#

# Get a list of basename of your samples
Basename_samples="sample_1 sample_2 sample_3 sample_4"

# get local dir
Local_Dir="/Your/PATH_TO/PSMC_FOLDER"

# nb of bootstrap
Nb_Boot=100

# create one script by samples and by iteration to run PSMC and launch it on the cluster
for name in $Basename_samples
do
    cd ${name}_masked_PSMC
	# create loop from 1 to x repetition (here, x = 100)
    for i in `seq ${Nb_Boot}`
    do
    echo $i
    cat > ${name}_round${i}_PSMC.sh << EOF
#!/bin/bash
#SBATCH --clusters=mesopsl1
#SBATCH --account=gay
#SBATCH --partition=def
#SBATCH --qos=mesopsl1_def_long
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --job-name=round${i}_psmc_${name}
#SBATCH --time=10:00:00

# IMPORT MODULE
module load gcc/9.2.0
module load samtools/1.10
module load psmc

# run psmc : name with the num of iteration 'round${i}' the .psmc output
# t = maximum 2N0 coalescent time
# r = initial theta/rho ratio
# p = pattern of parameters
# b = bootstrap (input be preprocessed with split_psmcfa)
psmc -t40 -b -r5 -p "4+25*2+4+6" -o round${i}_${name}_bootstrap.psmc ${name}.split.consensus.psmcfa

EOF
    sbatch ${name}_round${i}_PSMC.sh
done
    cd ${Local_Dir}
done

