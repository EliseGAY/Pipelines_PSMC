#!/bin/bash

# Get a list of basename of your samples
Basename_samples="sample_1 sample_2 sample_3 sample_4"

# get genome fasta file (preferable to run it on masked genome)
Genome_file="/Your/PATH_TO/reference_genome.fasta.masked"

# get the global directory where psmc folders will be stored
DIR="/Your/PATH_TO/PSMC_FOLDER"
# Loop on the sample name 
for name in $Basename_samples
do
	# Get the directory where you saved the BAM file of each sample from the mapping step
	# Here the bam files are stored in one folder by samples (saved in DIR_samples viriable)
    DIR_samples="Your/PATH_TO/Samples_X_BAM/"
	
	# Get the bam file corresponding to the current sample in the loop (adapt the bam command if needed)
    bam=$(ls ${DIR_samples} | grep ".bam.gz" | tr "\n" "\t" | cut -f1)
    echo ${bam}
	# create a folder for each sample and go in it. Each psmc results will be run in the sample folder 
    mkdir ${name}_masked_PSMC
    cd ${name}_masked_PSMC
	# create a script to run PSMC and run it on the cluster
    cat > ${name}_masked_PSMC.sh << EOF
#!/bin/bash
#SBATCH --clusters=mesopsl1
#SBATCH --account=gay
#SBATCH --partition=def
#SBATCH --qos=mesopsl1_def_long
#SBATCH --nodes=6
#SBATCH --ntasks-per-node=16
#SBATCH --job-name=psmc_${name}
#SBATCH --time=3-00:00:00

# IMPORT MODULE
module load gcc/9.2.0
module load samtools/1.10
module load psmc

# Make variant calling with bcftools. Use the $name variable to name the outputs files
samtools mpileup -Q 30 -q 30 --ff UNMAP,SECONDARY,QCFAIL,DUP  -u -v -f ${Genome_file} ${DIR_samples}${bam} | bcftools call -c -o ${name}.bcf.gz -O b

# filter if needed (filters by scaffolds)
bcftools index ${name}.bcf.gz .
bcftools view --regions "SUPER_1,SUPER_2,SUPER_3,SUPER_4,SUPER_5,SUPER_6,SUPER_7,SUPER_8,SUPER_9,SUPER_10" ${name}.bcf.gz -o 10st_${name}.bcf.gz -O b

# create a consensus file 
# d 10  = min depth per base
# D 50 = max depth per base
# Q 30 = min base quality
bcftools view 10st_${name}.bcf.gz | vcfutils.pl vcf2fq -d 10 -D 50 -Q 30 | gzip > 10st_${name}.consensus.fq.gz

# fastq to fasta
fq2psmcfa 10st_${name}.consensus.fq.gz > 10st_${name}.consensus.psmcfa

# run psmc
# t = maximum 2N0 coalescent time
# r = initial theta/rho ratio
# p = pattern of parameters
psmc -t 40 -r 5 -p "4+25*2+4+6" -o 10st_${name}.psmc 10st_${name}.consensus.psmcfa

# get table for PSMC plot
# R =  do not remove temporary files
# n = which iteration to take (the last one preferably)
# u = mutation rate
# g = generation time
# -T = initial divergence time
psmc_plot.pl -R -n 30 -u 1.93e-08 -g 11 -T 10st_${name} -p 10st_${name}_plot 10st_${name}.psmc
EOF

# run the script on the cluster with sbatch
    sbatch ${name}_masked_PSMC.sh
	# get out to the sample directory and conitnue the loop with a new one
    cd ${DIR}
done
