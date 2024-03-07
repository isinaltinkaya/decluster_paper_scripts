library(dplyr)
library(tidyr)
d<-read.csv("/home/isin/Mount/decluster/benchmark_2211/results/benchmark/merged_benchmark")



library("ggplot2")
ggplot(
	       df,
		       aes(
				         tool,
						       seconds,
						       colour = tool,
							         shape = tool,
							         group = tool
									     )
		     ) +
    geom_boxplot() +
	    geom_point(size = 2) 



	ggplot(d, aes(x = tool, y = s)) +
		  ggtitle("Task run times in seconds") +
		    xlab("task") +
			  ylab("time in seconds") +
			    geom_bar(stat = "identity") +
				  coord_flip()

			  ggplot(d, aes(x = tool, y = max_rss)) +
				    ggtitle("Maximum task RAM usage") +
					  xlab("tool") +
					    ylab("maximum RAM usage in megabytes") +
						  geom_boxplot()+
						    coord_flip()+
							  theme_bw()+
							    geom_point(shape=1)

