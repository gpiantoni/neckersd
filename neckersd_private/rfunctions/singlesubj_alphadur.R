#Single-subj alphadur: 

#-----------------#
#-pass arguments
#1. file of the dataset
#2. 'pow', 'pow1', 'pow2', 'pow3', 'pow4'
#3. output file
args <- commandArgs(TRUE)
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
cat('\n\n\nSINGLE-SUBJ CORR\n\n')
#-----------------#

#-----------------#
#-simplify data
dfp <- aggregate(cbind(alphapow, dur) ~ subj + cond, data = df, mean)
print(dfp)

d_dfp <- aggregate(cbind(alphapow, dur) ~ subj, data = dfp, diff);
#-----------------#

#-----------------#
#-paired t-test and corr
(t1 <- t.test(d_dfp$alphapow))
(t2 <- t.test(d_dfp$dur))

(t3 <- cor.test(d_dfp$alphapow, d_dfp$dur))
#-----------------#% 

#-----------------#
#-prepare csv
singlesubj <- numeric(3)
singlesubj[1] <- t1$p.value
singlesubj[2] <- t2$p.value
singlesubj[3] <- t3$p.value
#-----------------#

#-----------------#
sink()

infofile <- paste(substr(outputfile, 1, nchar(outputfile)-12), 'output_singlesubj', '.csv', sep='')
write.table(singlesubj, file=infofile, row.names=FALSE, col.names=FALSE, quote=FALSE)
#-----------------#