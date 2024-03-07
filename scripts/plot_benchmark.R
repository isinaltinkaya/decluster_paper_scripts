library(ggplot2)

# read in the benchmark results
args1<-length(commandArgs(trailingOnly = TRUE))-1
readlist<-commandArgs(trailingOnly = TRUE)[1:args1]

results <- lapply(readlist, read.csv,sep='\t')

print(results)


# combine all results into a single data frame
df <- do.call(rbind, results)

# # plot the results
distmode <- sapply(readlist, function(x) {regmatches(x, regexec("(global|local)", x))[[1]][1]})

df$distmode<-distmode


print(colnames(df))
 # [1] "s"         "h.m.s"     "max_rss"   "max_vms"   "max_uss"   "max_pss"
 # [7] "io_in"     "io_out"    "mean_load" "cpu_time"  "distmode"


ggplot(data = df, aes(x = distmode, y = s, colour = distmode)) +
	geom_boxplot() +
	labs(title = "Decluster Benchmark Results", x = "Sample", y = "Time (seconds)") +
	theme_bw()

# save the plot
ggsave(commandArgs(trailingOnly = TRUE)[length(commandArgs(trailingOnly = TRUE))], width = 8, height = 6)
