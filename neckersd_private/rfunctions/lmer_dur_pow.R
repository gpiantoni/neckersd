#LMER_dur_POW: 

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
load(datfile)
outputfile <- args[[3]]

# get rid of confusing columns
df$alphapow <- df[,args[[2]]]
df <- df[,!(names(df) %in% c('pow', 'pow1', 'pow2', 'pow3', 'pow4'))]

sink(outputfile, append=TRUE)
cat('\n\n\nLMER_DUR_POW\n\n')

summary(df)
#-----------------#

#-----------------#
print('XXX Power-duration Correlation (NS) XXX')
lm1 <- lmer(dur ~ alphapow + (1|subj) + (1|day:subj) + (1|sess:day:subj), subset(df, cond=='ns'))
summary(lm1)
est.ns.pow <- summary(lm1)$coefficients[2,1]
t.ns.pow <- summary(lm1)$coefficients[2,3]

r2.corr.mer <- function(m) {
  lmfit <-  lm(model.response(m@frame) ~ fitted(m))
  summary(lmfit)$r.squared
}
cat('\nR-squared\n')
print(r2.corr.mer(lm1))
#-----------------#

#-----------------#
print('XXX Power-duration Correlation (SD) XXX')
lm1 <- lmer(dur ~ alphapow + (1|subj) + (1|day:subj) + (1|sess:day:subj), subset(df, cond=='sd'))
summary(lm1)
est.sd.pow <- summary(lm1)$coefficients[2,1]
t.sd.pow <- summary(lm1)$coefficients[2,3]
#-----------------#

#-----------------#
print('XXX Sleep Deprivation and Alpha Power XXX')
lm1 <- lmer(alphapow ~ cond + (1|subj) + (1|day:subj) + (1|sess:day:subj), df)
summary(lm1)
#-----------------#

#-----------------#
#-model
print('XXX Full MODEL: Sleep Deprivation and Alpha Power XXX')
lm1 <- lmer(dur ~ alphapow * cond + (1|subj) + (1|day:subj) + (1|sess:day:subj), df)
summary(lm1)
sink()
#-----------------#

#-----------------#
#-write to file only the full model
est.pow <- summary(lm1)$coefficients[2,1]
t.pow <- summary(lm1)$coefficients[2,3]

est.cond <- summary(lm1)$coefficients[3,1]
t.cond <- summary(lm1)$coefficients[3,3]

est.int <- summary(lm1)$coefficients[4,1]
t.int <- summary(lm1)$coefficients[4,3]
tocsv <- c(t.ns.pow, t.sd.pow, t.pow, t.cond, t.int)

infofile <- paste(substr(outputfile, 1, nchar(outputfile)-12), 'output_main', '.csv', sep='')
write.table(tocsv, file=infofile, row.names=FALSE, col.names=FALSE, quote=FALSE)
#-----------------#


#-ALPHA SCATTER LINE PLOT
# 12/11/27
# dfp <- aggregate(cbind(alphapow) ~ subj + cond + sess, data = df, mean) # average over electrodes
# dfp1 <- dfp[!rownames(dfp) %in% '71',] # remove unmatched observation
# dfp1$subjsess  <- interaction(dfp1$subj, dfp1$sess)

# p <- ggplot(dfp1, aes(x=cond, y=alphapow, color=factor(subj)))
# p + geom_point() + geom_line(aes(group=subjsess))
