#!/bin/bash

# Trial with one sample 

# 1. Download SRA (SRR12345678 accession)
prefetch SRR25777591 && fasterq-dump SRR25777591 --split-files --progress
gzip SRR25777591_1.fastq SRR25777591_2.fastq

# 2. FastQC
mkdir -p fastqc_results
fastqc SRR25777591_*.fastq.gz -o fastqc_results

# 3. MultiQC
multiqc fastqc_results -o multiqc_report

# 4. fastp trimming
fastp \
  -i SRR25777591_1.fastq.gz \
  -I SRR25777591_2.fastq.gz \
  --length_required 50 \
  -o trimmed_R1.fastq.gz \
  -O trimmed_R2.fastq.gz \
  --html fastp_report.html \
  --json fastp_report.json

echo "Pipeline complete!"