#tfrecord_dir='/research/bsi/projects/PI/tertiary/Sun_Zhifu_zxs01/s4331393.GTEX/processing/naresh/Digital_path/tfrecords/Level2_selected_TP53/'
#tfrecord_dir='/research/bsi/projects/PI/tertiary/Sun_Zhifu_zxs01/s4331393.GTEX/processing/naresh/Digital_path/lung_tcga_svs/TF_OUTPUT/TFRECORDS/'
#tfrecord_dir='/research/bsi/projects/PI/tertiary/Sun_Zhifu_zxs01/s4331393.GTEX/processing/naresh/Digital_path/BRAF_TIFF/Final_TF/'
#tfrecord_dir='/data/Naresh/PhilipsSDK/CodeSample_N/output/tfrecords/'
tfrecord_dir='/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level2_geneexpr/Final_TF_level2'
import tensorflow as tf
import io
import sys
from PIL import Image
import numpy as np
import os
#tf_files=['bh_bach_train_bach.tfrecords','bh_bach_train_bh.tfrecords','bh_bach_val_bach.tfrecords','bh_bach_val_bh.tfrecords']
#tf_files=['TCGA-A2-A04W.tfrecords']
#tf_files=['TCGA-37-4132-01Z-00-DX1.tfrecords']
tf_files=os.listdir(tfrecord_dir)
for i in tf_files:
	if 'tfrecord' in i:
		tfrecord=tfrecord_dir+'/'+i
		#print(tfrecord)
		#sys.exit(0)
		for example in tf.python_io.tf_record_iterator(tfrecord):
			result = tf.train.Example.FromString(example)
			z1=100
			z2="NA"
			z3="NA"			
			for k,v in result.features.feature.items():
				if k == 'image/encoded':
					#print(k, "Skipping...")
					z=1
				elif k == 'image/segmentation/class/encoded':
					stream=io.BytesIO(v.bytes_list.value[0])
					#img = Image.open(stream)
					#res = np.unique(np.asarray(img), return_counts=True)
					#print(k, res)
				else:
					try:
						#print(k, v.bytes_list.value[0])
						if k=="image/name":
							z1=v.bytes_list.value[0]
							z1=z1.decode("utf-8")
						if k=='phenotype/geneexpr_cate':
							z2=v.int64_list.value[0]
					except:
						#print(k, v.int64_list.value[0])
						if k=='phenotype/geneexpr_cate':
							z2=v.int64_list.value[0]
			print(str(z2)+"\t"+i+"\t"+str(z1))	
			#sys.exit(0)
