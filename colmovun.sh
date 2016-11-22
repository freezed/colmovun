#!/bin/bash
#
# colmuvun.sh - Collect media files in directories, downsize jpeg and move all to unique destination
#
# auteur:	git@freezed.me
# licence:	GNU GPL v3 [http://www.gnu.org/licenses/gpl.html]

# Config
DATE=$(date +%Y-%m-%d)
TIME=$(date +%T)
SCRIPT_NAME="colmuvun"
LOG_FILE="/path/to/log/${SCRIPT_NAME}.log"

ROOT="folder"
SOURCE_PATH="/path/to/source/"
DESTINATION="/path/to/destination/"
IMG_PREF="IMG_"
VID_PREF="VID_"
SCR_PREF="Screenshot_"
TAG="tag_00"

LOG_HEAD="\n# # # _________ START: ${DATE} @ ${TIME} _________ # # #"
LOG_TAIL="# # # _________ END [$(date +%T)] _________ # # #\n"

# Fonction
files_processing()
{
	N_IMG=0
	N_VID=0
	N_SCR=0
	N_MIS=0

	for FILE in $WORKING_DIR/*
	do
	FILE=`basename $FILE`

	if [[ $FILE == $IMG_PREF* ]]; then
		let N_IMG=$N_IMG+1

		jhead -q -exonly -cmd "mogrify -quality 70 -resize 1300x1300 &i" -n$DESTINATION%Y%m%d-%H%M%S-$TAG $WORKING_DIR/$FILE  >> $LOG_FILE

	elif [[ $FILE == $VID_PREF* ]]; then
		let N_VID=$N_VID+1

		tstp=`date -r $WORKING_DIR/$FILE +%Y%m%d-%H%M%S`
		ext=`basename $FILE | cut -d'.' -f2`
		mv -v $WORKING_DIR/$FILE $DESTINATION$tstp-$TAG.$ext >> $LOG_FILE

	elif [[ $FILE == $SCR_PREF* ]]; then
		let N_SCR=$N_SCR+1

		tstp=`date -r $i +%Y%m%d-%H%M%S`
		ext=`basename $FILE | cut -d'.' -f2`
		mv -v $WORKING_DIR/$FILE $DESTINATION$tstp-$TAG.$ext >> $LOG_FILE

	else let N_MIS=$N_MIS+1
	fi

	done

	if [[ $N_IMG > 0 ]] || [[ $N_VID > 0 ]] || [[ $N_SCR > 0 ]] || [[ $N_MISC > 1 ]]; then
		echo -e "## $TAG | $N_IMG img | $N_VID vid | $N_MIS misc ## \n" >> $LOG_FILE
	fi
}

echo -e $LOG_HEAD >> $LOG_FILE

# Fichiers a la racine
WORKING_DIR=$SOURCE_PATH$ROOT

files_processing

# Fichiers dans N-1
DIR_LIST=`find $SOURCE_PATH$ROOT/* -type d|sed "s#$SOURCE_PATH$ROOT/#%#"|cut -d'%' -f2`
#~ echo -e "## Directories: ##" >> $LOG_FILE
#~ echo -e $DIR_LIST "\n" >> $LOG_FILE

for DIR in $DIR_LIST
do
	TAG=$DIR
	WORKING_DIR=$SOURCE_PATH$ROOT/$DIR

	files_processing
done
echo -e $LOG_TAIL >> $LOG_FILE

exit 0;
