#!/bin/bash

#SBATCH --gres=gpu:3,gpu_mem:5000M  # number of GPUs (keep it at 3) and memory limit
#SBATCH --cpus-per-task=20            # number of CPU cores
#SBATCH --output=slurm-%j.out        # output file


./my_run.sh --affix 1024nodes_300bnlayer_nz_15000 --bnf-dim 300 --train-stage -10

# --affix base_7accents_nz
# --affix base_512nodes_7accents_nz --bnf-dim 512
# 1024nodes_200bnlayer_7accents_nz --bnf-dim 200
# 1024nodes_100bnlayer_7accents_nz --bnf-dim 100
# 1024nodes_300bnlayer_except_england_canada --bnf-dim 300 