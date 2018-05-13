##Make a dateset with a certain accent
##$1=the annotated file
##$2=the data folder to create
##$3=the accent

##change the wav variable accordingly whether it is train, dev or test

filename=$1
datafolder=$2
IFS=","

dir=data/$datafolder
mkdir $dir

i=0
while read a b c d e f g h; do
	echo $a
	if [ "$g" == "" ]; then
		continue;
	else
		x=`echo $a | cut -d'/' -f2 | cut -d'.' -f1`
		wav="/exp/abhinav/Mozilla_wav/cv_corpus_v1/cv-valid-dev/"$x".wav"
		echo $x" "$wav >> $dir/wav.scp
		echo $x" "$x >> $dir/spk2utt
		echo $x" "$x >> $dir/utt2spk
		echo $x" "$b >> $dir/text
		echo $x" "$g >> $dir/accent
		((i=i+1))
	fi
	# id=`echo $wav | cut -d'/' -f7 | cut -d'.' -f1`
	# echo $id" "$wav >> data/$datafolder/wav.scp
	# echo $id" "$text >> data/$datafolder/text
	# echo $id" "$id >> data/$datafolder/utt2spk
	# echo $id" "$id >> data/$datafolder/spk2utt
done < $filename
echo $i