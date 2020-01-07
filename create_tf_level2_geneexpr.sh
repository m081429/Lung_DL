dir1=/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level2_geneexpr/Final_TF_level2
IFS=$'\n'
for i in `cat /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/Lung_DL/final_confirm_tf_record_level2_geneexp.xls`
do
	echo $i
	sampname=`echo $i|cut -f3`
	mut=`echo $i|cut -f2`
	cat=`echo $i|cut -f4`
	file1=`echo $sampname|sed -e "s/.tfrecords/.cat$mut.tfrecords/g"`
	file2=`echo $sampname|sed -e "s/.tfrecords/.$cat.cat$mut.tfrecords/g"`
	#mv $dir1/$sampname $dir1/Final_TF/$file1
	mv $dir1/Final_TF/$file1 $dir1/Final_TF/$file2
	#exit
done	
