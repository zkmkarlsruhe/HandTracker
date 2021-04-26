#! /bin/sh
#
# script to download pre-trained models for the example projects
#
# requires: curl, unzip
#
# Dan Wilcox ZKM | Hertz-Lab 2021

# stop on error
set -e

# ZKM NextCloud shared folder direct link
URL="https://cloud.zkm.de/index.php/s/gfWEjyEr9X4gyY6"

SRC=downloads
DEST=../..

##### functions

# download from a public NextCloud shared link
# $1: root folder share link URL
# $2: filename
function download() {
	local path="download?path=%2F&files=$2"
	curl -LO $URL/$path
	mkdir -p $SRC
	mv $path $SRC/$2
}

##### go

# change to script dir
cd $(dirname "$0")

# download model
download $URL model_handtracking.zip

cd "$SRC"

# unzip and place
unzip model_handtracking.zip
rm -rf "$DEST"/bin/data/model
mv model "$DEST"/bin/data/

# cleanup
cd ../
rm -rf "$SRC"
