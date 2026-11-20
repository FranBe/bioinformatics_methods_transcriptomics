library( "DESeq2" )

# read in the read count data; note that the header line must not start with # => delete the # sign at the front of the read count file
cts <- as.matrix(read.csv("/scratch16/lflorea1/projects/Coursera/M3/Isoquant/Ref_annot/ref_annot/ref_annot.gene_grouped_counts.tsv",sep="\t",row.names="feature_id"))

# read in the column name data; MUST match the rows of the column data
coldata<- read.csv("/scratch16/lflorea1/projects/Coursera/M4/DESeq2/GSE151841.Isoquant.coldata",sep="\t", row.names=1)

# load and then run the DDS object with the counts data and column data and experiment design 
# deseq2 requires integer counts => round any fractional counts
dds <-DESeqDataSetFromMatrix(countData=round(cts,digits=0),colData=coldata,design=~condition)
dds$condition <- relevel( dds$condition, "wt" )
dds <-DESeq(dds)

res<-results(dds)
res_pval0.05 <-res[ which(res$pvalue <= 0.05 ), ]
res_qval0.05 <-res[ which(res$padj <= 0.05 ), ]

write.csv( round(counts(dds, normalized=TRUE),digits=2), file="normalized_counts.wt_vs_Smchd1.Isoquant-genes.csv" )
write.csv( as.data.frame(res), file="results_wt_vs_Smchd1.Isoquant-genes.csv" )
write.csv( as.data.frame(res_pval0.05), file="results_wt_vs_Smchd1.Isoquant-genes.pval05.csv" )
write.csv( as.data.frame(res_qval0.05), file="results_wt_vs_Smchd1.Isoquant-genes.qval05.csv" )

