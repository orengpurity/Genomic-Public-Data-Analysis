#!/bin/bash 

# Reanalysis of publicly available sequences on ovarian failure study

# SRA accession list (modify as needed)
SRA_IDS=("SRR25777591" "SRR25777593" "SRR25777589")

# Create directories
mkdir -p raw_data fastqc_reports trimmed_reads multiqc_report

# Download and process each SRA accession
for SRA_ID in "${SRA_IDS[@]}"; do
    echo "Processing $SRA_ID..."
    
    # 1. Download SRA data (prefetch + fasterq-dump)
    prefetch "$SRA_ID" && \
    fasterq-dump "$SRA_ID" --split-files --progress --outdir raw_data/ && \
    gzip "raw_data/${SRA_ID}_1.fastq" "raw_data/${SRA_ID}_2.fastq"
    
    # 2. FastQC (quality control)
    fastqc "raw_data/${SRA_ID}_1.fastq.gz" "raw_data/${SRA_ID}_2.fastq.gz" -o fastqc_reports/
    
    # 3. fastp (trimming)
    fastp \
        -i "raw_data/${SRA_ID}_1.fastq.gz" \
        -I "raw_data/${SRA_ID}_2.fastq.gz" \
        --length_required 50 \
        -o "trimmed_reads/${SRA_ID}_trimmed_R1.fastq.gz" \
        -O "trimmed_reads/${SRA_ID}_trimmed_R2.fastq.gz" \
        --html "trimmed_reads/${SRA_ID}_fastp_report.html" \
        --json "trimmed_reads/${SRA_ID}_fastp_report.json" \
        --thread 4  # Use 4 CPU threads
done

# 4. MultiQC (aggregate all reports)
multiqc fastqc_reports/ trimmed_reads/ -o multiqc_report/

echo "Pipeline complete! Check outputs in:"
echo "- Raw data: ./raw_data/"
echo "- QC reports: ./fastqc_reports/"
echo "- Trimmed reads: ./trimmed_reads/"
echo "- MultiQC report: ./multiqc_report/"

# End analysis