#!/bin/sh

##This script splits an input icon set, the "ARCHIVE1" variable, and builds a primary icon set
##based on a list of required icons, see "*.map1" files. Subsequently the script builds
##a complementary secondary icon set consisting from the remaining icons and symlinks.
##Build process treats and fixes missing symlinks for the primary icon set,
##and takes care about proper data ingegrity for both output icon sets.

cd "$(dirname $0)"
THIS_SCRIPT_DIR="$(pwd)"

WKDIR1="$(mktemp -d -t ".00_spliticonset_XXXXXXXXXX")/"

ARCHIVE1="$1" #input icon set
OUTDIR1="$2" #output dir

ICONSET_IN="$WKDIR1/in_iconset/"
ICONSET_OUT1="$WKDIR1/outset1/"
ICONSET_OUT2="$WKDIR1/outset2/"

WKFL01="$WKDIR1/.iconset_in_names.lst" #all icons names list
ICIN_LIST_FL="$WKDIR1/.iconset_in_files.lst" #all icon files full path list
BROKEN_LINKS_LIST="$WKDIR1/.brokenlinks.map" #unsatisfied symlinks on phase-1

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

rsync -a --delete --exclude=*.svg --exclude=*.png --exclude=COPYING --exclude=AUTHORS --exclude=index.theme "$1/" "$2/"
}

make_lists ()
{
#make standard and extra lists from wanted maps
# read -p "press Enter to continue ..." XXX
local WKFL02="$WKDIR1/.bbb.lst"
if [ -f "$BROKEN_LINKS_LIST" ] ; then
  local BBLST="$BROKEN_LINKS_LIST"
fi
cat $MAPS_PATH $BBLST | sort -u > $WKFL02
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
if [ ! -f "$ARCHIVE1/index.theme" ] && [ ! -d "$ARCHIVE1/32x32/" ] && [ ! -d "$ARCHIVE1/places/" ] ; then
  echo "[E:] Iconset source file not found, exiting ..."
  exit 10
fi
if [ -z "$OUTDIR1" ] || [ "$OUTDIR1" = "/" ] ; then
  echo "[E:] Incorrect output directory, exiting ..."
  exit 11
fi
if [ -z "$MAPS_PATH" ] || [ -z "$( ls $MAPS_PATH )" ] ; then
  echo "[E:] Map files $MAPS_PATH don't exist, exiting ..."
  exit 12
fi
echo
echo "Building icon theme directories ..."
echo "Cleaning ..."
# rm -rf $WKDIR1
# mkdir -p $WKDIR1
mkdir -p "$ICONSET_IN"
echo "Copying ..."
cp -r $ARCHIVE1/* $ICONSET_IN/


if [ "$INITF_SYMLINKS" = "1" ] ; then
  #caution: the input icon set must have multiple level symlinks fixed and no broken symlinks,
  #so fix the input icon set first
  FIX_DOUBLE_LINKS="1" sh 95_fix_symlinks.sh "$ICONSET_IN/"
fi

#make icons lists from the input icon set
# read -p "press Enter to continue ..." XXX
echo "Create icons listings ..."
find "$ICONSET_IN/" -name '*.svg' -o -name '*.png' | sort -u > $ICIN_LIST_FL
cat "$ICIN_LIST_FL" | awk -F'/' '{ print $(NF) }' | awk -F'\\.png$' '{ print $1 }' | awk -F'\\.svg$' '{ print $1 }' | sort -u > $WKFL01

# #make all symlinks list from the input icon set
# read -p "press Enter to continue ..." XXX
# WKFL04="$WKDIR1/.ddd.lst"
# find "$ICONSET_IN" -type l | xargs file | grep 'symbolic link to' | grep -v 'broken symbolic link' | awk -F'symbolic link to ' '{ print $1"->:"$2 }' | tr -d ' ' | sed 's/:->:/ -> /g' > $WKFL04

echo
echo "Phase 1 - create a temporary output dir to create broken symlinks list"
# read -p "press Enter to continue ..." XXX
make_lists
create_out_dir "$WKDIR1/out1_std.lst" "$ICONSET_OUT1"
find "$ICONSET_OUT1" -type l | xargs file | grep 'broken symbolic link to' | awk -F'broken symbolic link to' '{ print $2 }' | awk -F'/' '{ print $(NF) }' | tr -d ' ' | awk -F'\\.png$' '{ print $1 }' | awk -F'\\.svg$' '{ print $1 }' | sort -u > $BROKEN_LINKS_LIST
rm -rf "$ICONSET_OUT1"

echo
echo "Phase 2 - create final output dirs - treat broken links"
# read -p "press Enter to continue ..." XXX
make_lists
copy_dir_structure "$ICONSET_IN" "$ICONSET_OUT1"
copy_dir_structure "$ICONSET_IN" "$ICONSET_OUT2"
create_out_dir "$WKDIR1/out1_std.lst" "$ICONSET_OUT1"
create_out_dir "$WKDIR1/out2_extra.lst" "$ICONSET_OUT2"
cp $ICONSET_IN/index.theme $ICONSET_OUT1

echo
echo "Perform checkings ..."
# read -p "press Enter to continue ..." XXX
CHKLST1="$WKDIR1/.checklist1.lst" #broken links checklist
CHKLST2="$WKDIR1/.checklist2.lst" #check if primary icon set listing matches icons in the generated icon set
CHKLST3="$WKDIR1/.checklist3.lst" #sum of icons in output icon sets must give all the icons in the input icon set
CHKLST4="$WKDIR1/.checklist4.lst" #check for conflicting files in both iconsets

#broken links checklist
find "$ICONSET_OUT1" -type l | xargs file | grep 'broken symbolic link to' >> $CHKLST1
WKFL06="$WKDIR1/.chkwkfl06.lst" #all icons in out iconset 1

#check if primary icon set listing matches icons in the generated icon set
find "$ICONSET_OUT1" -name '*.svg' -o -name '*.png' | awk -F'/' '{ print $(NF) }' | awk -F'\\.png$' '{ print $1 }' | awk -F'\\.svg$' '{ print $1 }' | sort -u > $WKFL06
comm -3 $WKFL06 $WKDIR1/out1_std.lst > $CHKLST2

#check if sum of icons in output icon sets gives all icons in the input icon set
cd $ICONSET_IN/
find . -name '*.svg' -type f,l -o -name '*.png' -type f,l | sort > $WKDIR1/chk1_in.lst
cd $ICONSET_OUT1/
find . -name '*.svg' -type f,l -o -name '*.png' -type f,l | sort > $WKDIR1/chk1_out.lst
cd $ICONSET_OUT2/
find . -name '*.svg' -type f,l -o -name '*.png' -type f,l | sort >> $WKDIR1/chk1_out.lst
cat $WKDIR1/chk1_in.lst | sort > $WKDIR1/check1_in.lst
cat $WKDIR1/chk1_out.lst | sort > $WKDIR1/check1_out.lst
rm $WKDIR1/chk1_in.lst $WKDIR1/chk1_out.lst
comm -3 $WKDIR1/check1_in.lst $WKDIR1/check1_out.lst > $CHKLST3
rm $WKDIR1/check1_in.lst $WKDIR1/check1_out.lst

#check for conflicting files in both iconsets
cd $ICONSET_OUT1/
find -L . -type f,l | sort > $WKDIR1/mchk_1.lst
cd $ICONSET_OUT2/
find -L . -type f,l | sort > $WKDIR1/mchk_2.lst
comm -12 $WKDIR1/mchk_1.lst $WKDIR1/mchk_2.lst > $CHKLST4
rm $WKDIR1/mchk_1.lst $WKDIR1/mchk_2.lst

#generate a control icon set
ICONSET_OUT3="$WKDIR1/zout_check_iconset/"
cd $ICONSET_OUT1/
rsync -aR ./ $ICONSET_OUT3/
cd $ICONSET_OUT2/
rsync -aR ./ $ICONSET_OUT3/

echo
echo "Moving result to the output directory and cleaning..."
rm -rf "$OUTDIR1" ; mkdir -p "$OUTDIR1/"
mv "$ICONSET_OUT1" "$OUTDIR1/"
mv "$ICONSET_OUT2" "$OUTDIR1/"
if [ -n "$( cat $CHKLST1 )" ] || [ -n "$( cat $CHKLST2 )" ] || [ -n "$( cat $CHKLST3 )" ] || [ -n "$( cat $CHKLST4 )" ] ; then
  echo "[E:] Error: Non-zero checklists, please check the checklists !" ; sleep 10
  # read -p "  ..press Enter to continue ..." RDVAR1
  rm -rf "$WKDIR1"
fi

echo
echo "Completed. Filesystem has been prepared in: \"$OUTDIR1\""
echo
