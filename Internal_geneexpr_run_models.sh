set -x
SCRIPTS=/dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/Lung_DL
cd $SCRIPTS
source Internal_geneexpr_run_models.cfg
#export PYTHONPATH=$PYTHONPATH:/projects/shart/anaconda3/envs/WSItools/lib/python3.6/site-packages
#export LD_LIBRARY_PATH=/projects/shart/anaconda3/envs/WSItools/lib/:$LD_LIBRARY_PATH
#export CUDA_VISIBLE_DEVICES=2,3
IFS=$'\n'
#for i in `cat $SCRIPTS/tcga_run_models.retrain.txt|head -1|tail -1`
for i in `cat $SCRIPTS/tcga_run_models.txt|head -25|tail -1`
do
	CHECK_POINT_PATH=`echo $i|cut -f1`
	MODELNAME=`echo $i|cut -f2`
	SCOPE=`echo $i|cut -f3`
	TRAIN_LOGDIR=$LOGDIR"/"$MODELNAME"/train"
	EVAL_LOGDIR=$LOGDIR"/"$MODELNAME"/eval"
	mkdir -p $LOGDIR"/"$MODELNAME
	sudo chmod -R 777 $LOGDIR"/"$MODELNAME"/train/*"
	sudo chmod -R 777 $LOGDIR"/"$MODELNAME"/eval/*"
	
	EVAL_test_LOGDIR=$LOGDIR"/"$MODELNAME"/test"
	sudo chmod -R 777 $LOGDIR"/"$MODELNAME"/test/*"
	
	train_eval_LOGDIR=$LOGDIR"/"$MODELNAME"/train_eval"
	sudo chmod -R 777 $LOGDIR"/"$MODELNAME"/train_eval/*"
	
	
	for ((step=10000;step<=150000;step=step+10000)); 
	do
		#for ((try=1;try<=10;try=try+1));
		#do	
			echo $CHECK_POINT_PATH $MODELNAME $SCOPE $TRAIN_LOGDIR $EVAL_LOGDIR $step $try
			python $SLIM_SCRIPTS/train_image_classifier.py \
			 --train_dir=${TRAIN_LOGDIR} \
			 --dataset_name=${DATASET_NAME}\
			 --dataset_split_name=train\
			 --dataset_dir=${DATASET_DIR} \
			 --model_name=${MODELNAME} \
			 --log_every_n_steps 100 \
			 --num_clones 2\
			 --max_number_of_steps ${step} \
			 --batch_size 32 \
			 --checkpoint_path $CHECK_POINT_PATH \
			 --checkpoint_exclude_scopes=${SCOPE} \
			 --preprocessing_name tcga \
			 --optimizer rmsprop \
			 --learning_rate 0.001 \
			 --train_image_size 224 
			# --trainable_scopes=${SCOPE} 
			#exit
			ret=$?
			#if [ $ret -eq 0 ]; then
			#	try=11
			#fi
		#done
		if [ $ret -ne 0 ]; then
			echo "training step failed"
			exit 1
		fi
		#exit
		
		python $SLIM_SCRIPTS/eval_image_classifier.py \
		--checkpoint_path ${TRAIN_LOGDIR} \
		--eval_dir ${train_eval_LOGDIR} \
		--dataset_name=${DATASET_NAME} \
		--dataset_split_name=train \
		--dataset_dir=${DATASET_DIR} \
		--model_name=${MODELNAME} \
		--batch_size 32 \
		--preprocessing_name bh_bach  --eval_image_size 224
		ret=$?
		if [ $ret -ne 0 ]; then
			echo "train eval step failed"
			exit 1
		fi
		
		python $SLIM_SCRIPTS/eval_image_classifier.py \
		--checkpoint_path ${TRAIN_LOGDIR} \
		--eval_dir ${EVAL_LOGDIR} \
		--dataset_name=${DATASET_NAME} \
		--dataset_split_name=test \
		--dataset_dir=${DATASET_DIR} \
		--model_name=${MODELNAME} \
		--batch_size 32 \
		--preprocessing_name bh_bach  --eval_image_size 224
		ret=$?
		if [ $ret -ne 0 ]; then
			echo "eval step failed"
			exit 1
		fi
		
		python $SLIM_SCRIPTS/eval_image_classifier.py \
		--checkpoint_path ${TRAIN_LOGDIR} \
		--eval_dir ${EVAL_test_LOGDIR} \
		--dataset_name=${DATASET_NAME} \
		--dataset_split_name=val \
		--dataset_dir=${DATASET_DIR} \
		--model_name=${MODELNAME} \
		--batch_size 32 \
		--preprocessing_name bh_bach  --eval_image_size 224
		ret=$?
		if [ $ret -ne 0 ]; then
			echo "eval step step failed"
			exit 1
		fi
	done	
done
