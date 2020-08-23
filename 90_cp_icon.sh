#!/bin/sh

#$1 .. Source icons directory
#$2 .. Destination icons directory
#$3 .. Source icon name to copy
#$4 .. Destination icon name to be replaced

#1.Remove specified icons "$4" from destination directory "$2"
#2.Copy icon variants "$3" from source to destination directory "$2"

SRC_ICON_DIR="$( readlink -f "$1" )"
DST_ICON_DIR="$( readlink -f "$2" )"
SRC_ICON_NAME="$3"
DST_ICON_NAME="$4"
if [ -z "$DST_ICON_NAME" ] ; then
  DST_ICON_NAME="$SRC_ICON_NAME"
fi

if [ -z "$SRC_ICON_NAME" ] || [ -z "$DST_ICON_NAME" ] ; then
  echo "Need arguments, exiting ..."
  exit 100
fi
if [ ! -f "$SRC_ICON_DIR/index.theme" ] ; then
  echo "Source icon theme not found, exiting ..."
  exit 110
fi
if [ ! -f "$DST_ICON_DIR/index.theme" ] ; then
  echo "Destination icon theme not found, exiting ..."
  exit 111
fi

#Remove "$DST_ICON_NAME" icons from destination directory
find $DST_ICON_DIR/ -type f,l -iname "$DST_ICON_NAME" | while read -r ICONFL01 ; do
  # echo "rm $ICONFL01"
  rm $ICONFL01
done

#Copy "$SRC_ICON_NAME" icon variants from source to destination directory
find $SRC_ICON_DIR/ -type f,l -iname "$SRC_ICON_NAME" | while read -r ICONFL02 ; do
  ICONFL03="$( echo $ICONFL02 | awk -F'/' '{ print $(NF-2)"/"$(NF-1)"/" }' )/$DST_ICON_NAME"
  # echo "cp --remove-destination $ICONFL02 $DST_ICON_DIR/$ICONFL03"
  mkdir -p "$( dirname "$DST_ICON_DIR/$ICONFL03" )"
  cp --remove-destination $ICONFL02 $DST_ICON_DIR/$ICONFL03
done
