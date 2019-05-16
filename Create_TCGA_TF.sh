#! /bin/bash
#$ -q 1-day
#$ -l h_vmem=30G
#$ -M prodduturi.naresh@mayo.edu
#$ -t 2-372:1
#$ -m abe
#$ -V
#$ -cwd
# #$ -pe threaded 4
#$ -j y
#$ -o /research/bsi/projects/lung/s211913.dlmp_lung_zhifu_dl/processing/LOG

set -x
temp_dir=/research/bsi/projects/lung/s211913.dlmp_lung_zhifu_dl/processing/LOG
FINAL_COMBINED_FILE=/research/bsi/projects/lung/s211913.dlmp_lung_zhifu_dl/processing/Lung_Meta_Zhifu_May10.txt
PATCH_DIR=/research/bsi/projects/lung/s211913.dlmp_lung_zhifu_dl/processing/PATCHES
TF_DIR=/research/bsi/projects/lung/s211913.dlmp_lung_zhifu_dl/processing/TFRECORDS
Patch_size=512
cd /research/bsi/projects/lung/s211913.dlmp_lung_zhifu_dl/processing/Lung_DL
SGE_TASK_ID=105
#SGE_TASK_ID=2
#for SGE_TASK_ID in {2..372}
#do
samp=`head -$SGE_TASK_ID $FINAL_COMBINED_FILE|tail -1|cut -f1`
subtype=`head -$SGE_TASK_ID $FINAL_COMBINED_FILE|tail -1|cut -f2`
svs_file="/research/bsi/projects/lung/s211913.dlmp_lung_zhifu_dl/processing/lungAD_wsi_tmp/"$samp".svs"
if [ -f $svs_file  ]; then
	#echo -e "$samp\t$subtype\t$svs_file" >> k.txt
	source /research/bsi/tools/biotools/tensorflow/1.12.0/PKG_PROFILE
	source /research/bsi/tools/biotools/openslide/3.4.1/PKG_PROFILE
	source /research/bsi/tools/biotools/tensorflow/1.12.0/miniconda/bin/activate tf-gpu-cuda8
	echo -e "$samp\t$subtype\t$svs_file" > $temp_dir/$SGE_TASK_ID.txt
	python /research/bsi/projects/lung/s211913.dlmp_lung_zhifu_dl/processing/Lung_DL/Create_TCGA_ImagePatches_level2.py -i $temp_dir/$SGE_TASK_ID.txt -p $PATCH_DIR -o $TF_DIR -s $Patch_size
	mut=$?
	if [ $mut -ne 0 ]; then
		echo $mut
		exit 1
	fi
	conda deactivate
fi
#done
