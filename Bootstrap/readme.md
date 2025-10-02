
# PSMC Pipeline with Bootstrap


This repository provides scripts to run the PSMC tool on a cluster (adapted for PSL cluster with SLURM commands) using the original PSMC pipeline: https://github.com/lh3/psmc

---

## Input

- BAM file(s), zipped or unzipped.  
- Optionally, you can select only the first scaffold/chromosome for testing or small runs.

---

## Pipeline Overview

Three main scripts are provided:

1. `step1_create_psmcfa.sh` – create consensus sequences and split them.  
2. `step2_bootstrap_psmc.sh` – run PSMC with bootstrap iterations.  
3. `step3_combined_plot_psmc.sh` – combine all bootstrap outputs and prepare plotting.  

**SLURM note:** Each script internally calls `sbatch` to submit jobs for individuals using `psmc.sh` (line 70).

---

## Step 1: Create PSMCFA (`step1_create_psmcfa.sh`)

- Performs variant calling using **BCFTOOLS** (not GATK).  
- Converts BAM/FASTA into consensus sequences using `fq2psmcfa`.  

### Example command
```bash
fq2psmcfa -s 40 XXX.consensus.fq.gz > XXX.consensus.psmcfa
```

> **Note:** Default bin size = 100. If you change it, rescale `N` in the PSMC output by `100/new_bin`.

- **Split consensus sequences** for bootstrapping using `splitfa`:
```bash
splitfa XXX.psmcfa 10000 > XXX.split.psmcfa
```
> Only use one `>` to avoid generating excessively large files.  

---

## Step 2: Bootstrap PSMC (`step2_bootstrap_psmc.sh`)

- Runs PSMC with the `-b` option to perform repetitions on the split fasta segments.  
- Each bootstrap generates a separate `.psmc` output file.

---

## Step 3: Combine & Plot (`step3_combined_plot_psmc.sh`)

- Combines all `.psmc` files from bootstrap iterations into one.  
- `psmc_plot.pl` (Perl) is used to generate the effective population size (`Ne`) table for plotting the chosen iteration.

---

## Outputs

### 1. `consensus.psmcfa`
- FASTA-like consensus sequences used by PSMC.

### 2. `.psmc` files
- **Header lines:**
```
CC    # comments
MM    # useful messages
RD    # round-of-iterations
LL    # log[P(sequence)]
QD    # Q-before-opt, Q-after-opt
TR    # theta_0, rho_0
RS    # k, t_k, lambda_k, pi_k, sum_l!=k(A_kl), A_kk
DC    # begin, end, best-k, t_k+Δ_k, max-prob
```
- **Example messages:**
```
MM    Version: 0.6.5-r67
MM    pattern:4+25*2+4+6, n:63, n_free_lambdas:28
MM    n_iterations:30, skip:1, max_t:40, theta/rho:5
MM    is_decoding:0
MM    n_seqs:10, sum_L:6957486, sum_n:278156
```
- **Iteration block example:**
```
IT  6169
RD  1
LK  -975421.298044
QD  -19719.527525 -> -12031.120010
RI  0.0144543040
TR  0.034099 0.005444
MT  68.653336
MM  C_pi: 1.091603, n_recomb: 41225.736374
```
- **Columns table for each iteration:**
  1. Time interval  
  2. Theta estimation  
  3. Number of recombination events per interval  
  4. Proportion of recombination per interval  
  5. Genome proportion covered by the interval  

### 3. `_plot.0` files
- One file per bootstrap iteration.  
- Contains effective population size (`Ne`) table for the chosen iteration to facilitate plotting.

---

## Notes / Best Practices

- Always check that your BAM/consensus files are correct before splitting or bootstrapping.  
- Adjust `fq2psmcfa` bin size carefully; incorrect scaling affects all downstream Ne estimates.  
- Use `splitfa` carefully to avoid huge files: one `>` per command only.  
- Keep track of bootstrap iterations to ensure reproducibility and consistent plots.  

---

## References

- Li, H., & Durbin, R. (2011). Inference of human population history from individual whole-genome sequences. *Nature*, 475(7357), 493–496.  
- Original PSMC GitHub: https://github.com/lh3/psmc
