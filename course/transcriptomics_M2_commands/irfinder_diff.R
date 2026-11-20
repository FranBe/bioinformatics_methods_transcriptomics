## Modified from https://github.com/williamritchie/IRFinder/wiki/Generalized-Linear-Model-with-Replicates

library( "DESeq2" )
library( "EnhancedVolcano" )

source("/scratch4/lflorea1/shared/sw/src/irfinder_env/opt/irfinder-1.3.1/bin/DESeq2Constructor.R") 
                                                                             # Load IRFinder-related function
results = read.table("filePaths.txt")
paths = as.vector(results$V1)                                                # File names must be saved in a vector
experiment = read.table("experiment.txt",header=T)
experiment$Condition=factor(experiment$Condition,levels=c("Ctrl","Test"))    # Set Ctrl as the baseline in the analysis
rownames(experiment)=NULL                                                    # Force removing rownames

# WARNING: make sure the rownames of `experiment` is set to NULL.
# WARNING: users MUST check if the order of files in the `path` matches the order of samples in `experiment` before continue

metaList=DESeqDataSetFromIRFinder(filePaths=paths, designMatrix=experiment, designFormula=~1)

# The above line generates a meta list containing four slots
# First slot is a DESeq2 Object that can be directly passed to DESeq2 analysis.
# Second slot is a matrix for trimmed mean of intron depth
# Third slot  is a matrix for correct splicing depth flanking introns
# Fourth slot is a matrix for maximum splicing reads at either ends of introns
# We build a “null” regression model on the interception only.
# A “real” model can be assigned either here directly, or in the downstream step. See below

dds = metaList$DESeq2Object                       # Extract DESeq2 Object with normalization factors ready
colData(dds)                                      # Check design of matrix

# Please note that sample size has been doubled and one additional column "IRFinder" has been added.
# This is because IRFinder considers each sample has two sets of counts: one for reads inside
# intronic region and one for reads at splice site, indicating by "IR" and "Splice" respectively.
# "IRFinder" is considered as an additional variable in the GLM model.
# Please also be aware that size factors have been set to 1 for all samples. Re-estimation of size 
# factors is NOT recommended and is going to bias the result.
# More details at the end of the instruction.

design(dds) = ~Condition + Condition:IRFinder     # Build a formula of GLM. Read below for more details.
dds = DESeq(dds)                                  # Estimate parameters and fit to model
resultsNames(dds)                                 # Check the actual variable name assigned by DESeq2

res.Ctrl = results(dds, name = "ConditionCtrl.IRFinderIR")

# This tests if the number of IR reads are significantly different from normal spliced reads, in the Ctrl samples.
# We might only be interested in the "log2FoldChange" column, instead of the significance.
# This is because "log2FoldChange" represents log2(number of intronic reads/number of normal spliced reads).
# So we the value of (intronic reads/normal spliced reads) by

Ctrl.IR_vs_Splice=2^res.Ctrl$log2FoldChange

# As IR ratio is calculated as (intronic reads/(intronic reads+normal spliced reads))
# We can easily convert the above value to IR ratio by

IRratio.Ctrl = Ctrl.IR_vs_Splice/(1+Ctrl.IR_vs_Splice)

# Similarly, we can get IR ratio in the Test samples
res.Test = results(dds, name = "ConditionTest.IRFinderIR")
Test.IR_vs_Splice=2^res.Test$log2FoldChange
IRratio.Test = Test.IR_vs_Splice/(1+Test.IR_vs_Splice)

# Finally we can test the difference of (intronic reads/normal spliced reads) ratio between Ctrl and Test

res.diff = results(dds, contrast=list("ConditionTest.IRFinderIR","ConditionCtrl.IRFinderIR"))
write.csv( as.data.frame(res.diff), file="IR_Test_vs_Ctrl.csv", row.names = TRUE )
write.csv( as.data.frame(res.diff[ which(res.diff$pvalue <= 0.05), ]), file="IR_Test_vs_Ctrl.pval05.csv", row.names = TRUE )
write.csv( as.data.frame(res.diff[ which(res.diff$padj <= 0.05), ]), file="IR_Test_vs_Ctrl.qval05.csv", row.names = TRUE )
write.csv( as.data.frame(res.diff[ which(res.diff$pvalue <= 0.05 & abs(res.diff$log2FoldChange) >= 1.0 ), ]), file="IR_Test_vs_Ctrl.pval05_lFC1.csv", row.names = TRUE )

# We can plot the changes of IR ratio with p values
# In this example we defined significant IR changes as
# 1) IR changes no less than 10% (both directions) and
# 2) with adjusted p values less than 0.05

IR.change = IRratio.Test - IRratio.Ctrl
plot(IR.change,col=ifelse(res.diff$pvalue <= 0.05 & abs(IR.change)>=0.1, "red", "black"))

# PLEASE NOTE
# You might see dots at the same horizontal level (same IR change) either marked as significant (red) or not (black)
# This is because the Wald test applied above is testing on fold changes instead of absolute changes
# For example, both changes from 0.01 to 0.11 and from 0.8 to 0.9 have absolute changes of 0.1.
# But the fold changes for them are 11 folds and 1.1 folds respectively, and lead to different p values

# Volcano plot of the differential analysis results
gl=c("")
png("IR_volcano_Test_vs_Ctrl.png", width = 720, height = 720)
#ylim = c(0, 30)
myV <- EnhancedVolcano(res.diff, lab=NA, selectLab = gl, labSize = 3.0, title = "Ctrl_Test.IR", x = 'log2FoldChange', y = 'pvalue', pCutoff = 0.05, FCcutoff = 1.5, titleLabSize=24, cutoffLineWidth=0.2, ylab = bquote(~-Log[10]~italic(Padj)), legendLabSize=-1, legendIconSize=-1, xlim=c(-10,10) )
print(myV);
dev.off()
