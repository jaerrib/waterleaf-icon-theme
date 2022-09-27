#!/bin/sh

#-------------------------------------------------------
# function: wig_read
#
# $1 .. Message
#-------------------------------------------------------
wig_read ()
{
  local M1MSG="$1"
  local RDVAR_XYZ
  if [ "$CONFIRMS" = "1" ] ; then
    read -p "$M1MSG, press Enter to continue ..." RDVAR_XYZ
  else
    echo "$M1MSG > working ..."
  fi
}

#-------------------------------------------------------
# main entry
#
# This script generates the complete Waterleaf icon theme
#-------------------------------------------------------

# --- Check environment ---
echo
wig_read "Before check"
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
wig_read "Before init"

#Commits defining the fixed points
if [ "$PAPIRUS_20220916" != "1" ] ; then
  COMMIT_PAPIRUS_ICONS="074aa8f2263ecdc5696177baa193e6cbe19b3032" #2021-07-21
else
  COMMIT_PAPIRUS_ICONS="9c6fba831ec71c1c3551e7e31187d0b0d3abb78b" #2022-09-16
fi
COMMIT_PAPIRUS_FOLDERS="6837aa9ca9f1e87040ed7f5d07e23960010d010f" #2022-07-25

cd $(dirname $0)
THIS_SCRIPT_DIR="$(pwd)"
OUTDIR="$(readlink -m "$THIS_SCRIPT_DIR/../.build1_iconset/")"
CLONEDIR="$THIS_SCRIPT_DIR/../.clone.tmp/"
WKDIR1="/tmp/.00_gendebnr_wtrlf/"
rm -rf $OUTDIR $WKDIR1

# --- Clone Papirus repository ---
echo
wig_read "Before clone"
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
wig_read "Before copy"
mkdir -p $WKDIR1/
cp -r $THIS_SCRIPT_DIR/* $WKDIR1/
cp -r $CLONEDIR/* $WKDIR1/

# --- Checkout Git repositories ---
echo
wig_read "Before git checkouts"
cd $WKDIR1/papirus-icon-theme/
git checkout --detach "$COMMIT_PAPIRUS_ICONS"
cd $WKDIR1/papirus-folders/
git checkout --detach "$COMMIT_PAPIRUS_FOLDERS"

# --- Apply patches ---
echo
wig_read "Before patch"
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
wig_read "Before build color folders"
cd $WKDIR1/papirus-icon-theme/
$WKDIR1/papirus-icon-theme/tools/build_color_folders.sh

# --- Override default folder icons ---
echo
wig_read "Before defaults override"
mkdir -p $HOME/.icons/
rm -f $HOME/.icons/Papirus.WorkingTree
ln -s $WKDIR1/papirus-icon-theme/Papirus $HOME/.icons/Papirus.WorkingTree
$WKDIR1/papirus-folders/papirus-folders -t Papirus.WorkingTree -C waterleaf

# --- Edits to modify iconset ---
echo
wig_read "Before modifications"
rm -f $HOME/.icons/Papirus.WorkingTree/icon-theme.cache
sed -i "s/Papirus/Waterleaf/" $HOME/.icons/Papirus.WorkingTree/index.theme

# --- Copy result ---
echo
wig_read "Before result copy"
mkdir -p $OUTDIR/Waterleaf/
cp -r $HOME/.icons/Papirus.WorkingTree/* $OUTDIR/Waterleaf/

# --- Override with new specific icons ---
echo
wig_read "Before Waterleaf override"
touch $WKDIR1/Waterleaf/index.theme
sh $WKDIR1/90_cp_icons.sh "$WKDIR1/Waterleaf/" "$OUTDIR/Waterleaf/" "$WKDIR1/70_override_icons.lst"

# --- Icons linking ---
echo
wig_read "Before icons linking"
sh $WKDIR1/91_link_icons.sh "$OUTDIR/Waterleaf/" "$WKDIR1/71_link_icons.lst"

# --- Check and fix symbolic links ---
echo
wig_read "Before symlinks check"
sh $WKDIR1/95_fix_symlinks.sh "$OUTDIR/Waterleaf/" #set FIX_DOUBLE_LINKS=1 for fixing multiple level symlinks

# --- Clean ---
echo
wig_read "Before clean"
rm -f $HOME/.icons/Papirus.WorkingTree

# --- Complete ---
echo
echo "Completed >"
echo " Waterleaf icon set has been generated in: \"$OUTDIR/\""
echo
