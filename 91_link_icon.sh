#!/bin/sh

#$1 .. Icons directory
#$2 .. Source icon name to copy to be replaced
#$3 .. Target icon name to be linked to

#1.Remove specified icons "$3" from destination directory "$1"
#2.Link icon variants "$2" to the target "$3"

ICON_DIR="$( readlink -f "$1" )"
SRC_ICON_NAME="$2"
DST_ICON_NAME="$3"
if [ -z "$SRC_ICON_NAME" ] || [ -z "$DST_ICON_NAME" ] ; then
  echo "Need arguments, exiting ..."
  exit 100
fi
if [ ! -f "$ICON_DIR/index.theme" ] ; then
  echo "Source icon theme not found, exiting ..."
  exit 110
fi

DST_ICON_FILES="$( find $ICON_DIR/ -type f,l -name "$DST_ICON_NAME" )"
if [ -n "$DST_ICON_FILES" ] ; then
  rm -f $( find $ICON_DIR/ -type f,l -name "$SRC_ICON_NAME" | xargs ) #remove all source icons, if at least one target icon found
  echo "$DST_ICON_FILES" | while read -r ICONFL01 ; do
    cd "$( dirname "$ICONFL01" )"
    # echo "linking $SRC_ICON_NAME -> $DST_ICON_NAME, in $(pwd)"
    ln -s "$DST_ICON_NAME" "$SRC_ICON_NAME"
  done
fi
