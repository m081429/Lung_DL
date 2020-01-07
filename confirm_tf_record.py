
#tfrecord_dir='/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS/FINAL_TF/'
#tfrecord_dir='/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level3/FINAL_TF_tmp'
tfrecord_dir='/dtascfs/DL/lungcancer/AD_SC_PDL1/LUNG_TCGA_LEVEL2/TFRECORDS'
tfrecord_dir='/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level1_geneexpr/Final_TF'
tfrecord_dir='/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level2_geneexpr/Final_TF_level2'
import tensorflow as tf
import io
import sys
from PIL import Image
import numpy as np
import os
import subprocess
#tf_files=['AC49.ADC.train.tfrecords','SC52.SQCC.train.tfrecords']
#tf_files=['AC101.ADC.test.tfrecords']
#tf_files=['TCGA-NK-A7XE-01Z-00-DX1.TCGA-LUSC.1.train.tfrecords']
tf_files=os.listdir(tfrecord_dir)
for i in tf_files:
	if '.tfrecords' in i:
		print(i+" subtype")
		tfrecord=tfrecord_dir+'/'+i
		for example in tf.python_io.tf_record_iterator(tfrecord):
			result = tf.train.Example.FromString(example)
			for k,v in result.features.feature.items():
				if k == 'image/encoded':
					print(k, "Skipping...")
					#stream=io.BytesIO(v.bytes_list.value[0])
					#img = Image.open(stream)
					#img.save("sampletf.png", "png")
					#cmd='file sampletf.png'
					#subprocess.call(cmd, shell=True)
					#sys.exit(0)
					#res = np.unique(np.asarray(img), return_counts=True)
					#print(k, res)
				elif k == 'image/segmentation/class/encoded':
					stream=io.BytesIO(v.bytes_list.value[0])
					img = Image.open(stream)
					res = np.unique(np.asarray(img), return_counts=True)
					#print(k, res)
				#elif k == 'phenotype/tumor_class':
				#	print(v.bytes_list.value[0])
				else:
					#k=1	
					try:
						print(k, v.bytes_list.value[0])
					except:
						print(k, v.int64_list.value[0])
			sys.exit(0)
