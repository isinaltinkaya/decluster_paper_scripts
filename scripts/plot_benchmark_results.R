library(dplyr)
#library(tidyr)
library(ggplot2)

asDirPath <- function(string){
  if(!endsWith(string,"/"))string<-paste0(string,"/")
  if(!dir.exists(string))warning("Directory does not exist, will exit!")
  return(string)
}


PDIR="/home/isin/Projects/decluster/decluster_benchmark_plots_2212/v2/"
PDIR=asDirPath(PDIR)

d<-read.csv("/home/isin/Mount/decluster/benchmark_2211/results/benchmark/merged_benchmark_v2")


# colname	type (unit)	description
# s	float (seconds)	Running time in seconds
# h:m:s	string (-)	Running time in hour, minutes, seconds format
# max_rss	float (MB)	Maximum "Resident Set Size”, this is the non-swapped physical memory a process has used.
# max_vms	float (MB)	Maximum “Virtual Memory Size”, this is the total amount of virtual memory used by the process
# max_uss	float (MB)	“Unique Set Size”, this is the memory which is unique to a process and which would be freed if the process was terminated right now.
# max_pss	float (MB)	“Proportional Set Size”, is the amount of memory shared with other processes, accounted in a way that the amount is divided evenly between the processes that share it (Linux only)
# io_in	float (MB)	the number of MB read (cumulative).
# io_out	float (MB)	the number of MB written (cumulative).
# mean_load	float (-)	CPU usage over time, divided by the total running time (first row)
# cpu_time	float(-)	CPU time summed for user and system




MB_to_GB <- function(x) x/1024

format_hms <- function(x) {
  as.POSIXct(format(x, format = "%H:%M:%S"), format = "%H:%M:%S")
}


d <- d |> dplyr::rename(
  "seconds" = s,
  "max_rss_mb" = max_rss,
  "max_vms_mb" = max_vms,
  "max_uss_mb" = max_uss,
  "max_pss_mb" = max_pss,
  "io_in_mb" = io_in,
  "io_out_mb" = io_out,
  "time_hms" = h.m.s,
)


d$max_rss_gb <- MB_to_GB(d$max_rss_mb)
d$max_vms_gb <- MB_to_GB(d$max_vms_mb)
d$max_uss_gb <- MB_to_GB(d$max_uss_mb)
d$max_pss_gb <- MB_to_GB(d$max_pss_mb)
d$io_in_gb <- MB_to_GB(d$io_in_mb)
d$io_out_gb <- MB_to_GB(d$io_out_mb)
d$time_hms <- format_hms(d$time_hms)

p <- ggplot(d, aes(color = tool, x = id, y = seconds)) +
  xlab("") +
  ylab("Runtime (seconds)") +
  geom_boxplot()+
  coord_flip()+
  theme_bw()+
  geom_point(shape=1,alpha=0.5)+
  theme(legend.position="top")+labs(color="Tool")
p
ggsave(paste0(PDIR,"decluster_bm_221209_plot1.png"),p)

p <- ggplot(d, aes(color = tool, x = id, y = max_rss_mb)) +
  xlab("") +
  ylab("Maximum RAM usage (MB)") +
  geom_boxplot()+
  coord_flip()+
  theme_bw()+
  geom_point(shape=1,alpha=0.5)+
  theme(legend.position="top")+labs(color="Tool")

p
ggsave(paste0(PDIR,"decluster_bm_221209_plot2.png"),p)



p <- ggplot(d, aes(color = tool, x = id, y = max_rss_gb)) +
  xlab("") +
  ylab("Maximum RAM usage (GB)") +
  geom_boxplot()+
  coord_flip()+
  theme_bw()+
  geom_point(shape=1,alpha=0.5)+
  theme(legend.position="top")+labs(color="Tool")

p


ggsave(paste0(PDIR,"decluster_bm_221209_plot3.png"),p)



p<-ggplot(d, aes(color = tool, x = id, y = time_hms)) +
  xlab("") +
  ylab("Runtime (H:M:S)") +
  geom_boxplot()+
  coord_flip()+
  theme_bw()+
  geom_point(shape=1,alpha=0.5)+
  scale_y_datetime(date_labels = "%H:%M:%S",date_breaks = "5 min")+
  theme(legend.position="top")+labs(color="Tool")

p



ggsave(paste0(PDIR,"decluster_bm_221209_plot4.png"),p)



p <- ggplot(d, aes(color = tool, x = id, y = max_vms_mb)) +
  xlab("") +
  ylab("Maximum virtual memory usage (MB)") +
  geom_boxplot()+
  coord_flip()+
  theme_bw()+
  geom_point(shape=1,alpha=0.5)+
  theme(legend.position="top")+labs(color="Tool")

p


ggsave(paste0(PDIR,"decluster_bm_221209_plot5.png"),p)



p <- ggplot(d, aes(color = tool, x = id, y = max_vms_gb)) +
  xlab("") +
  ylab("Maximum virtual memory usage (GB)") +
  geom_boxplot()+
  coord_flip()+
  theme_bw()+
  geom_point(shape=1,alpha=0.5)+
  theme(legend.position="top")+labs(color="Tool")

p

ggsave(paste0(PDIR,"decluster_bm_221209_plot6.png"),p)




p <- ggplot(d, aes(color = tool, x = id, y = io_in_mb)) +
  xlab("") +
  ylab("Cumulative number of MB read during process") +
  geom_boxplot()+
  coord_flip()+
  theme_bw()+
  geom_point(shape=1,alpha=0.5)+
  theme(legend.position="top")+labs(color="Tool")

p

ggsave(paste0(PDIR,"decluster_bm_221209_plot7.png"),p)



p <- ggplot(d, aes(color = tool, x = id, y = io_in_gb)) +
  xlab("") +
  ylab("Cumulative number of GB read during process") +
  geom_boxplot()+
  coord_flip()+
  theme_bw()+
  geom_point(shape=1,alpha=0.5)+
  theme(legend.position="top")+labs(color="Tool")

p

ggsave(paste0(PDIR,"decluster_bm_221209_plot8.png"),p)





p <- ggplot(d, aes(color = tool, x = id, y = io_out_mb)) +
  xlab("") +
  ylab("Cumulative number of MB written during process") +
  geom_boxplot()+
  coord_flip()+
  theme_bw()+
  geom_point(shape=1,alpha=0.5)+
  theme(legend.position="top")+labs(color="Tool")

p

ggsave(paste0(PDIR,"decluster_bm_221209_plot9.png"),p)



p <- ggplot(d, aes(color = tool, x = id, y = io_out_gb)) +
  xlab("") +
  ylab("Cumulative number of GB written during process") +
  geom_boxplot()+
  coord_flip()+
  theme_bw()+
  geom_point(shape=1,alpha=0.5)+
  theme(legend.position="top")+labs(color="Tool")

p

ggsave(paste0(PDIR,"decluster_bm_221209_plot10.png"),p)


