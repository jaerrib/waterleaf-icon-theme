#!/bin/sh

#$1 .. Icons directory
#$2 .. Source icon name to copy
#$3 .. Destination icon name to be replaced

#1.Remove specified icons "$3" from destination directory "$1"
#2.Link icon variants "$2" to the destination "$3"

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

find $ICON_DIR/ -type f,l -iname "$DST_ICON_NAME" | while read -r ICONFL01 ; do
  cd "$( dirname "$ICON_DIR/$ICONFL01" )"
  rm $DST_ICON_NAME
  ln -s $SRC_ICON_NAME $DST_ICON_NAME
done
