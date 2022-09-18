#!/bin/sh

##This script splits an input icon set, the "ARCHIVE1" variable, and builds a primary icon set
##based on a list of required icons, see "*.map1" files. Subsequently the script builds
##a complementary secondary icon set consisting from the remaining icons and symlinks.
##Build process treats and fixes missing symlinks for the primary icon set,
##and takes care about proper data ingegrity for both output icon sets.
##
##Caution: the input icon set must have multiple level symlinks fixed and no broken symlinks.
##So fix the input icon set before running this script.
##
##To get proper Waterleaf input icon set, we need to generate it using command:
## FIX_DOUBLE_LINKS=1 sh 99_generate_waterleaf.sh

cd "$(dirname $0)"
THIS_SCRIPT_DIR="$(pwd)"

SRCDIR="$THIS_SCRIPT_DIR"
WKDIR1="/tmp/.0aaaaax1/"

ARCHIVE1="$1" #input icon set

ICONSET_IN="$WKDIR1/in_iconset/"
ICONSET_OUT1="$WKDIR1/out_iconset-base/"
ICONSET_OUT2="$WKDIR1/out_iconset-extra/"

WKFL01="$WKDIR1/.iconset_in_names.lst" #all icons names list
ICIN_LIST_FL="$WKDIR1/.iconset_in_files.lst" #all icon files full path list
BROKEN_LINKS_LIST="$WKDIR1/.brokenlinks.map1" #unsatisfied symlinks on phase-1

#----------------------------------------------------------------------------------------------
# functions
#----------------------------------------------------------------------------------------------
copy_dir_structure ()
{
#copy empty directory structure including symlinks
#$1 .. source dir
#$2 .. destination dir

#safety check
if [ -z "$2" ] || [ "$(readlink -f "$2")" = "/" ] ; then
  echo "[E:] wrong directory: $2"
  return 10
fi

rsync -a --delete --exclude=*.svg --exclude=*.png --exclude=index.theme "$1/" "$2/"
}

make_lists ()
{
#make standard and extra lists from wanted maps
# read -p "press Enter to continue ..." XXX
local WKFL02="$WKDIR1/.bbb.lst"
if [ -f "$BROKEN_LINKS_LIST" ] ; then
  local BBLST="$BROKEN_LINKS_LIST"
fi
cat $SRCDIR/maps/*.map1 $BBLST | sort -u > $WKFL02
comm -12 $WKFL02 $WKFL01 > $WKDIR1/out1_std.lst
comm -13 $WKFL02 $WKFL01 > $WKDIR1/out2_extra.lst
rm "$WKFL02"
}

create_out_dir ()
{
#$1 .. list of desired icons
#$2 .. output directory

#safety check
if [ -z "$2" ] || [ "$(readlink -f "$2")" = "/" ] ; then
  echo "[E:] wrong directory: $2"
  return 10
fi

#search for matching icon files and list them
# read -p "press Enter to continue ..." XXX
echo "listing matching icon files ..."
local WKFL03="$WKDIR1/.ccc1.lst"
rm -f $WKFL03 ; touch $WKFL03
while read LINEA ; do
  printf '.'
  grep "/$LINEA.png$" "$ICIN_LIST_FL" | grep -F "/$LINEA.png" >> $WKFL03
  grep "/$LINEA.svg$" "$ICIN_LIST_FL" | grep -F "/$LINEA.svg" >> $WKFL03
done < "$1"
unset LINEA
echo

#create splitted iconset tree
echo "copying files ..."
rsync -a --delete --files-from="$WKFL03" "/" "$WKDIR1/"
rm "$WKFL03"

#shift icons dir structure back to the root of output directory
rsync -a "$WKDIR1/$ICONSET_IN/" "$2/"
rm -rf $WKDIR1/tmp/
}

#----------------------------------------------------------------------------------------------
# start
#----------------------------------------------------------------------------------------------

#extract the iconset
# read -p "press Enter to continue ..." XXX
if [ ! -f "$ARCHIVE1/index.theme" ] ; then
  echo "[E:] Iconset source file not found, exiting ..."
  exit 10
fi
echo "cleaning ..."
rm -rf $WKDIR1
mkdir -p $WKDIR1
mkdir -p "$ICONSET_IN"
echo "copying ..."
cp -r $ARCHIVE1/* $ICONSET_IN/

#make icons lists from the input icon set
# read -p "press Enter to continue ..." XXX
echo "create icons listings ..."
find "$ICONSET_IN/" -name "*.svg" -o -name "*.png" | sort -u > $ICIN_LIST_FL
cat "$ICIN_LIST_FL" | awk -F'/' '{ print $(NF) }' | awk -F'\\.png$' '{ print $1 }' | awk -F'\\.svg$' '{ print $1 }' | sort -u > $WKFL01

# #make all symlinks list from the input icon set
# read -p "press Enter to continue ..." XXX
# WKFL04="$WKDIR1/.ddd.lst"
# find "$ICONSET_IN" -type l | xargs file | grep 'symbolic link to' | grep -v 'broken symbolic link' | awk -F'symbolic link to ' '{ print $1"->:"$2 }' | tr -d ' ' | sed 's/:->:/ -> /g' > $WKFL04

echo
echo "phase 1 - create a temporary output dir to create broken symlinks list"
# read -p "press Enter to continue ..." XXX
make_lists
create_out_dir "$WKDIR1/out1_std.lst" "$ICONSET_OUT1"
find "$ICONSET_OUT1" -type l | xargs file | grep 'broken symbolic link to' | awk -F'broken symbolic link to' '{ print $2 }' | awk -F'/' '{ print $(NF) }' | tr -d ' ' | awk -F'\\.png$' '{ print $1 }' | awk -F'\\.svg$' '{ print $1 }' | sort -u > $BROKEN_LINKS_LIST
rm -rf "$ICONSET_OUT1"

echo
echo "phase 2 - create final output dirs - treat broken links"
# read -p "press Enter to continue ..." XXX
make_lists
copy_dir_structure "$ICONSET_IN" "$ICONSET_OUT1"
copy_dir_structure "$ICONSET_IN" "$ICONSET_OUT2"
create_out_dir "$WKDIR1/out1_std.lst" "$ICONSET_OUT1"
create_out_dir "$WKDIR1/out2_extra.lst" "$ICONSET_OUT2"
cp $ICONSET_IN/index.theme $ICONSET_OUT1

echo
echo "perform checkings"
# read -p "press Enter to continue ..." XXX
CHKLST1="$WKDIR1/.checklist1.lst"
CHKLST2="$WKDIR1/.checklist2.lst"
CHKLST3="$WKDIR1/.checklist3.lst"

cd $ICONSET_IN/
find . -name "*.svg" -o -name "*.png" | sort > ../.chk1_in.lst
cd $ICONSET_OUT1/
find . -name "*.svg" -o -name "*.png" | sort > ../.chk1_out.lst
cd $ICONSET_OUT2/
find . -name "*.svg" -o -name "*.png" | sort >> ../.chk1_out.lst
cd ..
cat .chk1_out.lst | sort > .check1_in.lst
cat .chk1_out.lst | sort > .check1_out.lst
rm .chk1_*.lst
comm -3 .check1_in.lst .check1_out.lst > $CHKLST3

# echo "note, this list should be empty, broken links checklist:" > $CHKLST1
find "$ICONSET_OUT1" -type l | xargs file | grep 'broken symbolic link to' >> $CHKLST1
WKFL06="$WKDIR1/.chkwkfl06.lst" #all icons in out iconset 1
find "$ICONSET_OUT1" -name "*.svg" -o -name "*.png" | awk -F'/' '{ print $(NF) }' | awk -F'\\.png$' '{ print $1 }' | awk -F'\\.svg$' '{ print $1 }' | sort -u > $WKFL06
comm -3 $WKFL06 $WKDIR1/out1_std.lst > $CHKLST2
if [ -n "$( cat $CHKLST1 )" ] || [ -n "$( cat $CHKLST2 )" ] || [ -n "$( cat $CHKLST3 )" ] ; then
  echo "[E:] Error: Non-zero checklists, please check the checklists !"
fi
ICONSET_OUT3="$WKDIR1/zout_check_iconset/"
cd $ICONSET_OUT1/
rsync -aR ./ $ICONSET_OUT3/
cd $ICONSET_OUT2/
rsync -aR ./ $ICONSET_OUT3/
