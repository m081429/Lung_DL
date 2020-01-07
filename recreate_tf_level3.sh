dir="/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level3"
#dir="/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS"
nomutn=137
mutn=54
nn=0
nm=0
cd $dir
#mkdir FINAL_TF/
for i in `ls -S $dir`
do
	sampname=`echo $i|sed -e 's/.tfrecords//g'`
	mut=`grep -P "^$sampname\t" /dtascfs/DL/lungcancer/AD_SC_PDL1/scripts/Lung_DL/Lung_Meta_Zhifu_May10.txt|cut -f2` 
	echo $sampname $mut
	continue
	if [ $mut  == "SQCC" ]; then
		(( nm += 1 ))
		#if [ $nm -lt 12 ]; then
			file="$i"
			file1="./FINAL_TF/"`echo $i|sed -e 's/.tfrecords/.SQCC.test.tfrecords/g'`
	
		mv $file $file1
		fi
		if [ $nm -lt 55 ] && [ $nm -gt 11 ]; then
			file="$i"
			file1="./FINAL_TF/"`echo $i|sed -e 's/.tfrecords/.SQCC.train.tfrecords/g'`
			mv $file $file1
		fi
	fi
	if [ $mut  == "ADC" ]; then
		(( nn += 1 ))
		if [ $nn -lt 22 ]; then
			file="$i"
			file1="./FINAL_TF/"`echo $i|sed -e 's/.tfrecords/.ADC.test.tfrecords/g'`
			mv $file $file1
		fi
		if [ $nn -lt 108 ]  && [ $nn -gt 21 ]; then
			file="$i"
			file1="./FINAL_TF/"`echo $i|sed -e 's/.tfrecords/.ADC.train.tfrecords/g'`
			mv $file $file1
		fi
	fi
done
