#PREPAREDF: prepare dataframe for alpha dur

#-----------------#
#-pass arguments
#1. data to import, csv
#2. name of the file to save to
args <- commandArgs(TRUE)
#-----------------#

#-----------------#
#-read the data
if (file.exists(args[[1]])) {
  df <- read.csv(args[[1]], header=FALSE)
  colnames(df) <- c('subj', 'cond', 'day', 'sess', 'trl', 'dur', 'time', 'pow', 'pow1', 'pow2', 'pow3', 'pow4')

  df$subj <- factor(df$subj)
  df$trl <- factor(df$trl)
  df$day <- factor(df$day)
  df$sess <- ordered(df$sess)
  df$time <- factor(df$time)

  save(df, file=args[[2]])
  file.remove(args[[1]])
  
} else {
  
  print('REUSING PREVIOUSLY CREATE DAT')
  
}
#-----------------#
