#!/bin/bash -l

module load STAR/2.7.10a
module load samtools/1.15.1

## STAR script
STAR=STAR
BASEDIR=/scratch16/lflorea1/projects/Coursera/M3/
DATADIR=${BASEDIR}/Data/FASTQ.SR
WORKDIR=${BASEDIR}/Star
STAR2IDX=/scratch4/lflorea1/shared/genomes/mm39/star


# wild type replicates
for i in SRR1793544 SRR1793545 SRR1793549
do
  time \
  $STAR --limitBAMsortRAM 50000000000 --runThreadN 6 --genomeDir $STAR2IDX/ \
        --readFilesIn $DATADIR/${i}_1.fastq.gz $DATADIR/${i}_2.fastq.gz --readFilesCommand zcat \
        --outSAMtype BAM SortedByCoordinate --outSAMstrandField intronMotif \
        --outFileNamePrefix ${WORKDIR}/${i}_ &> ${WORKDIR}/${i}.star.log &
done

wait 

# Smchd1 null replicates
for i in SRR1793546 SRR1793547 SRR1793548
do
  time \
  $STAR --limitBAMsortRAM 50000000000 --runThreadN 6 --genomeDir $STAR2IDX/ \
        --readFilesIn $DATADIR/${i}_1.fastq.gz $DATADIR/${i}_2.fastq.gz --readFilesCommand zcat \
        --outSAMtype BAM SortedByCoordinate --outSAMstrandField intronMotif \
        --outFileNamePrefix ${WORKDIR}/${i}_ &> ${WORKDIR}/${i}.star.log &
done

wait

## Next, index the files
for i in SRR1793544 SRR1793545 SRR1793549
do
   samtools index ${i}_Aligned.sortedByCoord.out.bam &
done

wait

for i in SRR1793546 SRR1793547 SRR1793548
do
   samtools index ${i}_Aligned.sortedByCoord.out.bam &
done

wait

exit;
