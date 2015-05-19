#SWITCHRATE:

#-----------------#
#-pass arguments
#1. file of the csv duration file
#2. mindur
#3. maxndur
#4. steps for hist statistics
#5. bw (kernel width)
#6. pngfile
#7. output file
args <- commandArgs(TRUE)

filename <- args[[1]]
mindur <- as.numeric(args[[2]])/10
maxdur <- as.numeric(args[[3]])/10
steps <- as.numeric(args[[4]])/10
bw <- as.numeric(args[[5]])/10
pngfile <- args[[6]]
output <- args[[7]]
#-----------------#

#-----------------#
#-library
library(lme4)
library(ggplot2)
#-----------------#

#-----------------#
#-read and clean duration data
sr <- read.table(filename, sep=',')
names(sr) <- c('subj', 'cond', 'day', 'sess', 'dur')
sr$subj <- factor(sr$subj)
sr$cond <- factor(sr$cond)
sr$day <- factor(sr$day)
sr$sess <- ordered(sr$sess)
sr$durlog <- log(sr$dur)
#-----------------#

#-----------------#
#-LMM for perceptual durations
sink(output, append=TRUE)
print('XXX Sleep Deprivation and Perceptual Duration XXX')
summary(subset(sr, dur > mindur & dur < maxdur))
lm1 <- lmer(durlog ~ cond + (1|subj) + (1|day:subj) + (1|sess:day:subj), subset(sr, dur > mindur & dur < maxdur))
summary(lm1)
#-----------------#

#-----------------#
dur_ns <- subset(sr, cond=='ns' & dur > mindur & dur < maxdur)$dur
dur_sd <- subset(sr, cond=='sd' & dur > mindur & dur < maxdur)$dur
ks.test(dur_ns, dur_sd)
#-----------------#

#-----------------#
(breakpoint <- seq(mindur,maxdur,steps))
hns <- hist(dur_ns, breaks=breakpoint)
hsd <- hist(dur_sd, breaks=breakpoint)
h <- data.frame(ns = hns$counts, sd = hsd$counts)

p.val <- 0
est <- 0
for (i in 1:nrow(h)) { 
  ptest <- prop.test(as.numeric(h[i,]), colSums(h))
  p.val[i] <- ptest$p.value
  est[i] <- diff(ptest$estimate)
}

p.val[is.nan(p.val)] <- 1
#-----------------#

#-----------------#
nsd <- density(sr[sr$cond=='ns','dur'], bw=bw, from=mindur, to=maxdur, n=(maxdur-mindur)*10+1)
sdd <- density(sr[sr$cond=='sd','dur'], bw=bw, from=mindur, to=maxdur, n=(maxdur-mindur)*10+1)

d1 <- data.frame(x = nsd$x, y = nsd$y, cond='ns')
d2 <- data.frame(x = sdd$x, y = sdd$y, cond='sd')
d <- rbind(d1, d2)
#-----------------#

#-----------------#
#-write to file
b1 <- hns$breaks[c(p.val < 0.05, FALSE)]
b2 <- hns$breaks[c(FALSE, p.val < 0.05)]
p <- p.val[p.val < 0.05]
b1b2 <- sprintf('%1.f-%1.f (%4.3f)', b1, b2, p)

print(paste(b1b2, collapse=' '))
sink()
#-----------------#

#-----------------#
#-make figure
df.p <- data.frame(x=hns$mids[p.val < 0.05], y=.1, est=est[p.val < 0.05]>0)
png(file=pngfile)
q <- ggplot(d, aes(x=x, y=y, fill=cond)) + geom_line(position='identity', width=.5) + geom_area(alpha=0.4, position='identity')
q + geom_point(aes(x=df.p$x, y=df.p$y, color=df.p$est)) + 
  geom_vline(xintercept = mean(sr[sr$cond=='ns','dur']), color='blue') + 
  geom_vline(xintercept = mean(sr[sr$cond=='sd','dur']), color='red')

dev.off()
#-----------------#
