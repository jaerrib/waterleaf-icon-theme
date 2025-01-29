#!/bin/sh

echo "Hook1 start."

SETUPDIR="$THIS_SCRIPT_DIR"

if [ "$ACCENTI" = "light" ] ; then
  PAPISCR_DIR="Papirus-Light"
elif [ "$ACCENTI" = "dark" ] ; then
  PAPISCR_DIR="Papirus-Dark"
fi

#Commits defining the fixed points
COMMIT_PAPIRUS_FOLDERS="7ea3dce2e3672dd0a50f4d4a6587589bac6f65e6" #2023-12-10
if [ "$PAPIRUS_VER" = "new" ] ; then
  echo "* Using Papirus icons commit: \"The most recent\""
  COMMIT_PAPIRUS_ICONS="466184391d8a52f21858ccc322701405e5ec06bd" #2024-10-19
  PATCH_ICONS="$WK1DIR/02_waterleaf_colors_20220916.patch"
elif [ "$PAPIRUS_VER" = "1" ] ; then
  echo "* Using Papirus icons commit: \"$PAPIRUS_VER\""
  COMMIT_PAPIRUS_ICONS="466184391d8a52f21858ccc322701405e5ec06bd" #2024-10-19
  PATCH_ICONS="$WK1DIR/02_waterleaf_colors_20220916.patch"
else
  echo "* Using Papirus icons commit: \"Waterleaf stable\""
  COMMIT_PAPIRUS_ICONS="074aa8f2263ecdc5696177baa193e6cbe19b3032" #2021-07-21
  PATCH_ICONS="$WK1DIR/02_waterleaf_colors_001.patch"
fi

echo && wig_read "Before upstream copy"
rsync -a $SETUPDIR/../.clone.tmp/* $WK1DIR/

# --- Checkout Git repositories ---
echo && wig_read "Before git checkouts"
cd $WK1DIR/papirus-folders/
git checkout --detach "$COMMIT_PAPIRUS_FOLDERS"
cd $WK1DIR/papirus-icon-theme/
git checkout --detach "$COMMIT_PAPIRUS_ICONS"

# --- Apply patches ---
echo && wig_read "Before patch"
if [ -n "$PATCH_ICONS" ] ; then
  cd $WK1DIR/papirus-icon-theme/
  patch -p1 < $PATCH_ICONS
fi

# --- Generate colored folder icons ---
echo && wig_read "Before build color folders"
cd $WK1DIR/papirus-icon-theme/
$WK1DIR/papirus-icon-theme/tools/build_color_folders.sh

# --- Copy the accent theme ---
if [ -n "$PAPISCR_DIR" ] && [ -d "$WK1DIR/papirus-icon-theme/$PAPISCR_DIR" ] ; then
  echo && wig_read "Before accent apply"
  cd $WK1DIR/papirus-icon-theme/$PAPISCR_DIR
  find . -name '*.svg' -type f -o -name '*.png' -type f | while read -r ICONFL01 ; do
    printf '.'
    # echo "$WK1DIR/papirus-icon-theme/$PAPISCR_DIR/$ICONFL01 >>cp>> $WK1DIR/papirus-icon-theme/Papirus/$ICONFL01"
    mkdir -p "$( dirname "$WK1DIR/papirus-icon-theme/Papirus/$ICONFL01" )"
    cp --remove-destination $WK1DIR/papirus-icon-theme/$PAPISCR_DIR/$ICONFL01 $WK1DIR/papirus-icon-theme/Papirus/$ICONFL01
  done
  echo
  cp $WK1DIR/papirus-icon-theme/$PAPISCR_DIR/index.theme  $WK1DIR/papirus-icon-theme/Papirus/index.theme
fi

# --- Override default folder icons ---
echo && wig_read "Before defaults override"
mkdir -p $HOME/.icons/
cd $HOME/.icons
rm -f $HOME/.icons/Papirus.WorkingTree
ln -s $WK1DIR/papirus-icon-theme/Papirus $HOME/.icons/Papirus.WorkingTree
$WK1DIR/papirus-folders/papirus-folders --theme Papirus.WorkingTree -C waterleaf
$WK1DIR/papirus-folders/papirus-folders --theme Papirus.WorkingTree -l
# read -p ... RDVL #view the active theme
rm -f $HOME/.icons/Papirus.WorkingTree

# --- Specific edits to the source iconset ---
echo && wig_read "Before modifications"
cd $WK1DIR/papirus-icon-theme/
if [ -z "$PAPISCR_DIR" ] ; then
  cp $WK1DIR/addicons/16x16/places/16wlf_folder-documents.svg $WK1DIR/papirus-icon-theme/Papirus/16x16/places/folder-documents.svg #override 16px icon only
  cp $WK1DIR/addicons/16x16/places/16wlf_folder.svg $WK1DIR/papirus-icon-theme/Papirus/16x16/places/folder.svg #override 16px icon only
elif [ "$PAPISCR_DIR" = "Papirus-Light" ] ; then
  cp $WK1DIR/addicons/16x16/places/16wlf_folder-documents.svg $WK1DIR/papirus-icon-theme/Papirus/16x16/places/folder-documents.svg #override 16px icon only
  cp $WK1DIR/addicons/16x16/places/16wlf_folder.svg $WK1DIR/papirus-icon-theme/Papirus/16x16/places/folder.svg #override 16px icon only
elif [ "$PAPISCR_DIR" = "Papirus-Dark" ] ; then
  cp $WK1DIR/addicons/16x16/places/16wlg_folder-documents.svg $WK1DIR/papirus-icon-theme/Papirus/16x16/places/folder-documents.svg #override 16px icon only
  cp $WK1DIR/addicons/16x16/places/16wlg_folder.svg $WK1DIR/papirus-icon-theme/Papirus/16x16/places/folder.svg #override 16px icon only
fi
sed -i "s/Papirus/Waterleaf/" $WK1DIR/papirus-icon-theme/Papirus/index.theme
rm -f $WK1DIR/papirus-icon-theme/Papirus/icon-theme.cache

# --- Copy result ---
echo && wig_read "Before result copy"
mkdir -p $WK1DIR/outicons
cp -r $WK1DIR/papirus-icon-theme/Papirus/* $WK1DIR/outicons/

echo "Hook1 done."
