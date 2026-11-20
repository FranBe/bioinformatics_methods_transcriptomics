#!/bin/bash

#************************************************************************
#                           Data Ingestion Script
#************************************************************************

#while read -r line; do echo "$line"; done < <(cat data/urls.txt | grep -v -e "^$")

#------------------------------ Functions section-----------------------------------------

Help()
{
   # Display Help
   echo "Download and decompress data files from URLs specified in data/urls.txt."
   echo
   echo "Syntax: dataingestion.sh data_directory urls_file"
   echo "or..."
   echo "Syntax: scriptTemplate [-d|f|h]"
   echo "options:"
   echo "d     Data directory."
   echo "f    URLs file."
   echo "h     Print this Help."
   echo
}



GetData() 
{
    workdir=$(pwd)
    datadir=$workdir/$1
    urlsfile=$datadir/$2

    # Check if provided arguments are valid
    if [ ! -d $datadir ]; then
        echo "Error: $datadir is not a valid directory."
        exit 1
    fi

    if [ ! -f $urlsfile ]; then
        echo "Error: $urlsfile file not found."
        exit 1
    fi


    data=$1

    while read -r line; do
        
        # Dowload the file from the URL and save it to the data directory
        echo "Downloading $line"
        #wget -P $datadir/zip "$line"

        # Decompress the file if it is a .gz file
        
        if [[ "$line" == *.tar.gz ]]; then
            echo "Decompressing $(basename "$line")"
            tar -xzf "$datadir/zip/$(basename "$line")" -C $datadir/raw
        fi

        if [[ "$line" == *.gz ]]; then
            echo "Decompressing $(basename "$line")"
            gunzip -f "$datadir/zip/$(basename "$line")"
        fi

    done < <(cat $urlsfile | grep -v -e "^$")
    
} 


#------------------------------ Program section-----------------------------------------

# Get Help
if [ "$1" == "-h" ]; then
    Help
    exit 0
fi

# Check if the correct number of arguments is provided
if [ "$#" -ne 4 ]; then
    echo "You must provide next arguments: data_directory and urls_file."
    echo
    Help
    exit 1
fi 

# Caso sin opciones

if [ "$1" == "-d" ]; then
    if [ "$3" == "-f" ]; then
        GetData "$2" "$4"
    else
        echo "Error: You just provided data_directory argument, but urls_file argument is missing."
        echo "Use the -h option for help."
        exit 1
    fi
elif [ "$1" == "-f" ]; then
    if [ "$3" == "-d" ]; then
        GetData "$4" "$2"
    else
        echo "Error: You just provided urls_file argument, but data_directory argument is missing."
        echo "Use the -h option for help."
    exit 1
    fi
fi


#GetData "$@"
