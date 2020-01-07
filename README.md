# Lung_DL

Image classification on Lung DL dataset

## 1. Datasets
```
Lung DL Dataset Metadata
head Lung_Meta_Zhifu_May10.txt
BlindCaseNum    TumorType       ProcedureType   PDL1IHC%        PDL1ExpGRP      ImmuneCellPDL1%
AC1     ADC     Biopsy  99      51-100% <5
AC10    ADC     Biopsy  95      51-100% <5
AC100   ADC     Biopsy  0       <1%     <5
AC101   ADC     Surgery 0       <1%     <5
AC102   ADC     Biopsy  0       <1%     <5
AC103   ADC     Biopsy  0       <1%     <5
AC104   ADC     Biopsy  30      26-50%  <5
AC105   ADC     Biopsy  0       <1%     <5
AC106   ADC     Biopsy  70      51-100% ≥5

```

## 2. Preprocessing and Create TF Records
```
Create_TCGA_ImagePatches_level2.py:Script to create Level3 256 X 256 image patches and create TF Records including eval datasets
Create_TCGA_TF.sh: Script to iterate through svs files and convert them to tfrecords
Ex:

python /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/Lung_DL/Create_TCGA_ImagePatches_level3.py -i /dtascfs/DL/lungcancer/AD_SC_PDL1/LOG/AC100.txt -p /dtascfs/DL/lungcancer/AD_SC_PDL1/PATCHES -o /dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level3 -s 224

```

## 3. Running models from models/slim 
```
Downloaded all the models and checkpoints from https://github.com/tensorflow/models/tree/master/research/slim#pre-trained-models

Different models
 cat run_models.txt

/resnet_v1_50_2016_08_28/resnet_v1_50.ckpt        resnet_v1_50    resnet_v1_50/logits
/resnet_v1_152_2016_08_28/resnet_v1_152.ckpt      resnet_v1_152   resnet_v1_152/logits

Specific changes needed to run the models
resnet_v1_50 : image resize was needed to 224 X 224
resnet_v1_152 : image resize was needed to 224 X 224

Run 1: script = tcga_run_models.sh
starting model : downloaded resnet_v1_50
Learning rate : 0.01
steps : 500000
LOGDIR=/dtascfs/DL/lungcancer/AD_SC_PDL1/results/Lung_DL1
Obtained eval: 69.99
Ex: python /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/models/research/slim/train_image_classifier.py --train_dir=/dtascfs/DL/lungcancer/AD_SC_PDL1/results/Lung_DL1_level3/resnet_v1_50/train --dataset_name=tcga --dataset_split_name=train --dataset_dir=/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level3/FINAL_TF --model_name=resnet_v1_50 --log_every_n_steps 100 --num_clones 2 --max_number_of_steps 70000 --batch_size 32 --checkpoint_path /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/models/research/slim/checkpoints/resnet_v1_50_2016_08_28/resnet_v1_50.ckpt --checkpoint_exclude_scopes=resnet_v1_50/logits --trainable_scopes=resnet_v1_50/logits --preprocessing_name tcga --optimizer rmsprop --learning_rate 0.01 --train_image_size 224

```

## 4. Optimization step: Rerunning models from models/slim 
```

Run 2:script = tcga_run_models.sh
starting model : model from step 3
Learning rate : 0.001
steps : 500000
SLIM_SCRIPTS=/dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/models/research/slim
Obtained eval: 
Ex: python /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/models/research/slim/train_image_classifier.py --train_dir=/dtascfs/DL/lungcancer/AD_SC_PDL1/results/Lung_DL1_level3/resnet_v1_50/train --dataset_name=tcga --dataset_split_name=train --dataset_dir=/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level3/FINAL_TF --model_name=resnet_v1_50 --log_every_n_steps 100 --num_clones 2 --max_number_of_steps 70000 --batch_size 32 --checkpoint_path /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/models/research/slim/checkpoints/resnet_v1_50_2016_08_28/resnet_v1_50.ckpt --checkpoint_exclude_scopes=resnet_v1_50/logits --trainable_scopes=resnet_v1_50/logits --preprocessing_name tcga --optimizer rmsprop --learning_rate 0.001 --train_image_size 224
```