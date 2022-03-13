import pandas as pd
import os

configfile: "config.yml"

pixel_distance=list(range(
	config["pxd_range_start"],
	config["pxd_range_end"]+config["pxd_range_by"],
	config["pxd_range_by"]))


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
		expand("{dataset_id}/decluster_estimate_pxd/{sample}/{sample}_{pxd}.hist.txt",
				dataset_id=config["dataset_id"],
				sample=list(SAMPLES.keys()),
				pxd=pixel_distance),
		expand("{dataset_id}/decluster_local/{sample}/{sample}_{rpxd}.hist.txt",
				dataset_id=config["dataset_id"],
				sample=list(SAMPLES.keys()),
				rpxd=config["recommended_pxd"]),
		expand("{dataset_id}/without_decluster/{sample}/.done.{sample}_without_decluster.table.txt",
				dataset_id=config["dataset_id"],
				sample=list(SAMPLES.keys())),
		expand("{dataset_id}/decluster_global/{sample}/{sample}_{rpxd}.hist.txt",
				dataset_id=config["dataset_id"],
				sample=list(SAMPLES.keys()),
				rpxd=config["recommended_pxd"]),
		expand("{dataset_id}/decluster_estimate_pxd/{sample}/.parsed.{sample}_{pxd}.dupstat.txt",
				dataset_id=config["dataset_id"],
				sample=list(SAMPLES.keys()),
				pxd=pixel_distance),




rule run_decluster_pxd_range:
	input:
		lambda wildcards: SAMPLES[wildcards.sample]
	output:
		"{dataset_id}/decluster_estimate_pxd/{sample}/{sample}_{pxd}.dupstat.txt",
		"{dataset_id}/decluster_estimate_pxd/{sample}/{sample}_{pxd}.hist.txt"
	params:
		decluster=config['decluster_path'],
		xLength=config['xLength'],
		yLength=config['yLength'],
		nTiles=config['nTiles'],
		outbase="{dataset_id}/decluster_estimate_pxd/{sample}/{sample}_{pxd}"
	benchmark:
		"{dataset_id}/benchmark/decluster_estimate_pxd/{sample}_{pxd}_decluster.benchmark.tsv"
	log:
		"{dataset_id}/logs/decluster_estimate_pxd/{sample}_{pxd}_decluster.log"
	shell:
		"( {params.decluster} {input} "
		"-o {params.outbase} "
		"--xLength {params.xLength} "
		"--yLength {params.yLength} "
		"--nTiles {params.nTiles} "
		"-p {wildcards.pxd} "
		"-m "
		"-q 30 "
		"-w -0 ) 2> {log}"

rule collect_estimate_pxd_results:
	input:
		"{dataset_id}/decluster_estimate_pxd/{sample}/{sample}_{pxd}.dupstat.txt",
	output:
		"{dataset_id}/decluster_estimate_pxd/{sample}/.parsed.{sample}_{pxd}.dupstat.txt"
	params:
		run_collect="/science/willerslev/users-shared/science-snm-willerslev-pfs488/projects/superduper/WORKINGDIR/WD-22/benchmarking/collect_pxd_extimate_results.sh",
		out="{dataset_id}/decluster_estimate_pxd/estimate_pxd_results.csv"
	shell:
		" {params.run_collect} {input} {wildcards.sample} {wildcards.pxd} {wildcards.dataset_id} >> {params.out} ; "
		" touch {output} "




rule run_decluster_local:
	input:
		lambda wildcards: SAMPLES[wildcards.sample]
	output:
		"{dataset_id}/decluster_local/{sample}/{sample}_{rpxd}.dupstat.txt",
		"{dataset_id}/decluster_local/{sample}/{sample}_{rpxd}.hist.txt"
	params:
		decluster=config['decluster_path'],
		outbase="{dataset_id}/decluster_local/{sample}/{sample}_{rpxd}"
	benchmark:
		"{dataset_id}/benchmark/decluster_local/{sample}_{rpxd}_decluster.benchmark.tsv"
	log:
		"{dataset_id}/logs/decluster_local/{sample}_{rpxd}_decluster.log"
	shell:
		"( {params.decluster} {input} "
		"--coordType local "
		"-o {params.outbase} "
		"-p {wildcards.rpxd} "
		"-m "
		"-q 30 "
		"-D 2 ) 2> {log}"

rule run_decluster_global:
	input:
		lambda wildcards: SAMPLES[wildcards.sample]
	output:
		"{dataset_id}/decluster_global/{sample}/{sample}_{rpxd}.dupstat.txt",
		"{dataset_id}/decluster_global/{sample}/{sample}_{rpxd}.hist.txt"
	params:
		decluster=config['decluster_path'],
		xLength=config['xLength'],
		yLength=config['yLength'],
		nTiles=config['nTiles'],
		outbase="{dataset_id}/decluster_global/{sample}/{sample}_{rpxd}"
	benchmark:
		"{dataset_id}/benchmark/decluster_global/{sample}_{rpxd}_decluster.benchmark.tsv"
	log:
		"{dataset_id}/logs/decluster_global/{sample}_{rpxd}_decluster.log"
	shell:
		"( {params.decluster} {input} "
		"-o {params.outbase} "
		"--coordType global "
		"--xLength {params.xLength} "
		"--yLength {params.yLength} "
		"--nTiles {params.nTiles} "
		"-p {wildcards.rpxd} "
		"-m "
		"-q 30 "
		"-D 2 ) 2> {log}"

rule filter_input:
	input:
		lambda wildcards: SAMPLES[wildcards.sample]
	output:
		"{dataset_id}/filteredData/{sample}_filtered.bam",
	log:
		"{dataset_id}/logs/without_decluster/{sample}_filterInput.log"
	params:
		samtools=config['samtools_path']
	shell:
		"( {params.samtools} view -h -F 4 -F 1 -q 30 {input} -o {output} ) 2> {log} "


rule without_decluster:
	input:
		"{dataset_id}/filteredData/{sample}_filtered.bam",
	output:
		"{dataset_id}/without_decluster/{sample}/.done.{sample}_without_decluster.table.txt",
	log:
		"{dataset_id}/logs/without_decluster/{sample}_preseq.log"
	benchmark:
		"{dataset_id}/benchmark/without_decluster/{sample}_preseq.benchmark.tsv"
	params:
		preseq=config['preseq_path'],
		lcextrap_error="{dataset_id}/without_decluster/lcextrap_error.txt",
		lcextrap_success="{dataset_id}/without_decluster/lcextrap_success.txt",
		lcextrap_unknownerror="{dataset_id}/without_decluster/lcextrap_unknownerror.txt",
		outfile="{dataset_id}/without_decluster/{sample}/{sample}_without_decluster.table.txt",
	run:
		import subprocess
		shell( "touch " + output[0] + ";")
		p=subprocess.Popen("( " + params.preseq + " lc_extrap -B " + input[0] + " -o " + params.outfile + " ) 2> " +log[0] + ";", shell=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
		stdout, stderr= p.communicate()
		if p.returncode == 1:
			shell(" echo " + wildcards.sample + " >> "+ params.lcextrap_error + ";")
		elif p.returncode == 0:
			shell(" echo " + wildcards.sample + " >> "+ params.lcextrap_success)
		else:
			shell(" echo " + wildcards.sample + " >> "+ params.lcextrap_unknownerror)



#rule plot_results:
	#input:
		#"{sample}"
	#params:
		#"{dataset_id}/plots/"
	#shell:
		#" Rscript --vanilla "
		#" scripts/plot_lc_extrap.R "
		#" {wildcards.dataset_id} "
		#" {input} "
		#" {params.out_dir}"
