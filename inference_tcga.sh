set -x
IMAGE_SIZE=224
#DATADIR=/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level3/FINAL_TF
MODELNAME="resnet_v1_50"
#TRAIN_LOGDIR="/dtascfs/DL/lungcancer/AD_SC_PDL1/results/Lung_DL1_level3/resnet_v1_50/train/"
#EVAL_LOGDIR="/dtascfs/DL/lungcancer/AD_SC_PDL1/results/Lung_DL1_level3/resnet_v1_50/eval/"
#DATADIR=/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS/FINAL_TF
DATADIR=/dtascfs/DL/lungcancer/AD_SC_PDL1/LUNG_TCGA_LEVEL2/FINAL_TFRECORDS-400
#TRAIN_LOGDIR="/dtascfs/DL/lungcancer/AD_SC_PDL1/results/Lung_DL1_retrain_ALL/resnet_v1_50_FineTune_no_tr_scope_learn_rate_1e_3/train/"
#EVAL_LOGDIR="/dtascfs/DL/lungcancer/AD_SC_PDL1/results/Lung_DL1_retrain_ALL/resnet_v1_50_FineTune_no_tr_scope_learn_rate_1e_3/eval/"
TRAIN_LOGDIR="/dtascfs/DL/lungcancer/AD_SC_PDL1/results/Lung_TCGA_Level2-400/resnet_v1_50/train/"
EVAL_LOGDIR="/dtascfs/DL/lungcancer/AD_SC_PDL1/results/Lung_TCGA_Level2-400/resnet_v1_50/eval/"
echo $MODELNAME $TRAIN_LOGDIR $EVAL_LOGDIR $IMAGE_SIZE $DATASET_DIR
SCRIPTS=/dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/Lung_DL
SLIM_SCRIPTS=/dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/models/research/slim
#DATASET_DIR=/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level3/FINAL_TF_tmp
DATASET_DIR=/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS/FINAL_TF_tmp
cd $SCRIPTS

#for i in `ls $DATADIR|grep ".train."`
#IFS=$'\n'
#for i in `cat inference_input.txt|tail -95`
for i in `cat inference_input_level2_tcga.txt`
do
	echo $i
	rm $DATASET_DIR/*tfrecords
	cp $DATADIR/$i $DATASET_DIR 
	python $SLIM_SCRIPTS/inference2.py --checkpoint_path ${TRAIN_LOGDIR} --eval_dir ${EVAL_LOGDIR} --dataset_name=tcga --dataset_split_name=tf --dataset_dir=${DATASET_DIR} --model_name=${MODELNAME} --batch_size 1 --preprocessing_name tcga  --eval_image_size $IMAGE_SIZE > k.txt 2>&1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "inference step failed"
		exit 1
	fi
	
	#exit
	#grep -P "^\[0\]|^\[1\]" k.txt|sed -e 's/\[//g'|sed -e 's/\]//g'	> k1.txt
	#grep -P "^\[\[" k.txt|sed -e 's/\[\[//g'|sed -e 's/\]\]//g'> k1.txt
    #grep -P "^\[\[" k.txt|tr ']' '\n'|grep -P "^\["|sed -e 's/\[//g'> k1.txt
	grep -P "^\[" k.txt|grep -v -P "^\['"|tr ']' '\n'|grep -P "^\["|sed -e 's/\[//g'> k1.txt
	mv k1.txt k.txt
	#echo "python /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/Lung_DL/predicted_val_name.py -t $DATASET_DIR/$i -i k.txt"
	#exit
	#python /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/Lung_DL/predicted_val_name.py -t $DATASET_DIR/$i -i k.txt >> level3_res_test.txt
	echo "python /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/Lung_DL/predicted_val_name.py -t $DATASET_DIR/$i -i k.txt >> level2_res.txt"
	python /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/Lung_DL/predicted_val_name.py -t $DATASET_DIR/$i -i k.txt >> tcga_level2_res.txt
	rm $DATASET_DIR/$i k.txt
	#exit
done
