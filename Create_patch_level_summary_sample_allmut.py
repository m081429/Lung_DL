
import io
import sys, argparse
import os

import numpy as np
import math
from sklearn.metrics import classification_report
from sklearn.metrics import confusion_matrix
from sklearn.metrics import accuracy_score
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
from sklearn.metrics import roc_auc_score
from sklearn import metrics
import statistics
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
	#parser.add_argument("-t","--train",help="TFRECORD file",required="True",type=input_file_validity)
	#parser.add_argument("-p","--test",help="input file",required="True",type=input_file_validity)
	parser.add_argument("-i","--input",help="input file",required="True",type=input_file_validity)
	return parser

def softmax(x,y):
	X=math.exp(x)
	Y=math.exp(y)
	sum=X+Y
	X=round(X/sum,2)
	Y=round(Y/sum,2)
	return [X,Y]
	
def method(samp_list_full,samp_softmax1_list):
	prob_cutoff=0.75
	level=2
	num_patch_in_cat=2
	#print(samp_list_full)
	x_list = list(set([(str(x)).split("_")[2] for x in samp_list_full]))
	y_list = list(set([(str(x)).split("_")[5] for x in samp_list_full]))
	x_list=list(map(int, x_list))
	y_list=list(map(int, y_list))
	x_list.sort()
	y_list.sort()
	#print(x_list)
	#print(y_list)
	x_list_map={}
	for i in range(0,len(x_list)):
		x_list_map[str(x_list[i])]=i
	y_list_map={}
	for i in range(0,len(y_list)):
		y_list_map[str(y_list[i])]=i
		
	#idx=sorted(range(len(samp_softmax1_list)), key=samp_softmax1_list.__getitem__)	
	#samp_list_full_sort=[samp_list_full[x] for x in idx]
	#samp_softmax1_list_sort=[samp_softmax1_list[x] for x in idx]
	samp_softmax1_list_final=[]
	samp_list_full_final=[]
	x_list=[]
	y_list=[]
	for i in range(0, len(samp_softmax1_list)):
		if samp_softmax1_list[i] > prob_cutoff:
			samp_softmax1_list_final.append(samp_softmax1_list[i])
			samp_list_full_final.append(samp_list_full[i])
			p=samp_list_full[i].split("_")
			x_list.append(x_list_map[p[2]])
			y_list.append(y_list_map[p[5]])
	#print(samp_softmax1_list_final)
	#print(samp_list_full_final)
	#print(x_list)
	#print(y_list)
	total_num=0
	for i in range(0,len(samp_list_full_final)):
		#print(samp_list_full_final[i])
		num=0
		for j in range(0,len(samp_list_full_final)):
			if i != j and x_list[j]-x_list[i] >= 0 and  x_list[j]-x_list[i]<level and y_list[j]-y_list[i] >=0 and y_list[j]-y_list[i]<level:
				#print("sucess "+str(x_list[i])+' '+str(y_list[i])+' '+str(x_list[j])+' '+str(y_list[j]))
				num=num+1
			#print("fail "+str(x_list[i])+' '+str(y_list[i])+' '+str(x_list[j])+' '+str(y_list[j]))
		if num	>= num_patch_in_cat:
			total_num = total_num+1
	#print(total_num)	
	#sys.exit(0)
	return total_num
	
def class_rep_new(samp,samp_full,label,softmax0,softmax1):

	'''creating list with unique elements'''
	ts = list(set(samp))
	max_limit=0.75
	min_limit=0.25
	'''iterating through each sample'''
	num_mut=0
	num_not_mut=0
	pred_num_mut=0
	pred_num_not_mut=0	
	Y_test=[]
	predicted=[]

	for y in  ts:
		#print(y)
		idx = [i for i, x in enumerate(samp) if x ==y]
		samp_list = [samp[i] for i in idx]
		samp_list_full = [samp_full[i] for i in idx]	
		samp_label_list = [label[i] for i in idx]
		#print(samp_list)
		#print(samp_list_full)
		#print(samp_label_list)
		#sys.exit(0)
		samp_softmax0_list = [softmax0[i] for i in idx]
		samp_softmax1_list = [softmax1[i] for i in idx]
		#print(samp_label_list)
		prd=method(samp_list_full,samp_softmax1_list)
		predicted.append(prd)
		Y_test.append(int(samp_label_list[0]))
		print(samp_list[0]+' '+samp_label_list[0]+' '+str(prd))
	s=0
	report={}
	if s>0:
		tn_A0_P0,fp_A0_P1,fn_A1_P0,tp_A1_P1= confusion_matrix(Y_test, predicted, labels=[0,1]).ravel()
		
		report["tn_A0_P0"]=tn_A0_P0
		report["fp_A0_P1"]=fp_A0_P1
		report["fn_A1_P0"]=fn_A1_P0
		report["tp_A1_P1"]=tp_A1_P1
		report["accuracy"]=accuracy_score(Y_test, predicted)
		report["sensitivity"]=round(tp_A1_P1/(tp_A1_P1+fn_A1_P0),2)
		report["specifcity"]=round(tn_A0_P0/(tn_A0_P0+fp_A0_P1),2)
		report["f1"]=round(((2*tp_A1_P1)/(2*tp_A1_P1+fp_A0_P1+fn_A1_P0)),2)
		fpr, tpr, thresholds = metrics.roc_curve(Y_test, predicted, pos_label=1)
		report["AUC"]=round(metrics.auc(fpr, tpr),2)
	return report
	
def class_rep(samp,label,softmax0,softmax1):	
	'''creating list with unique elements'''
	ts = list(set(samp))
	max_limit=0.75
	min_limit=0.25
	'''iterating through each sample'''
	num_mut=0
	num_not_mut=0
	pred_num_mut=0
	pred_num_not_mut=0	
	Y_test=[]
	predicted=[]
	for y in  ts:
		idx = [i for i, x in enumerate(samp) if x ==y]
		samp_list = [samp[i] for i in idx] 
		samp_label_list = [label[i] for i in idx]
		samp_softmax0_list = [softmax0[i] for i in idx]
		samp_softmax1_list = [softmax1[i] for i in idx]
		tn=0
		num0=0
		num1=0
		for k in range(0,len(samp_list)):
			#sys.exit(1)
			tn=tn+1	
			# if samp_softmax0_list[k]<0.5:
				# num1=num1+1
				
			# if samp_softmax0_list[k]>0.5:
				# num0=num0+1
			if samp_softmax0_list[k]< min_limit and samp_softmax1_list[k] > max_limit:
				num1=num1+1
				
			if samp_softmax0_list[k] > max_limit and samp_softmax1_list[k] < min_limit:
				num0=num0+1	
			#print(str(samp_list[k])+"\t"+str(samp_label_list[k])+"\t"+str(samp_softmax0_list[k])+"\t"+str(samp_softmax1_list[k]))	
		f1=num1/tn
		f0=num0/tn
		#f1=statistics.mean(samp_softmax1_list)
		#f0=statistics.mean(samp_softmax0_list)
		if f0 > f1:
			predicted.append(0)
		else:
			predicted.append(1)
		Y_test.append(int(samp_label_list[k]))
		#if samp_label_list[k]==0:
	#report = classification_report(Y_test, predicted)
	#print(Y_test)
	#print(predicted)
	#report = confusion_matrix(Y_test, predicted, labels=[0,1]).ravel()
	tn_A0_P0,fp_A0_P1,fn_A1_P0,tp_A1_P1= confusion_matrix(Y_test, predicted, labels=[0,1]).ravel()
	
	report={}
	report["tn_A0_P0"]=tn_A0_P0
	report["fp_A0_P1"]=fp_A0_P1
	report["fn_A1_P0"]=fn_A1_P0
	report["tp_A1_P1"]=tp_A1_P1
	report["accuracy"]=accuracy_score(Y_test, predicted)
	report["sensitivity"]=round(tp_A1_P1/(tp_A1_P1+fn_A1_P0),2)
	report["specifcity"]=round(tn_A0_P0/(tn_A0_P0+fp_A0_P1),2)
	report["f1"]=round(((2*tp_A1_P1)/(2*tp_A1_P1+fp_A0_P1+fn_A1_P0)),2)
	fpr, tpr, thresholds = metrics.roc_curve(Y_test, predicted, pos_label=1)
	report["AUC"]=round(metrics.auc(fpr, tpr),2)
	return report
	
def main():	
	abspath=os.path.abspath(__file__)
	words = abspath.split("/")
	#print("You are running CNV caller Workflow "+words[len(words) - 2])
	'''reading the config filename'''
	parser=argument_parse()
	arg=parser.parse_args()
	print("Entered logits file "+arg.input+"\n\n")
	'''test'''
	test_samp=[]
	test_samp_full=[]
	test_label=[]
	#test_logit_0=[]
	#test_logit_1=[]
	test_softmax_0=[]
	test_softmax_1=[]
	test_mut=[]
	
	'''train'''
	train_samp=[]
	train_label=[]
	train_samp_full=[]
	#train_logit_0=[]
	#train_logit_1=[]
	train_softmax_0=[]
	train_softmax_1=[]
	train_mut=[]
	fobj = open(arg.input)
	for file in fobj:
		file = file.strip()
		p = file.split("\t")
		samp=p[1].split("_")
		samp[0]=samp[0]+'_'+p[0]
			
		if p[3] == 'test':
			'''test'''
			#print(p[0])
			test_mut.append(p[0])	
			test_samp.append(samp[0])
			test_samp_full.append(p[1])
			test_label.append(p[2])
			#test_logit_0.append(float(p[4]))
			#test_logit_1.append(float(p[5]))
			sf=softmax(float(p[4]),float(p[5]))
			test_softmax_0.append(sf[0])
			test_softmax_1.append(sf[1])
		else:
			'''train'''
			train_mut.append(p[0])
			train_samp.append(samp[0])
			train_samp_full.append(p[1])
			train_label.append(p[2])
			#train_logit_0.append(float(p[4]))
			#train_logit_1.append(float(p[5]))
			sf=softmax(float(p[4]),float(p[5]))
			train_softmax_0.append(sf[0])
			train_softmax_1.append(sf[1])
	fobj.close()
	
	mut=list(set(train_mut))

	m=0
	if m==1:
		
		for k in mut:
			print(k)
			train_idx_mut = [i for i, x in enumerate(train_mut) if x ==k]
			mut_train_samp = [train_samp[i] for i in train_idx_mut] 
			mut_train_label = [train_label[i] for i in train_idx_mut]
			mut_train_softmax_0 = [train_softmax_0[i] for i in train_idx_mut]
			mut_train_softmax_1 = [train_softmax_1[i] for i in train_idx_mut]

		
			print(len(mut_train_samp))
			report=class_rep(mut_train_samp,mut_train_label,mut_train_softmax_0,mut_train_softmax_1)
			print(report)
				
			test_idx_mut = [i for i, x in enumerate(test_mut) if x ==k]
			mut_test_samp = [test_samp[i] for i in test_idx_mut] 
			mut_test_label = [test_label[i] for i in test_idx_mut]
			mut_test_softmax_0 = [test_softmax_0[i] for i in test_idx_mut]
			mut_test_softmax_1 = [test_softmax_1[i] for i in test_idx_mut]

			print(len(mut_test_samp))
			report=class_rep(mut_test_samp,mut_test_label,mut_test_softmax_0,mut_test_softmax_1)
			print(report)
	
	print("ALL MUT")	
	#print(len(train_samp))
	#report=class_rep(train_samp,train_label,train_softmax_0,train_softmax_1)
	#report=class_rep(train_samp,train_samp_full,train_label,train_softmax_0,train_softmax_1)
	#print(report)
	
	print(len(test_samp))
	#report=class_rep(test_samp,test_label,test_softmax_0,test_softmax_1)
	report=class_rep_new(test_samp,test_samp_full,test_label,test_softmax_0,test_softmax_1)
	#print(report)
	
if __name__ == "__main__":
	main()
				
