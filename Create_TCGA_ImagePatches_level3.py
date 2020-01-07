#!/usr/local/biotools/python/3.4.3/bin/python3
__author__ = "Naresh Prodduturi"
__email__ = "prodduturi.naresh@mayo.edu"
__status__ = "Dev"

import os
import argparse
import sys
import pwd
import time
import subprocess
import re
import shutil
import glob	
import openslide
import numpy as np
from PIL import Image, ImageDraw

import tensorflow as tf
import io
from dataset_utils import * 
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
	parser.add_argument("-p","--patch_dir",help="Patch dir",required="True")
	parser.add_argument("-i","--input_file",help="input file",required="True")
	parser.add_argument("-o","--tf_output",help="output tf dir",required="True")
	parser.add_argument("-s","--patch_size",help="Patch_size",required="True")
	return parser


  
def create_patch(svs,patch_sub_size,patch_dir,samp,p,tf_output):
	#print(svs+' '+str(patch_sub_size)+' '+patch_dir+' '+samp+' '+' '+tf_output)
	
	threshold=200
	level=3
	OSobj = openslide.OpenSlide(svs)
	minx = 0
	miny = 0
	#maxx = OSobj.dimensions[0]
	#maxy = OSobj.dimensions[1]
	#print(OSobj.dimensions)
	#print(OSobj.level_dimensions)
	#print(OSobj.level_downsamples)
	#sys.exit(0)
	#print(OSobj.level_dimensions[1])
	#print(OSobj.level_dimensions[2])
	print("Level_count "+str(OSobj.level_count))
	if OSobj.level_count <= 3:
		print("No enough levels")
		sys.exit(0)
	tf_writer=tf.python_io.TFRecordWriter(tf_output+'/'+samp+'.tfrecords')	
	tmp=OSobj.level_dimensions[level]
	maxx = tmp[0]
	maxy = tmp[1]
	#this factor if required to convert level0 start coordinatess to level2 start coordinates (this is required for OSobj.read_region function)
	multi_factor=OSobj.level_downsamples[level]
	#print(svs+' '+str(patch_sub_size)+' '+patch_dir+' '+str(maxx))
	start_x=minx	
	'''creating sub patches'''	
	'''Iterating through x coordinate'''	
	current_x=0
	filenames=[]
	#num=0
	while start_x+patch_sub_size < maxx:
		'''Iterating through y coordinate'''
		current_y=0
		start_y=miny
		while start_y+patch_sub_size < maxy:
			tmp_start_x=int(round(start_x*multi_factor,0))
			tmp_start_y=int(round(start_y*multi_factor,0))
			try: 
				img_patch = OSobj.read_region((tmp_start_x,tmp_start_y), level, (patch_sub_size, patch_sub_size))
			except:
					print("error in open slide")
					sys.exit(0)
			#img_patch = OSobj.read_region((start_x,start_y), level, (maxx, maxy))
			#num=num+1
			#img_patch.save(patch_dir+'/'+str(num)+'.png', "png")
			#sys.exit(1)
			np_img = np.array(img_patch)
			im_sub = Image.fromarray(np_img)
			width, height = im_sub.size
			'''Change to grey scale'''
			grey_img = im_sub.convert('L')
			'''Convert the image into numpy array'''
			np_grey = np.array(grey_img)
			patch_mean=round(np.mean(np_grey),2)
			patch_std=round(np.std(np_grey),2)
			'''Identify patched where there are tissues'''
			'''tuple where first element is rows, second element is columns'''
			#idx = np.where(np_grey < threshold)
			'''proceed further only if patch has non empty values'''
			#if len(idx[0])>0 and len(idx[1])>0 and width==patch_sub_size and height==patch_sub_size:
			if patch_mean<245 and patch_std>4 and width==patch_sub_size and height==patch_sub_size:
			#if patch_mean<255:
            #if width==patch_sub_size and height==patch_sub_size:
				#print("sucess")
				'''creating patch name'''
				num_patch=samp+"_X_"+str(start_x)+"_"+str(start_x+patch_sub_size)+"_Y_"+str(start_y)+"_"+str(start_y+patch_sub_size)
				filenames.append(num_patch)
				#tmp_png=patch_dir+'/'+num_patch+'.png'
				'''saving image'''
				#im_sub.save(tmp_png, "png")
				#sys.exit(1)
				image_format="png"    
				height=patch_sub_size
				width=patch_sub_size 
				image_name=num_patch     
				sub_type=2
				if p[1] == "ADC":
					sub_type=0
				if	p[1] == "SQCC":
					sub_type=1
				#sub_type=p[1]

				imgByteArr = io.BytesIO()
				im_sub.save(imgByteArr, format='PNG')
				imgByteArr = imgByteArr.getvalue()
				record=image_to_tfexample_tcga(imgByteArr,image_format,int(height),int(width),image_name, sub_type)
				tf_writer.write(record.SerializeToString())
			start_y	= start_y+patch_sub_size
			current_y = current_y+patch_sub_size
		start_x = start_x+patch_sub_size	
		current_x = current_x+patch_sub_size	
	#sys.exit(1)
	tf_writer.close()
	return filenames
	
def main():	
	abspath=os.path.abspath(__file__)
	words = abspath.split("/")
	'''reading the config filename'''
	parser=argument_parse()
	arg=parser.parse_args()
	'''printing the config param'''
	print("Entered INPUT Filename "+arg.input_file)
	print("Entered Output Patch Directory "+arg.patch_dir)
	print("Entered Output TF Directory "+arg.tf_output)
	print("Entered Patch size "+arg.patch_size)

	patch_sub_size=int(arg.patch_size)
	patch_dir=arg.patch_dir
	tf_output=arg.tf_output
	'''Reading TCGA file'''
	fobj = open(arg.input_file)
	#header = fobj.readline()
	for file in fobj:
		file = file.strip()
		p = file.split("\t")
		samp=p[0]
		svs_file=p[2]
		set=p[1]
		filenames=create_patch(svs_file,patch_sub_size,patch_dir,samp,p,tf_output)

	fobj.close()


	
if __name__ == "__main__":
	main()