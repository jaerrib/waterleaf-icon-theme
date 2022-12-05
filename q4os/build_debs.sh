# --- Check environment ---
if [ "$(id -u)" = "0" ]; then
  echo
  echo "Please run script as a user, exiting ..."
  exit 100
fi

# --- Initialize ---
cd $(dirname $0)
BASE_DIR="$( readlink -f "$(pwd)/../" )"
ICONSET_IN="$(readlink -m "$BASE_DIR/../.build1_iconset/Waterleaf/")"
DEBFS_OUT="$(readlink -m "$BASE_DIR/../.build2_fsdeb/")"
BUILD_TDE_ICONSET="1"

# echo "BASE_DIR:   $BASE_DIR/"
# echo "ICONSET_IN: $ICONSET_IN/"
# echo "DEBFS_OUT:  $DEBFS_OUT/"
# read -p "Before build debfs, press Enter to continue ..." RDVAR1

if [ ! -d "$DEBFS_OUT/out_iconset1-base/" ] ; then
  if [ ! -d "$ICONSET_IN/" ] ; then
    sh "$BASE_DIR/99_generate_iconset.sh"
  else
    read -p "[I:] Skipped 99_generate_iconset.sh, Enter to continue ..." RDVAR1
  fi
  rm -rf "$DEBFS_OUT" ; mkdir -p "$DEBFS_OUT/"
  if [ "$BUILD_TDE_ICONSET" = "1" ] ; then
    WKDIR1="/tmp/.build_debs_icons_1a/"
    rm -rf "$WKDIR1" ; mkdir -p "$WKDIR1/"
    INITF_SYMLINKS="1" MAPS_PATH="$BASE_DIR/q4os/maps/bb*.map1" sh "$BASE_DIR/q4os/build_fs.sh" "$ICONSET_IN/" "$WKDIR1/pass1/"
    mv "$WKDIR1/pass1/outset1" "$DEBFS_OUT/out_iconset1-base"
    INITF_SYMLINKS="0" MAPS_PATH="$BASE_DIR/q4os/maps/cc*.map1" sh "$BASE_DIR/q4os/build_fs.sh" "$WKDIR1/pass1/outset2/" "$WKDIR1/pass2/"
    mv "$WKDIR1/pass2/outset1" "$DEBFS_OUT/out_iconset2-tde"
    mv "$WKDIR1/pass2/outset2" "$DEBFS_OUT/out_iconset3-extra"
  else
    INITF_SYMLINKS="1" MAPS_PATH="$BASE_DIR/q4os/maps/*.map1" sh "$BASE_DIR/q4os/build_fs.sh" "$ICONSET_IN/" "$DEBFS_OUT/"
    mv "$DEBFS_OUT/outset1" "$DEBFS_OUT/out_iconset1-base"
    mv "$DEBFS_OUT/outset2" "$DEBFS_OUT/out_iconset3-extra"
  fi
else
  read -p "[I:] Skipped build_fs.sh, Enter to continue ..." RDVAR1
fi

if [ "$NO_CREATE_DEBS" != "1" ] ; then
  cd "$BASE_DIR/q4os/"
  sh /opt/program_files/q4os-devpack/bin/create_q4app_setup.sh installer1.cfg
  if [ "$BUILD_TDE_ICONSET" = "1" ] ; then
    sh /opt/program_files/q4os-devpack/bin/create_q4app_setup.sh installer2.cfg
  fi
  sh /opt/program_files/q4os-devpack/bin/create_q4app_setup.sh installer3.cfg
fi

echo
echo "Completed."
