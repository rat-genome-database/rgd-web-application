#!/bin/bash

#SCRIPT_LOC="/rgd/data/primer3/"
PRIMER3_HOME="/rgd/data/primer3"

FIND_LATEST_FILE="ls -tr "$PRIMER3_HOME"/createPrimerInp/| tail -n 1"

#echo $FIND_LATEST_FILE

#PRIMER_FILE=`$FIND_LATEST_FILE`

PRIMER_FILE=`ls -tr $PRIMER3_HOME/createPrimerInp/| tail -n 1`

#echo $PRIMER_FILE

PRIMER_FILE_LOC=`find $PRIMER3_HOME -iname $PRIMER_FILE`

#echo "primer input file located at.."
#echo $PRIMER_FILE_LOC

cd $PRIMER3_HOME

PRIMERS_OUTPUT_FILE="$PRIMER3_HOME/createPrimerOut/$PRIMER_FILE"

#echo "primer output file located at.."
#echo $PRIMERS_OUTPUT_FILE


echo "<h1>Primer 3 Output</h1><hr>"

PRIMER_CMD="primer3_core -format_output -strict_tags -default_version=2 -io_version=4 -p3_settings_file=$PRIMER3_HOME/settings/$SETTINGS -echo_settings_file -output=$PRIMERS_OUTPUT_FILE $PRIMER3_HOME/createPrimerInp/$PRIMER_FILE"

#echo $PRIMER_CMD

`$PRIMER_CMD`

#echo $?

BODY=`cat $PRIMERS_OUTPUT_FILE`

if [ -n "$BODY" ]
then
        echo "$BODY"
fi









BLAT_FOLDER="/rgd/data/blat/"
BLAT_DB=$BLAT_FOLDER"blatdb/Human/human37/"
BLAT_INPUT=$BLAT_FOLDER"blatInp/"$PRIMER_FILE

if [ -e $BLAT_INPUT ]
then
rm $BLAT_INPUT
fi

BLAT_OUTPUT_FOLDER=$BLAT_FOLDER"blatOut/"$PRIMER_FILE"/"

if [ -e $BLAT_OUTPUT_FOLDER ]
	then
	echo "blat op folder exists.."
else
	mkdir $BLAT_OUTPUT_FOLDER
fi



if [ -e $BLAT_OUTPUT_FOLDER"psl/" ]
	then
	echo "psl folder exists"
else
	mkdir $BLAT_OUTPUT_FOLDER"psl/"
fi



HEAD_TAG=""
LEFT_PR_TAG=""
RIGHT_PR_TAG=""
NO_PR_TAG=""
COUNT=0

echo " "
echo "<h1>Primer3 Primers</h1><hr>"

cat $PRIMERS_OUTPUT_FILE | \
{
while read regExLine
do

if [[ $regExLine=~NO[:blank:]PRIMERS[:blank:]FOUND ]]
then
NO_PRIMER=`echo $regExLine`
#echo $NO_PRIMER
fi

if [[ $regExLine=~PICKING ]]
then
HEADER=`echo $regExLine | grep -n 'PRIMER PICKING' | awk '{ print $NF }'`
#echo $HEADER
fi

if [[ $regExLine=~LEFT ]]
then
LEFT_PRIMER=`echo $regExLine | grep -n 'LEFT PRIMER' | awk '{ print $NF }'`
#echo $LEFT_PRIMER
fi

if [[ $regExLine=~RIGHT ]]
then
RIGHT_PRIMER=`echo $regExLine | grep -n 'RIGHT PRIMER' | awk '{ print $NF }'`
#echo $RIGHT_PRIMER
fi


if [[ ${#HEADER} > 0 ]]
then
HEAD_TAG=$HEADER
#echo "$HEAD_TAG"
fi

if [[ ${#LEFT_PRIMER} > 0 ]]
then
    LEFT_PR_TAG=$LEFT_PRIMER
    COUNT=`expr $COUNT + 1`
    echo ">"$HEAD_TAG"_L"$COUNT >> $BLAT_INPUT
    echo $LEFT_PR_TAG >> $BLAT_INPUT
    HEADER="o "$HEAD_TAG"_L"$COUNT
    echo "$HEADER"
    echo "  $LEFT_PR_TAG"
fi

if [[ ${#RIGHT_PRIMER} > 0 ]]
then
    RIGHT_PR_TAG=$RIGHT_PRIMER
    echo ">"$HEAD_TAG"_R"$COUNT >> $BLAT_INPUT
    echo $RIGHT_PR_TAG >> $BLAT_INPUT
    HEADER="o "$HEAD_TAG"_R"$COUNT
    echo "$HEADER"
    echo "  $RIGHT_PR_TAG"
fi


if [[ ${#NO_PRIMER} > 0 ]]
then
NO_PR_TAG=NO_PRIMER
fi

done
}

#echo "-----------------------------------"



if [ -e $BLAT_INPUT ]
then

echo "<h1>Blat Result</h1><hr>"


	##	Blatting for each chromosome:
	for n in {1..22} X Y
	do
	#echo "runnig BLAT for query against chr$n"
	blat -t=dna -q=dna -out=pslx -fine -repMatch=1000000 $BLAT_DB"chr"$n".nib" $BLAT_INPUT $BLAT_OUTPUT_FOLDER"psl/chr"$n".psl" > /dev/null
	done

	##	sorting and merging the psl files(blat output for each chromosome)
	#echo "sorting and merging the individual chromosome output psl files"
	pslSort dirs $BLAT_OUTPUT_FOLDER"out.psl" /tmp $BLAT_OUTPUT_FOLDER"psl/" > /dev/null

	##pslReps - after pslSort.. haven't tried it yet.. 
	#echo "post processing output "
	pslReps -singleHit -ignoreSize $BLAT_OUTPUT_FOLDER"out.psl" $BLAT_OUTPUT_FOLDER"FINAL.psl" $BLAT_OUTPUT_FOLDER"out.psr" > /dev/null


	cat $BLAT_OUTPUT_FOLDER"FINAL.psl" | while read line
	do
	echo "$line"
	done

	cat $BLAT_OUTPUT_FOLDER"out.psr" | while read line
	do
	echo "$line"
	done


	#echo "your primers are located here: $PRIMERS_OUTPUT_FILE"
	#echo "your BLAT input files are located here: $BLAT_INPUT"
	#echo "your BLAT output files are located here: $BLAT_OUTPUT_FOLDERFinal.psl"


else

echo "NO PRIMERS FOUND"

fi
