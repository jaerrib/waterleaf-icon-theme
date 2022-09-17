#!/bin/sh

#This script generates the complete Waterleaf icon theme

# --- Check environment ---
echo
read -p "Before check, press enter to continue ..." RDVAR_XYZ
if [ "$(id -u)" = "0" ]; then
  echo
  echo "Please run script as a user, exiting ..."
  exit 100
fi
# if ! whereis papirus-folders ; then
#   echo
#   echo "Please install \"papirus-folders\", exiting ..."
#   exit 110
# fi

# --- Initialize ---
echo
read -p "Before init, press enter to continue ..." RDVAR_XYZ

#Commits defining the fixed points
if [ "$PAPIRUS_20220916" != "1" ] ; then
  COMMIT_PAPIRUS_ICONS="074aa8f2263ecdc5696177baa193e6cbe19b3032" #2021-07-21
else
  COMMIT_PAPIRUS_ICONS="9c6fba831ec71c1c3551e7e31187d0b0d3abb78b" #2022-09-16
fi
COMMIT_PAPIRUS_FOLDERS="6837aa9ca9f1e87040ed7f5d07e23960010d010f" #2022-07-25

cd $(dirname $0)
THIS_SCRIPT_DIR="$(pwd)"
OUTDIR="$THIS_SCRIPT_DIR/../.00built/"
CLONEDIR="$THIS_SCRIPT_DIR/../.clone.tmp/"
WKDIR1="/tmp/.99gendebnr/"
rm -rf $OUTDIR $WKDIR1

# --- Clone Papirus repository ---
echo
read -p "Before clone, press enter to continue ..." RDVAR_XYZ
mkdir -p "$CLONEDIR/"
cd $CLONEDIR/
if [ ! -d "papirus-folders" ] ; then
  git clone https://github.com/PapirusDevelopmentTeam/papirus-folders.git
fi
if [ ! -d "papirus-icon-theme" ] ; then
  git clone https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git
fi

# --- Copy files ---
echo
read -p "Before copy, press enter to continue ..." RDVAR_XYZ
mkdir -p $WKDIR1
cp -r $THIS_SCRIPT_DIR/* $WKDIR1/
cp -r $CLONEDIR/* $WKDIR1/

# --- Checkout Git repositories ---
echo
read -p "Before git checkouts, press enter to continue ..." RDVAR_XYZ
cd $WKDIR1/papirus-icon-theme/
git checkout --detach "$COMMIT_PAPIRUS_ICONS"
cd $WKDIR1/papirus-folders/
git checkout --detach "$COMMIT_PAPIRUS_FOLDERS"

# --- Apply patches ---
echo
read -p "Before patch, press enter to continue ..." RDVAR_XYZ
cd $WKDIR1/papirus-folders/
patch -p1 < $WKDIR1/01_waterleaf_define.patch
cd $WKDIR1/papirus-icon-theme/
if [ "$PAPIRUS_20220916" != "1" ] ; then
  patch -p1 < $WKDIR1/02_waterleaf_colors.patch
else
  patch -p1 < $WKDIR1/02_waterleaf_colors_20220916.patch
fi

# --- Generate colored folder icons ---
echo
read -p "Before build color folders, press enter to continue ..." RDVAR_XYZ
cd $WKDIR1/papirus-icon-theme/
$WKDIR1/papirus-icon-theme/tools/build_color_folders.sh

# --- Override default folder icons ---
echo
read -p "Before defaults override, press enter to continue ..." RDVAR_XYZ
mkdir -p $HOME/.icons/
rm -f $HOME/.icons/Papirus.WorkingTree
ln -s $WKDIR1/papirus-icon-theme/Papirus $HOME/.icons/Papirus.WorkingTree
$WKDIR1/papirus-folders/papirus-folders -t Papirus.WorkingTree -C waterleaf

# --- Edit to change to Waterleaf ---
echo
read -p "Before edit, press enter to continue ..." RDVAR_XYZ
rm -f $HOME/.icons/Papirus.WorkingTree/icon-theme.cache
sed -i "s/Papirus/Waterleaf/" $HOME/.icons/Papirus.WorkingTree/index.theme

# --- Copy result ---
echo
read -p "Before result copy, press enter to continue ..." RDVAR_XYZ
mkdir -p $OUTDIR/Waterleaf/
cp -r $HOME/.icons/Papirus.WorkingTree/* $OUTDIR/Waterleaf/

# --- Override with original Waterleaf icons ---
echo
read -p "Before Waterleaf override, press enter to continue ..." RDVAR_XYZ
touch $WKDIR1/Waterleaf/index.theme
while read LINE1; do
  sh $WKDIR1/90_cp_icon.sh $WKDIR1/Waterleaf/ $OUTDIR/Waterleaf/ "$LINE1.png"
  sh $WKDIR1/90_cp_icon.sh $WKDIR1/Waterleaf/ $OUTDIR/Waterleaf/ "$LINE1.svg"
done < $WKDIR1/70_waterleaf_icons.lst

# # --- Icons linking ---
# echo
# read -p "Before icons linking, press enter to continue ..." RDVAR_XYZ
# while read LINE1; do
#   sh $WKDIR1/91_link_icon.sh $OUTDIR/Waterleaf/ "$LINE1.png"
#   sh $WKDIR1/91_link_icon.sh $OUTDIR/Waterleaf/ "$LINE1.svg"
# done < $WKDIR1/70_waterleaf_icons.lst

# --- Check and fix symbolic links ---
echo
read -p "Before symlinks check, press enter to continue ..." RDVAR_XYZ
sh $WKDIR1/97_fix_symlinks.sh "$OUTDIR/Waterleaf/" #set FIX_DOUBLE_LINKS=1 for fixing multiple level symlinks

# --- Clean ---
echo
read -p "Before clean, press enter to continue ..." RDVAR_XYZ
rm -f $HOME/.icons/Papirus.WorkingTree
