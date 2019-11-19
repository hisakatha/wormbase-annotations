library(data.table)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)

# columns = num_copies,k
tr_stats_csv <- fread(args[1])

tr_stats_out <- args[2]

pdf(tr_stats_out, onefile = TRUE)

ggplot(tr_stats_csv) + geom_point(aes(k, num_copies), alpha = 0.05) + theme_classic()

invisible(dev.off())
