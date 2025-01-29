#!/bin/sh

#1.Remove broken symlinks
#2.Check for double and multiple level symlinks and fix them

#$1 .. source directory

ICON_DIR="$1"

if [ ! -f "$ICON_DIR/index.theme" ] ; then
  #safety check
  echo "Source icon theme not found, exiting ..."
  exit 100
fi

#remove all the broken links, but try to fix svg vs png
echo "Checking for broken symlinks ..."
WKFL1="/tmp/.a_mlinks_1.lst" #list of icons symlinks
find "$ICON_DIR/" -name '*.svg' -type l -o -name '*.png' -type l | xargs file | grep 'broken symbolic link to' | awk -F': ' '{ print $1 }' > $WKFL1
LN_NUM1="$( wc -l < "$WKFL1" )"
if [ "$LN_NUM1" != "0" ] ; then
  echo "  [W:] Found broken links: #$LN_NUM1, removing them ..."
  while read LINE1 ; do
    LN2SF="$( echo "$LINE1" | awk -F'.png$' '{ print $1 }' | awk -F'.svg$' '{ print $1 }' )"
    if [ -e "$LN2SF.svg" ] ; then
      echo -e "\nFixing symlink: $LN2SF.svg\n"
      mv $LINE1 $LN2SF.svg
    elif [ -e "$LN2SF.png" ] ; then
      echo -e "\nFixing symlink: $LN2SF.png\n"
      mv $LINE1 $LN2SF.png
    else
      printf '.'
      rm $LINE1
    fi
  done < $WKFL1
  printf '\n'
#   rm -f $( cat "$WKFL1" )
else
  echo "  No broken links found, Ok."
fi

if [ "$FIX_DOUBLE_LINKS" != "1" ] ; then
  exit
fi

echo "Determining all symlinks ..."
WKFL2="/tmp/.a_mlinks_2.lst" #list of all symlinks in the icons direcotory
find "$ICON_DIR/" -name '*.svg' -type l -o -name '*.png' -type l | sort -u > $WKFL2
echo "Number of all symlinks: #$(wc -l < "$WKFL2")"

echo "Fixing multiple level symlinks ..."
while read LINE1 ; do
  printf '.'
  ABSPATH1="$( readlink -f "$LINE1" )"
  # echo "$LINE1 -> $ABSPATH1"
  rm "$LINE1"
  ln -sr "$ABSPATH1" "$LINE1"
done < $WKFL2
