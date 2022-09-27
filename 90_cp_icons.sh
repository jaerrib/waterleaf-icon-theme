#!/bin/sh

#-------------------------------------------------------
# function: cp_icon
#
# 1.Remove specified icons "$4" from destination directory "$2"
# 2.Copy icon variants "$3" from source to destination directory "$2"
#
# $1 .. Source icons directory
# $2 .. Destination icons directory
# $3 .. Source icon name to copy
# $4 .. Destination icon name to be replaced
#-------------------------------------------------------
cp_icon ()
{
local SRC_ICON_DIR="$1"
local DST_ICON_DIR="$2"
local SRC_ICON_NAME="$3"
local DST_ICON_NAME="$4"
if [ -z "$SRC_ICON_NAME" ] ; then
  echo "Need arguments, cp_icon exiting ..."
  return 100
fi
if [ -z "$DST_ICON_NAME" ] ; then
  DST_ICON_NAME="$SRC_ICON_NAME"
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
}

#-------------------------------------------------------
# main entry
#
# $1 .. Source icons directory
# $2 .. Destination icons directory
# $3 .. Text file listing icons to be copied from source directory
#-------------------------------------------------------
SRC_DIR="$1"
OUT_DIR="$2"
ICN_LIST="$3"

if [ -z "$SRC_DIR" ] || [ -z "$OUT_DIR" ] || [ -z "$ICN_LIST" ] ; then
  echo "Need arguments, exiting ..."
  exit 20
fi
if [ ! -d "$SRC_DIR" ] || [ ! -d "$OUT_DIR" ] || [ ! -f "$ICN_LIST" ] ; then
  echo "Need proper arguments, exiting ..."
  exit 30
fi
if [ ! -f "$SRC_DIR/index.theme" ] ; then
  echo "Source icon theme not found, exiting ..."
  exit 40
fi
if [ ! -f "$OUT_DIR/index.theme" ] ; then
  echo "Target icon theme not found, exiting ..."
  exit 50
fi

while read LINE1 ; do
  if [ -n "$( echo "$LINE1" | grep -v "^#" | grep -v "^$" )" ] ; then
    cp_icon "$1" "$2" "$LINE1.png"
    cp_icon "$1" "$2" "$LINE1.svg"
  fi
done < $ICN_LIST
