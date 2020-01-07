inputdir=/dtascfs/DL/lungcancer/AD_SC_PDL1/LUNG_TCGA_LEVEL2/FINAL_TFRECORDS
outputdir=/dtascfs/DL/lungcancer/AD_SC_PDL1/LUNG_TCGA_LEVEL2/FINAL_TFRECORDS-400
ntrain=200
ntest=40

nn=0
#(( nn += 1 ))
#if [ $nn -lt $((z+1)) ]; then
for i in `ls $inputdir|grep ".TCGA-LUAD.0.test."` 
do
	(( nn += 1 ))
	if [ $nn -lt $((ntest+1)) ]; then
		mv $inputdir/$i $outputdir/
		#exit
	fi	
done

nn=0
#(( nn += 1 ))
#if [ $nn -lt $((z+1)) ]; then
for i in `ls $inputdir|grep ".TCGA-LUSC.1.test."`
do
        (( nn += 1 ))
        if [ $nn -lt $((ntest+1)) ]; then
                mv $inputdir/$i $outputdir/
                #exit
        fi
done
nn=0
#(( nn += 1 ))
#if [ $nn -lt $((z+1)) ]; then
for i in `ls $inputdir|grep ".TCGA-LUSC.1.train."`
do
        (( nn += 1 ))
        if [ $nn -lt $((ntrain+1)) ]; then
                mv $inputdir/$i $outputdir/
                #exit
        fi
done

nn=0
#(( nn += 1 ))
#if [ $nn -lt $((z+1)) ]; then
for i in `ls $inputdir|grep ".TCGA-LUAD.0.train."`
do
        (( nn += 1 ))
        if [ $nn -lt $((ntrain+1)) ]; then
                mv $inputdir/$i $outputdir/
                #exit
        fi
done


