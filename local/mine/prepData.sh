#Put in the folder where the csv separated file is placed and provide the input file and output directory to put the files into as arguments.


inputFileName=$1
outputDir=$2

mkdir $outputDir

IFS=','
while read wav size text; do

	echo $wav
	fileName=${wav##*/}
	fileId=`echo $fileName | cut -d'.' -f1`
	echo $fileId" "$wav >> $outputDir/wav.scp
	echo $fileId" "$fileId >> $outputDir/utt2spk
	echo $fileId" "$fileId >> $outputDir/spk2utt 
	echo $fileId" "$text >> $outputDir/text 

done < $inputFileName



