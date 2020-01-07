set -x
temp_dir=/dtascfs/DL/lungcancer/AD_SC_PDL1/LOG
FINAL_COMBINED_FILE=/dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/Lung_DL/Lung_Meta_Zhifu_May10.txt
PATCH_DIR=/dtascfs/DL/lungcancer/AD_SC_PDL1/PATCHES
TF_DIR=/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level3
Patch_size=224
cd /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/Lung_DL
IFS=$'\n'
#for i in `cat /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/Lung_DL/Lung_Meta_Zhifu_May10.txt|tail -292 |grep -v -P "^BlindCaseNum"`
for i in `cat /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/Lung_DL/Lung_Meta_Zhifu_May10.txt|grep -v -P "^BlindCaseNum|AC170\t"`
do
	samp=`echo $i|cut -f1`
	subtype=`echo $i|cut -f2`
	svs_file="/dtascfs/DL/lungcancer/AD_SC_PDL1/imagedata/"$samp".svs"
	if [ -f $svs_file  ]; then
		echo -e "$samp\t$subtype\t$svs_file" > $temp_dir/$samp.txt
		#python /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/Lung_DL/Create_TCGA_ImagePatches_level2.py -i $temp_dir/$SGE_TASK_ID.txt -p $PATCH_DIR -o $TF_DIR -s $Patch_size
		python /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/Lung_DL/Create_TCGA_ImagePatches_level3.py -i $temp_dir/$samp.txt -p $PATCH_DIR -o $TF_DIR -s $Patch_size 
		#exit
		mut=$?
		if [ $mut -ne 0 ]; then
			echo $mut
			exit 1
		fi
	fi
done
