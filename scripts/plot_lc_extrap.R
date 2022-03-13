#!/usr/bin/Rscript --vanilla
library(ggplot2)
library(dplyr)





args<-commandArgs(trailingOnly=TRUE)

analysis_dir<-args[1]
sample_id<-args[2]
out_dir<-args[3]



asDirPath <- function(string){
	if(!endsWith(string,"/"))string<-paste0(string,"/")
	if(!dir.exists(string))warning("Directory does not exist, will exit!")
	return(string)
}

read_lc_table <- function(analysis_dir, sample_id, lc_nrow=0, analysis_id){

	sample_results_dir<-asDirPath(paste0(asDirPath(analysis_dir),analysis_id,"/",sample_id))

	lc_file<-list.files(path=sample_results_dir, pattern=".*\\.table.txt$",full.names = T)
	#if without defect mode failed, fallback to defect mode result
	if( length(lc_file) == 0){lc_file<-list.files(path=sample_results_dir, pattern=".*\\.table_defect.txt$",full.names = T)}

	lc<-read.table(file=lc_file, header=T)
	file_id<-basename(lc_file)
	sample<-strsplit(file_id, ".table.txt")[[1]][1]

	# if not set read all
	# if set read the first <lc_nrow> lines
	if (lc_nrow != 0){
		lc<-lc[1:lc_nrow+1,]
	}
	lc$sample<-sample
	lc$analysis<-analysis_id

	return(lc)
}






library_id<-paste0(strsplit(sample_id,"_")[[1]][1:8],collapse="_")


merged <- read.csv(paste0(asDirPath(analysis_dir),"merged_total_distinct.csv"))
persample <- read.csv(paste0(asDirPath(analysis_dir),"persample_total_distinct.csv"))
colnames(persample)<-c("SAMPLE","SAMPLE_OBSERVED_TOTAL_READS","SAMPLE_OBSERVED_DISTINCT_READS","ANALYSIS_TYPE")


### Set maximum extrapolation to load to double of the total merged library size
lc_nrow <- (merged[merged$library== library_id ,]$MERGED_TOTAL_READS/1000000)*2


d_global<-read_lc_table(analysis_dir=analysis_dir,
						sample_id=sample_id,
						analysis_id="decluster_global",
						lc_nrow=lc_nrow)


d_global$SAMPLE_TOTAL_READS <- persample[persample$SAMPLE == sample_id & persample$ANALYSIS_TYPE == "decluster_global" ,]$SAMPLE_OBSERVED_TOTAL_READS
d_global$SAMPLE_DISTINCT_READS <- persample[persample$SAMPLE == sample_id & persample$ANALYSIS_TYPE == "decluster_global" ,]$SAMPLE_OBSERVED_DISTINCT_READS


d_local<-read_lc_table(analysis_dir=analysis_dir,
					sample_id=sample_id,
					analysis_id="decluster_local",
					lc_nrow=lc_nrow)

d_local$SAMPLE_TOTAL_READS <- persample[persample$SAMPLE == sample_id & persample$ANALYSIS_TYPE == "decluster_local" ,]$SAMPLE_OBSERVED_TOTAL_READS
d_local$SAMPLE_DISTINCT_READS <- persample[persample$SAMPLE == sample_id & persample$ANALYSIS_TYPE == "decluster_local" ,]$SAMPLE_OBSERVED_DISTINCT_READS



d_without<-read_lc_table(analysis_dir=analysis_dir,
						 sample_id=sample_id,
						 analysis_id="without_decluster",
						 lc_nrow=lc_nrow)


d_without$SAMPLE_TOTAL_READS <- persample[persample$SAMPLE == sample_id & persample$ANALYSIS_TYPE == "without_decluster" ,]$SAMPLE_OBSERVED_TOTAL_READS
d_without$SAMPLE_DISTINCT_READS <- persample[persample$SAMPLE == sample_id & persample$ANALYSIS_TYPE == "without_decluster" ,]$SAMPLE_OBSERVED_DISTINCT_READS


df<-rbind(d_global,d_local,d_without)

df$MERGED_TOTAL_READS<-merged[merged$library== library_id ,]$MERGED_TOTAL_READS
df$MERGED_DISTINCT_READS<-merged[merged$library== library_id ,]$MERGED_DISTINCT_READS


p_i<-ggplot(df, aes(x=TOTAL_READS, y=EXPECTED_DISTINCT))+
	geom_line(aes(colour=analysis))+
	geom_ribbon(aes(x=TOTAL_READS, ymin=LOWER_0.95CI, ymax=UPPER_0.95CI,color=analysis), alpha=0.3)+
	labs(x="Total number of reads",
		 y="Expected distinct reads",
		 title="Preseq library complexity estimates using lc_extrap method",
		 subtitle=paste0("Sample: ",df$sample))+
	theme_bw()+
	theme(legend.position = "bottom") + 
	theme(plot.title = element_text(face="bold", size="14"),
		plot.subtitle = element_text(size="10"))+
	geom_point(aes(x=MERGED_TOTAL_READS,y=MERGED_DISTINCT_READS),shape=4)+
	geom_point(aes(x=SAMPLE_TOTAL_READS,y=SAMPLE_DISTINCT_READS,colour=analysis),shape=3)+
	guides(colour=guide_legend(title = "" ,nrow=3,byrow=TRUE))+
	coord_fixed(ratio = 1, xlim = NULL, ylim = NULL, expand = TRUE)


png(paste0(out_dir,sample_id,"_n",lc_nrow,"_lc_extrap.png"),bg = "white",height = 1000,width = 1000,res=120)
print(p_i)
dev.off()


