dir="/dtascfs/DL/lungcancer/AD_SC_PDL1/LUNG_TCGA_LEVEL2/FINAL_TFRECORDS"
IFS=$'\n'
#for i in `cat adjusted_samples.txt`
#for i in `cat adjusted_samples1.txt`
for i in `cat adjusted_samples2.txt`
do
	ini=`ls $dir|grep "$i"|head -1`
	#tar=`echo $ini|sed -e 's/val/test/g'`
	#tar=`echo $ini|sed -e 's/test/train/g'`
	tar=`echo $ini|sed -e 's/val/train/g'`
	echo $ini $tar
	mv $dir/$ini $dir/$tar
	#exit
done
