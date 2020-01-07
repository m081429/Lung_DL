dir="/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level1_geneexpr/TF"
dir1="/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level1_geneexpr/"
finaldir="/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level1_geneexpr/Final_TF"
cd /dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level1_geneexpr/
nomutn=23
mutn=23
n0=0
n1=0
n2=0
n3=0
cd $dir
#mkdir FINAL_TF/
#for i in `ls $dir`
#do
#	sampname=`echo $i|sed -e 's/.tfrecords//g'`
#	mut=`grep -P "^$i\t" /dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level1_geneexpr/confirm_tf_record2.txt|cut -f3`
#	mut1=`grep -P "^$i\t" /dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level1_geneexpr/confirm_tf_record2.txt|cut -f4`
#	cate=`grep -P "^$i\t" /dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level1_geneexpr/confirm_tf_record2.txt|cut -f5`	
	#echo $sampname $mut
	#continue
#	if [ $cate != "NA" ]; then
		
#		file="$i"
#		file1=`echo $i|sed -e "s/.tfrecords/.cat$mut.$cate.tfrecords/g"`
#		cp $dir1/TF/$file $dir1/Final_TF/$file1
#	fi

#done

IFS=$'\n'
for i in `cat /dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level1_geneexpr/confirm_tf_record2_2class_final.txt`
do
	echo $i
	sampname=`echo $i|cut -f1`
	mut=`echo $i|cut -f2`
	mut1=`echo $i|cut -f3`
	cate=`echo $i|cut -f5`
	file1=`echo $sampname|sed -e "s/.tfrecords/.cat$mut1.$cate.tfrecords/g"`
	cp $dir1/TF/$sampname $dir1/Final_TF/$file1
	#exit
done	
