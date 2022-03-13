import pandas as pd
import os

configfile: "config.yml"



def read_filelist(read_from,cut_ext_list):

	read_to={}
	input_read_from = open(read_from,"r")
	read_from_list = [line.rstrip('\n') for line in input_read_from]
	input_read_from.close()

	for sample_fullpath in read_from_list:
		sample_basename=os.path.basename(sample_fullpath.strip())
		for extension in cut_ext_list:
			sample_basename=sample_basename.replace(extension,"")
			
		read_to[sample_basename] = sample_fullpath
	return read_to


IN_EXT=[".bam",".cram"]

SAMPLES=read_filelist(config["sample_list"],IN_EXT)



rule all:
	input:
		expand("{dataset_id}/decluster_getConf/{sample}_conf.txt",
				dataset_id=config["dataset_id"],
				sample=list(SAMPLES.keys()))



rule run_decluster_getConf:
	input:
		lambda wildcards: SAMPLES[wildcards.sample]
	output:
		"{dataset_id}/decluster_getConf/{sample}_conf.txt",
	params:
		decluster=config['decluster_path'],
	shell:
		"{params.decluster} --getConf {input} 2> {output} "
