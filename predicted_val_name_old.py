
import tensorflow as tf
import io
import sys, argparse
import os
from PIL import Image
import numpy as np
#tf_files=os.listdir(tfrecord_dir)
#num_samples = 0
#tfrecord=sys.argv[0]
#file=sys.argv[1]
filenames=[]


'''function to check if input files exists and valid''' 	
def input_file_validity(file):
	'''Validates the input files'''
	if os.path.exists(file)==False:
		raise argparse.ArgumentTypeError( '\nERROR:Path:\n'+file+':Does not exist')
	if os.path.isfile(file)==False:
		raise argparse.ArgumentTypeError( '\nERROR:File expected:\n'+file+':is not a file')
	if os.access(file,os.R_OK)==False:
		raise argparse.ArgumentTypeError( '\nERROR:File:\n'+file+':no read access ')
	return file

def argument_parse():
	'''Parses the command line arguments'''
	parser=argparse.ArgumentParser(description='')
	parser.add_argument("-t","--tf_info",help="TFRECORD file",required="True")
	parser.add_argument("-i","--input_info",help="input file",required="True",type=input_file_validity)
	return parser

def main():	
	abspath=os.path.abspath(__file__)
	words = abspath.split("/")
	#print("You are running CNV caller Workflow "+words[len(words) - 2])
	'''reading the config filename'''
	parser=argument_parse()
	arg=parser.parse_args()
	#print("Entered Run Info Config file "+arg.tf_info+"\n\n")
	#print("Entered Tool Info Config file "+arg.input_info+"\n\n")
	label=arg.tf_info.split(".")
	#labelt=label[1].replace(".test.tfrecords","")
	labelt=label[1]
	tfrecord=arg.tf_info
	file_input=arg.input_info	
	for example in tf.python_io.tf_record_iterator(tfrecord):
		result = tf.train.Example.FromString(example)
		for k,v in result.features.feature.items():
			#print(k)
			if k == 'image/name':
				stream=str(v.bytes_list.value[0], 'utf-8')
				filenames.append(stream)
	#print(len(filenames))
	#print(filenames)
	#sys.exit(0)
	fobj = open(file_input)
	#myfile = open(output, mode='wt')
	#fobj.readline()
	num=0
	num0=0
	num1=0
	for file in fobj:
		file = file.strip()
		p = file.split(" ")
		#myfile.write(p[0]+"\t"+p[1]+"\t"+p[2]+"\t"+p[3]+"\t"+avg+"\n")
		#print(filenames[num]+"\t"+file+"\t"+labelt)
		print(filenames[num]+"\t"+labelt+"\t"+p[0]+"\t"+p[1])
		if file == "0":
			num0=num0+1
		if file == "1":
			num1=num1+1	
		num=num+1
	#print(tfrecord+"\t"+labelt+"\t"+str(num)+"\t"+str(num0)+"\t"+str(num1))	
	fobj.close()

		
if __name__ == "__main__":
	main()
				
