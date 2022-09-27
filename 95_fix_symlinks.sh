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

#remove all the broken links
echo "Checking for broken symlinks ..."
WKFL1="/tmp/.a_mlinks_1.lst" #list of icons symlinks
find "$ICON_DIR/" -xtype l > $WKFL1
LN_NUM1="$( wc -l < "$WKFL1" )"
if [ "$LN_NUM1" != "0" ] ; then
  echo "  [W:] Found broken links: #$LN_NUM1, removing them ..."
  rm -f $( cat "$WKFL1" )
else
  echo "  No broken links found, Ok."
fi

if [ "$FIX_DOUBLE_LINKS" != "1" ] ; then
  exit
fi

#check for double and multiple level symlinks
echo "Checking for multiple level symlinks ..."
WKFL2="/tmp/.a_mlinks_2.lst" #list of all symlinks in the icons direcotory
WKFL3="/tmp/.a_mlinks_3.lst" #list of targets of symlinks with path resolved
WKFL4="/tmp/.a_mlinks_4.lst" #list of target symlinks what point to another symlink
WKFL5="/tmp/.a_mlinks_5.lst" #list of symlinks created as double symlinks bypass

while [ "$SYMLINKS_OK" != "1" ] ; do
  echo "  Starting new phase ..."
  echo "  Determining symlinks ..."
  find "$ICON_DIR/" -name '*.svg' -type l -ls | awk -F' ' '{ print $(NF-2)" -> "$NF }' > $WKFL2
  find "$ICON_DIR/" -name '*.png' -type l -ls | awk -F' ' '{ print $(NF-2)" -> "$NF }' >> $WKFL2
  # find "$ICON_DIR/" -name '*.svg' -type l -ls | awk -F' -> ' '{ print $(NF-1) }' | awk -F' ' '{ print $NF }' > $WKFL2
  # find "$ICON_DIR/" -name '*.png' -type l -ls | awk -F' -> ' '{ print $(NF-1) }' | awk -F' ' '{ print $NF }' >> $WKFL2
  echo "  Number of all symlinks: #$(wc -l < "$WKFL2")"

  echo "  Resolving paths ..."
  rm -f $WKFL3 ; touch $WKFL3
  while read LINE1 ; do
    HSTR1="$( echo "$LINE1" | awk -F' -> ' '{ print $1 }' | rev | cut -d'/' -f2- | rev )"
    HSTR2="$( echo "$LINE1" | awk -F' ' '{ print $NF }' )"
    echo "$LINE1 ( $HSTR1/$HSTR2 )" >> $WKFL3
    # readlink -f "$LINE1" >> $WKFL3
  done < $WKFL2

  echo "  Determining double links ..."
  rm -f $WKFL4 ; touch $WKFL4
  while read LINE1 ; do
    HSTR1="$( ls -l $( echo "$LINE1" | awk -F'(' '{ print $2 }' | awk -F' )' '{ print $1 }' ) )"
    if [ "$( echo "$HSTR1" | grep ' -> ' )" ] ; then
      echo "$LINE1 -> $( echo "$HSTR1" | awk -F' ' '{ print $NF }' )" >> $WKFL4
    fi
  done < $WKFL3

  LN_NUM1="$( wc -l < "$WKFL4" )"
  if [ "$LN_NUM1" != "0" ] ; then
    echo "  [W:] Found double links: #$LN_NUM1, fixing them ..."
    rm -f $WKFL5 ; touch $WKFL5
    while read LINE1 ; do
      LNK1="$( echo $LINE1 | awk -F' ' '{ print $1 }' )"
      LNK2="$( echo $LINE1 | awk -F' ' '{ print $3 }' | rev | cut -d'/' -f2- | rev )"
      LNK3="$( echo $LINE1 | awk -F' ' '{ print $8 }' )"
      rm "$LNK1"
      if [ -z "$( echo "$LNK2" | grep "/" )" ] ; then
        LNK4="$LNK3"
      else
        LNK4="${LNK2}/${LNK3}"
      fi
      ln -s "${LNK4}" "$LNK1"
      echo "$LNK1 -> $LNK4" >> $WKFL5
    done < $WKFL4
  else
    echo "  No multiple level symlinks found, fix completed."
    SYMLINKS_OK="1"
  fi
done
