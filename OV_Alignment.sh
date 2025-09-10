#!/bin/bash 

# Scrip preview
# Involves alignemt using a reference gene from gnomAD repositiory.
# the packages used are BWA, SAM/BAM, samtools, and bcftools.

# Script starts 
set -e  # Exit if any command fails

# Main objectives 
# 1. Align sequences to a reference genome
# 2. Detect variations (variants/variant calling)

## The alignment process consists of two steps:
# 1st Indexing the reference genome
# 2nd Aligning the reads to the reference genome

#  Preps. #
#a) Download packages using; conda install -c bioconda bwa samtools bcftools seqtk
#b) Download the reference genome manually into the PC or via the terminal using curl

# Objective 1: Alignemnt
#Index reference genome
bwa index  /Users/u/Downloads/coding/CMBG/ov_analysis/ref_genome/gene.fna

#Align reads to reference genome

# Define paths
trimmed="/Users/u/Downloads/coding/CMBG/ov_analysis/trimmed_reads"
assembly_dir="/Users/u/Downloads/coding/CMBG/ov_analysis/ref_assembly"
reference="/Users/u/Downloads/coding/CMBG/ov_analysis/ref_genome/gene.fna"

# Create output folder
echo "Creating reference assembly folder..."
mkdir -p "$assembly_dir"

# Loop through each R1 file
for r1 in "$trimmed"/*_trimmed_R1.fastq.gz
do
    r2="${r1/_R1/_R2}"   # Find matching R2
    sample=$(basename "$r1" _trimmed_R1.fastq.gz)
    
    echo "Aligning sample: $sample"
    outdir="$assembly_dir/$sample"
    mkdir -p "$outdir"

    # Step 1: Align reads with BWA-MEM
    bwa mem -t 8 "$reference" "$r1" "$r2" > "$outdir/${sample}.sam"

    # Step 2: Convert SAM → BAM
    samtools view -bS "$outdir/${sample}.sam" > "$outdir/${sample}.bam"

    # Step 3: Sort BAM
    samtools sort "$outdir/${sample}.bam" -o "$outdir/${sample}_sorted.bam"

    # Step 4: Index BAM
    samtools index "$outdir/${sample}_sorted.bam"

    # Step 5: Generate consensus FASTA
    samtools mpileup -uf "$reference" "$outdir/${sample}_sorted.bam" | \
    bcftools call -c - | \
    vcfutils.pl vcf2fq > "$outdir/${sample}_consensus.fq"

    # Step 6: Convert to FASTA
    seqtk seq -a "$outdir/${sample}_consensus.fq" > "$outdir/${sample}_consensus.fasta"

    echo "Reference-guided assembly complete for $sample"
done

echo "All samples assembled using reference genome!"

# Script ends
