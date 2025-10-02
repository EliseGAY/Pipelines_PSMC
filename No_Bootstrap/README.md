
# PSMC Pipeline (No Bootstrap)


This repository provides scripts to run the PSMC tool on a cluster (adapted for PSL cluster with SLURM commands) using the original PSMC pipeline: https://github.com/lh3/psmc

---

## Input

- BAM file(s), zipped or unzipped.  
- Optionally, select only the first scaffold/chromosome for testing or small runs.

---

## How to run

```bash
sh psmc.sh
```

> **SLURM note:** The script internally calls `sbatch` to submit jobs for each sample using line 70 of `psmc.sh`.

---

## Pipeline Overview

The pipeline consists of four steps:

1. **Variant calling** using **BCFTOOLS** (not GATK).  
2. (Optional) Select the first scaffold/chromosome as needed.  
3. **fq2psmcfa** – create consensus sequences.  
4. **psmc** – run PSMC with chosen parameters.  
5. **psmc_plot.pl** – Perl script to extract effective population size (`Ne`) of the chosen iteration.

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
  5. Proportion of the genome covered by the interval  

### 3. `_plot.0` files

- Contains reconstructed effective population size (`Ne`) for the chosen iteration.  
- **Output table columns:**
  1. Time  
  2. Ne  
  3–5. Correspond to the last three columns of the chosen iteration in the `.psmc` file.

---

## Notes / Best Practices

- Verify BAM/consensus files before running PSMC.  
- Carefully choose parameters in `fq2psmcfa` and `psmc` to ensure correct scaling.  
- Keep track of output files for reproducibility and plotting consistency.  

---

## References

- Li, H., & Durbin, R. (2011). Inference of human population history from individual whole-genome sequences. *Nature*, 475(7357), 493–496.  
- Original PSMC GitHub: https://github.com/lh3/psmc
