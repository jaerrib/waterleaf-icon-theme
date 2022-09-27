#!/bin/sh

#-------------------------------------------------------
# function: link_icon
#
# 1.Remove all source icons "$2" from the icon set
# 2.Link icon variants "$2" to the target "$3"
#
# $1 .. Icons directory
# $2 .. Source icon name that is a symlink
# $3 .. Target icon name to be linked to
#-------------------------------------------------------
link_icon ()
{
local ICON_DIR="$1"
local SRC_ICON_NAME="$2"
local DST_ICON_NAME="$3"
if [ -z "$SRC_ICON_NAME" ] || [ -z "$DST_ICON_NAME" ] ; then
  echo "Need arguments, link_icon exiting ..."
  return 100
fi

DST_ICON_FILES="$( find $ICON_DIR/ -type f,l -name "$DST_ICON_NAME" )"
if [ -n "$DST_ICON_FILES" ] ; then
  rm -f $( find $ICON_DIR/ -type f,l -name "$SRC_ICON_NAME" | xargs ) #remove all source icons
  echo "$DST_ICON_FILES" | while read -r ICONFL01 ; do
    cd "$( dirname "$ICONFL01" )"
    # echo "linking $SRC_ICON_NAME -> $DST_ICON_NAME, in $(pwd)"
    ln -s "$DST_ICON_NAME" "$SRC_ICON_NAME"
  done
fi
}

#-------------------------------------------------------
# main entry
#
# $1 .. Icons directory
# $2 .. Text file listing symlinks to be created for the icon set
#-------------------------------------------------------
ICONS_DIR="$1"
SYMLINKS_LIST="$2"

if [ -z "$ICONS_DIR" ] || [ -z "$SYMLINKS_LIST" ] ; then
  echo "Need arguments, exiting ..."
  exit 20
fi
if [ ! -d "$ICONS_DIR" ] || [ ! -f "$SYMLINKS_LIST" ] ; then
  echo "Need proper arguments, exiting ..."
  exit 30
fi
if [ ! -f "$ICONS_DIR/index.theme" ] ; then
  echo "Icon theme not found, exiting ..."
  exit 40
fi

while read LINE1 ; do
  if [ -n "$( echo "$LINE1" | grep -v "^#" | grep -v "^$" )" ] ; then
    IC_SRC="$(echo "$LINE1" | awk -F' ' '{ print $1 }' )"
    IC_TARG="$(echo "$LINE1" | awk -F' ' '{ print $2 }' )"
    link_icon "$ICONS_DIR" "$IC_SRC.png" "$IC_TARG.png"
    link_icon "$ICONS_DIR" "$IC_SRC.svg" "$IC_TARG.svg"
  fi
done < "$SYMLINKS_LIST"
