#LMER_predict: 

#-----------------#
#-pass arguments
#1. file of the dataset
#2. 'pow', 'pow1', 'pow2', 'pow3', 'pow4'
#3. output file
args <- commandArgs(TRUE)
#-----------------#

#-----------------#
#-library
library('lme4')
#-----------------#

#-----------------#
#-data
datfile <- args[[1]]
outputfile <- args[[3]]
load(datfile)

# get rid of confusing columns
df$alphapow <- df[,args[[2]]]
df <- df[,!(names(df) %in% c('pow', 'pow1', 'pow2', 'pow3', 'pow4'))]

sink(outputfile, append=TRUE)
cat('\n\n\nLMER_PREDICT\n\n')
#-----------------#

#-----------------#
tstat <- numeric(length(levels(df$time)))
cnt <- 0
for (t in levels(df$time)){
  lm1 <- lmer(dur ~ alphapow + (1|subj) + (1|day:subj) + (1|sess:day:subj), subset(df, cond=='ns' & time==t))
  cnt <- cnt + 1
  tstat[cnt] <- summary(lm1)$coefficients[2,3]
}

print(levels(df$time))
print(tstat, digits=2)
#-----------------#

#-----------------#
#-to csv
tocsv <- NULL
tocsv[1] <- max(tstat)
tocsv[2] <- levels(df$time)[which.max(tstat)]
tocsv[3] <- sum(tstat > 1.95)
tocsv[4] <- sum(tstat > 1.64)

lm_t <- lm(1:length(tstat) ~ tstat)
tocsv[5] <- lm_t$coefficients[[2]]
#-----------------#

#-----------------#
sink()

infofile <- paste(substr(outputfile, 1, nchar(outputfile)-12), 'output_predict', '.csv', sep='')
write.table(tocsv, file=infofile, row.names=FALSE, col.names=FALSE, quote=FALSE)

predictfile <- paste(substr(outputfile, 1, nchar(outputfile)-12), 'predict_values', '.csv', sep='')
write.table(tstat, file=predictfile, row.names=FALSE, col.names=FALSE, quote=FALSE)
#-----------------#
#-----------------#
