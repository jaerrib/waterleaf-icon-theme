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
# This script generates the complete icon theme
#-------------------------------------------------------

# --- Check environment ---
echo && wig_read "Before check"
if [ "$(id -u)" = "0" ]; then
  echo ; echo "Please run script as a user, exiting ..."
  exit 100
fi

# --- Initialize ---
echo && wig_read "Before init"
unset LANGUAGE
export LANG="C"
cd $(dirname $0)
THIS_SCRIPT_DIR="$(pwd)"
if [ -z "$HOOKS1DIR" ] ; then
  HOOKS1DIR="$(readlink -m "$THIS_SCRIPT_DIR/hooks/")"
fi
if [ -z "$ADDICONS1DIR" ] ; then
  ADDICONS1DIR="$(readlink -m "$THIS_SCRIPT_DIR/hooks/addicons")"
fi
OUT1_ICSET="$(readlink -m "$THIS_SCRIPT_DIR/../.built1_iconset")"
OUT2_DEBFS="$(readlink -m "$OUT1_ICSET/../.built2_fsdeb/")"
WK1DIR="/tmp/.00_gendeb_iconsname/"
if [ -f "$THIS_SCRIPT_DIR/hooks/hook1_env.sh" ] ; then
  echo "Running hook: $THIS_SCRIPT_DIR/hooks/hook1_env.sh"
  . $THIS_SCRIPT_DIR/hooks/hook1_env.sh
fi
if [ ! -d "$HOOKS1DIR" ] ; then
  echo ; echo "Please specify hooks directory, exiting ..."
  exit 100
fi
if [ ! -d "$ADDICONS1DIR" ] ; then
  echo ; echo "Please specify addicons directory, exiting ..."
  exit 101
fi

# --- Copy files ---
echo && wig_read "Before copy"
rm -rf $WK1DIR
mkdir -p $WK1DIR/
rsync -a --exclude=".git/" --exclude="debian/" --exclude="hooks/" --exclude="$HOOKS1DIR/" --exclude="$ADDICONS1DIR/" $THIS_SCRIPT_DIR/* $WK1DIR/
rsync -a $HOOKS1DIR/* $WK1DIR/
mkdir -p $WK1DIR/addicons
rsync -a $ADDICONS1DIR/* $WK1DIR/addicons/

if [ ! -d "$OUT1_ICSET" ] ; then
  if [ "$SCOURSVG_ADDICONS" != "0" ] ; then
    echo && wig_read "Before scour svg icons"
    cd $WK1DIR/addicons
    find . -name '*.svg' -type f | while read -r ICONFL01 ; do
      printf '.'
      # echo "Scouring $ICONFL01"
      scour --quiet -i $ICONFL01 -o /tmp/.xscrousvgtmp.svg
      cp /tmp/.xscrousvgtmp.svg $ICONFL01
    done
    echo
  fi

  echo && wig_read "Before running hook1_prepare_icons"
  cd $WK1DIR
  if [ -f "$WK1DIR/hook1_prepare_icons.sh" ] ; then
    echo "Running hook: $WK1DIR/hook1_prepare_icons.sh"
    . $WK1DIR/hook1_prepare_icons.sh
  fi

  # --- Modify iconset ---
  echo && wig_read "Before modifications"
  cd $WK1DIR/
  find $WK1DIR/outicons/. -type f,l -name "*.SVG" | xargs rm -f #incorrect file names
  find $WK1DIR/outicons/. -type f,l -name ".directory" | xargs rm -f #incorrect file
  find $WK1DIR/outicons/. -type f,l -name "icon-theme.cache" | xargs rm -f
  if [ -f "$WK1DIR/hook2_iconset_mods.sh" ] ; then
    echo "Running hook: $WK1DIR/hook2_iconset_mods.sh"
    . $WK1DIR/hook2_iconset_mods.sh
  fi

  # --- Override with new specific icons by addicons dir ---
  cd $WK1DIR/
  if [ -f "$WK1DIR/70_override_icons.lst" ] && [ -d "$WK1DIR/addicons" ] ; then
    echo && wig_read "Before custom icons override"
    sh 90_cp_icons.sh "$WK1DIR/addicons/" "$WK1DIR/outicons/" "$WK1DIR/70_override_icons.lst"
  fi

  echo && wig_read "Before symlinks check 1"
  cd $WK1DIR/
  FIX_DOUBLE_LINKS="0" sh 95_fix_symlinks.sh "$WK1DIR/outicons" #remove broken links

  echo && wig_read "Before TDE icons linking"
  cd $WK1DIR/
  TMPFL1="$WK1DIR/.alliconsx1225.lst" #all icons present
  TMPFL2="$WK1DIR/.zzz_tolink_oue.lst" #missing tde icons to link
  find $WK1DIR/outicons/. -name '*.svg' -type f,l -o -name '*.png' -type f,l | awk -F'/' '{ print $NF }' | awk -F'.png$' '{ print $1 }' | awk -F'.svg' '{ print $1 }' | sort -u > $TMPFL1
  sh 00_tde_icon_symlinks.sh "$TMPFL1" > $TMPFL2 #link possible tde icons
  sh 91_link_icons.sh "$WK1DIR/outicons" "$TMPFL2"

  #link icons by custom 71_link_icons.lst
  echo && wig_read "Before custom icons linking"
  cd $WK1DIR/
  if [ -f "$WK1DIR/71_link_icons.lst" ] ; then
    sh 91_link_icons.sh "$WK1DIR/outicons" "$WK1DIR/71_link_icons.lst"
    FIX_DOUBLE_LINKS="0" sh 95_fix_symlinks.sh "$WK1DIR/outicons" #remove broken links
  fi

  echo && wig_read "Before symlinks check 1"
  cd $WK1DIR/
  FIX_DOUBLE_LINKS="1" sh 95_fix_symlinks.sh "$WK1DIR/outicons" #FIX_DOUBLE_LINKS=1 for fixing multiple level symlinks

  if [ "$FIXTDE1_SVG" != "0" ] ; then
    WK2DIR="/tmp/src_svgtdeicons_fix/"
    if [ ! -x "$WK2DIR/src/svgtdefix/svgtdefix" ] ; then
      echo && wig_read "Before compiling "
      rm -rf $WK2DIR ; mkdir -p $WK2DIR
      rsync -a $WK1DIR/src_svgtdeicons_fix $WK2DIR/
      mv $WK2DIR/src_svgtdeicons_fix $WK2DIR/src
      cd $WK2DIR/src
      tqmake base.pro ; make
      if [ ! -x "$WK2DIR/src/svgtdefix/svgtdefix" ] ; then
        echo "Error compiling, exiting ..."
        exit 102
      fi
    fi

    echo && wig_read "Before fixing tde svg icons colors"
    cd $WK1DIR/outicons
    find . -name '*.svg' -type f | while read -r ICONFL01 ; do
      # echo ">>$ICONFL01"
      # rm -f /tmp/zzzx1.svg
      $WK2DIR/src/svgtdefix/svgtdefix $ICONFL01 > /dev/null
      if [ -f "/tmp/zzzx1.svg" ] ; then
        printf 'x'
        cp /tmp/zzzx1.svg $ICONFL01
      else
        printf '.'
      fi
    done
    echo
  fi

  if [ "$SCOURSVG_OUTICONS" != "0" ] ; then
    echo && wig_read "Before scour svg icons"
    cd $WK1DIR/outicons
    find . -name '*.svg' -type f | while read -r ICONFL01 ; do
      if [ -n "$( cat $ICONFL01 | grep '<metadata' )" ] ; then
        # echo "Scouring $ICONFL01"
        printf 'X'
        scour --quiet -i $ICONFL01 -o /tmp/.xscrousvgtmp.svg
        cp /tmp/.xscrousvgtmp.svg $ICONFL01
      else
        printf '.'
      fi
    done
    echo
  fi

  if [ -z "$SIZE_RM" ] ; then
    SIZE_RM="90k"
  fi
  if [ -n "$SIZE_RM" ] && [ "$SIZE_RM" != "0" ] ; then
    echo && wig_read "Before remove icon files consuming more then \"$SIZE_RM\" space."
    cd $WK1DIR/outicons
    find $WK1DIR/outicons/. -type f -name "*.svg" -size +$SIZE_RM | xargs rm -f #icons consuming too much space
  else
    echo "Big sized icons hasn't been removed."
  fi

  # --- Copy result ---
  echo && wig_read "Before result copy"
  rm -rf $OUT1_ICSET
  mkdir -p $OUT1_ICSET/
  rsync -a --no-perms --no-owner --no-group $WK1DIR/outicons/* $OUT1_ICSET/

  echo ; echo " Icon set has been generated in: \"$OUT1_ICSET/\"" ; echo
else
  read -p "[I:] Skipped building iconset, Enter to continue ..." RDVAR1
fi

if [ -z "$OMIT_DEBFS" ] ; then
  echo && wig_read "Before create debfs"
  cd $WK1DIR/
  ICONSET_IN="$OUT1_ICSET/"
  if [ ! -f "$ICONSET_IN/index.theme" ] ; then
    echo
    echo "Input icon set missing, exiting ..."
    exit 100
  fi
  if [ -d "$OUT2_DEBFS" ] ; then
    read -p "Really remove ? $OUT2_DEBFS, press Enter to continue ..." RDVAR1
  fi

  # echo "ICONSET_IN: $ICONSET_IN/"
  # echo "OUT2_DEBFS:  $OUT2_DEBFS/"
  # read -p "Before build debfs, press Enter to continue ..." RDVAR1

  rm -rf "$OUT2_DEBFS" ; mkdir -p "$OUT2_DEBFS/"
  # FIX_DOUBLE_LINKS="1" sh 95_fix_symlinks.sh "$WK1DIR/outicons"
  if [ "$BUILD_TDE_ICONSET" = "1" ] ; then
    MAPS_PATH="$WK1DIR/maps/bb*.map1" sh build_fs.sh "$ICONSET_IN/" "$WK1DIR/pass1/"
    mv "$WK1DIR/pass1/outset1" "$OUT2_DEBFS/out_iconset1-base"
    MAPS_PATH="$WK1DIR/maps/cc*.map1" sh build_fs.sh "$WK1DIR/pass1/outset2/" "$WK1DIR/pass2/"
    mv "$WK1DIR/pass2/outset1" "$OUT2_DEBFS/out_iconset2-tde"
    mv "$WK1DIR/pass2/outset2" "$OUT2_DEBFS/out_iconset3-extra"
  else
    MAPS_PATH="$WK1DIR/maps/*.map1" sh build_fs.sh "$ICONSET_IN/" "$OUT2_DEBFS/"
    mv "$OUT2_DEBFS/outset1" "$OUT2_DEBFS/out_iconset1-base"
    mv "$OUT2_DEBFS/outset2" "$OUT2_DEBFS/out_iconset3-extra"
  fi
else
  read -p "[I:] Skipped building debfs, Enter to continue ..." RDVAR1
fi

# --- Clean ---
# echo && wig_read "Before clean"
# mkdir -p $WK1DIR/_00_fsbuild/
# mv $WK1DIR/usr $WK1DIR/_00_fsbuild/

echo
echo "Completed."
echo
