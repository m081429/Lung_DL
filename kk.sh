dir="/dtascfs/DL/lungcancer/AD_SC_PDL1/TFRECORDS_Level3"
cd $dir
#mkdir FINAL_TF/
for i in `ls $dir`
do
	y=`echo $i|sed -e 's/.test//g'|sed -e 's/.train//g'|sed -e 's/.ADC//g'|sed -e 's/.SQCC//g'`
	echo $i $y
	#exit
	mv $i $y
done
