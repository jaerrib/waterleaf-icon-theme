#!/bin/sh

#script to find additional symlinks for Trinity desktop icons
#
#prepare files: kde4_to_kde3.map: kde4->kde3 mapping
#- get kde4->kde3 maps from src/z*.map
# $ cat src/z*.map | sort -u > a01.map
# $ cat a01.map | awk -F'/' '{ print $2" "$3 }' | awk -F' ' '{ print $1" "$4 }' | awk -F'.png' '{ print $1" >>"$2 }' | sort -u > a02.map
# $ cat a02.map | awk -F' >> ' '{ print $2" << "$1 }' | sort -u > kde4_to_kde3.map
#
#prepare files: all_trinityicons.lst: all trinity icons
# $ cp bb03_tde.map1 all_trinityicons.lst
#
#prepare files: icons.lst: all icons in the default iconset
# $ find . -name "*.svg" -o -name "*.png" | awk -F'/' '{ print $NF }' | awk -F'...g$' '{ print $1 }' | sort -u > icons.lst
#
#output: possible symlinks for Trinity icons from the existing set

#---function---
is_in_lst_file ()
{
  local ICONSTR1="$1"
  local FILE="$2"
  if [ -n "$( cat "$FILE" | grep "^$ICONSTR1$" )" ] ; then
    return 0
  fi
  return 1
}

#---script start---
if [ ! -f "$1" ] ; then
  echo "need input icons list file, exiting ..."
  exit
fi

EXSTING_LST="/tmp/.tmpmap1_existing.lst"
ALL_TDE_LST="/tmp/.tmpmap2_alltde.lst"
MISSING_LST="/tmp/.tmpmap3_missing.lst"
KDE3TO4_LST="/tmp/.tmpmap4_kde4to3.lst"

#generate list of trinity icons missing in the default set
cat "$1" | grep -v "^#" | sort -u > $EXSTING_LST
cat "maps/cc01_tde_list.map1" | grep -v "^#" | sort -u > $ALL_TDE_LST
comm -13 "$EXSTING_LST" "$ALL_TDE_LST" > "$MISSING_LST"

cat "kde4_to_kde3.map" | grep -v "^#" > $KDE3TO4_LST
while read LINE1 ; do
  # echo "processing: $LINE1"
  ICONSTR_TRINITY="$( echo "$LINE1" | awk -F' ' '{ print $1 }' )"
  ICONSTR_SET="$( echo "$LINE1" | awk -F' ' '{ print $3 }' )"
  if is_in_lst_file "$ICONSTR_TRINITY" "$MISSING_LST" ; then
    if is_in_lst_file "$ICONSTR_SET" "$EXSTING_LST" ; then
      # echo "Adding:"
      echo "$ICONSTR_TRINITY  $ICONSTR_SET"
    fi
  fi
done < "$KDE3TO4_LST"
