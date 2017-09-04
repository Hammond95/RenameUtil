#!/bin/bash
##################################################################################################
#   TO DO                                                                                        #
#                                                                                                #
#   1) Bug Fix: File che contengono nel nome un '#'                                              #
#   2) Bug Fix: File che non hanno extension                                                     #
##################################################################################################

#Set Script Name variable
SCRIPT=`basename ${BASH_SOURCE[0]}`

#Initialize variables to default values.
FILENAMEREGEX='*'
FROM_NAME=""
TO_NAME=""
OVERWRITE="yes"
NEWEXT=""
CASE="NOCASE"

#Set fonts for Help.
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

#Help function
function HELP 
{
	echo -e "==================================================================================================================="
	echo -e "Help documentation for ${BOLD}${SCRIPT}.${NORM}\n"
	echo -e "Listing of possible Arguments of the function\n"
	echo "${REV}-r${NORM}	--Regular Expression that matches the files to rename."
	echo "${REV}-f${NORM}	--Partial String to replace."
	echo "${REV}-t${NORM}	--String replacement of original string."
	echo "${REV}-p${NORM}	--Prefix to add at the beginning of a filename"
	echo "${REV}-s${NORM}	--Suffix to add at the end of a filename"
	echo "${REV}-o${NORM}	--Overwrite [yes/no]: specify if you want to overwrite if a file with a new name already exists."
	echo "${REV}-e${NORM}	--New Extension"
	echo "${REV}-c${NORM}	--Set Case of the Filename:"
	echo "			--${REV}u${NORM}: UPPERCASE BEFORE any replacement or prefix/suffix addition"
	echo "			--${REV}U${NORM}: UPPERCASE AFTER any replacement or prefix/suffix addition"
	echo "			--${REV}l${NORM}: LOWERCASE BEFORE any replacement or prefix/suffix addition"
	echo "			--${REV}L${NORM}: LOWERCASE AFTER any replacement or prefix/suffix addition"
	echo -e "${REV}-h${NORM}	--Displays this help message. No further functions are performed."\\n
	echo -e "Example: ${BOLD}$SCRIPT -r foo -f man -t chu -p bar${NORM}"
	echo -e "===================================================================================================================\n"	
	exit 1
}

#Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
#echo -e \\n"Number of arguments: $NUMARGS"
if [ $NUMARGS -eq 0 ]; then
	HELP
fi

### Start getopts code ###

#Parse command line flags
#If an option should be followed by an argument, it should be followed by a ":".
#Notice there is no ":" after "h". The leading ":" suppresses error messages from
#getopts. This is required to get my unrecognized option code to work.

while getopts :r:f:t:p:s:o:e:c:h FLAG; do
	case $FLAG in
		r)	FILENAMEREGEX=$OPTARG
			echo "-r used $OPTARG"
			echo "FILENAMEREGEX = $FILENAMEREGEX"
			;;
		f) 	FROM_PARTNAME=$OPTARG
			echo "-f used: $OPTARG"
			echo "FROM_NAME = $FROM_NAME"
			HASHASH=$( echo "$FROM_PARTNAME" | grep -c '#')
			if [ "$HASHASH" -ne 0 ]; then
				echo $FROM_PARTNAME
				FROM_PARTNAME=$(echo $FROM_PARTNAME | sed 's/#/\\#/g')
			fi
			;;
		t)	TO_PARTNAME=$OPTARG
			echo "-t used: $OPTARG"
			echo "TO_NAME = $TO_NAME"
			HASHASH=$( echo "$TO_PARTNAME" | grep -c '#')
                        if [ "$HASHASH" -ne 0 ]; then
				#echo $TO_PARTNAME
				TO_PARTNAME=$(echo $TO_PARTNAME | sed 's/#/\\#/g')
                        fi
			;;
		p)	PREFIX=$OPTARG
                        echo "-t used: $OPTARG"
                        echo "PREFIX = $PREFIX"
                        ;;
		s)	SUFFIX=$OPTARG
                        echo "-t used: $OPTARG"
                        echo "SUFFIX = $SUFFIX"
                        ;;
		o)	OVERWRITE=$OPTARG
			echo "-o used: $OPTARG"
			echo "OVERWRITE = $OVERWRITE"
			;;
		e)	#Add Check Extension
			NEWEXT=$OPTARG
			echo "-e used: $OPTARG"
			echo "NEWEXT = $NEWEXT"
			;;
		c)	#Add Check Option
			CASE=$OPTARG
			echo "-e used: $OPTARG"
			echo "CASE = $CASE"
			;;
		h)	HELP
			;;
		\?)	echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
			HELP
			;;
	esac
done

shift $((OPTIND-1))	#This tells getopts to move on to the next argument.

### End getopts code ###

#kill -INT $$

LISTTORENAME=$(ls -1 $FILENAMEREGEX)
for FILEFULLNAME in $LISTTORENAME; do
	ACTUALNEWEXT=$NEWEXT
	EXT="."$(echo $FILEFULLNAME | rev | cut -d'.' -f1 | rev)
	#echo "Estensione = $EXT"
	FILENAME=${FILEFULLNAME%$EXT}
	#echo "File Name = $FILENAME"
	NEWFILENAME=$FILENAME
	
	if [ "$CASE" == "u" ]; then
		NEWFILENAME=${NEWFILENAME^^}
	else
		if [ "$CASE" == "l" ]; then
			NEWFILENAME=${NEWFILENAME,,}
		fi
	fi
	
	#Regexp Replacment
	if [ ! -z "$FROM_PARTNAME" ]; then
		NEWFILENAME=$(echo $FILENAME | sed "s#$FROM_PARTNAME#$TO_PARTNAME#g")
	fi
	
	#Adding Prefix&Suffix
	NEWFILENAME="$PREFIX$NEWFILENAME$SUFFIX"
	
	
	if [ "$CASE" == "U" ]; then
                NEWFILENAME=${NEWFILENAME^^}
        else
                if [ "$CASE" == "L" ]; then
                        NEWFILENAME=${NEWFILENAME,,}
                fi
        fi
	
	#Checking Extension
	if [ -z "$NEWEXT" ]; then
		ACTUALNEWEXT="$EXT"
	fi
	
	#echo "NEWFILEFULLNAME prima= $NEWFILEFULLNAME"
	NEWFILEFULLNAME="$NEWFILENAME$ACTUALNEWEXT"
	#echo "NEWFILEFULLNAME dopo= $NEWFILEFULLNAME"

	if [ ! -z "$NEWFILEFULLNAME" ] && [ "$NEWFILEFULLNAME" != "$FILEFULLNAME" ]; then
		#TO DO:
			#if NEWFILEFULLNAME not exist or overwrite=yes
		#Performing Rename
		mv "$FILEFULLNAME" "$NEWFILEFULLNAME"
		echo "Rename from '$FILEFULLNAME' to '$NEWFILEFULLNAME'"
	else
		echo "Il nuovo nome file, è vuoto o coincide con quello di partenza"
	fi
done


