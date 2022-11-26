# --- Check environment ---
if [ "$(id -u)" = "0" ]; then
  echo
  echo "Please run script as a user, exiting ..."
  exit 100
fi

# --- Initialize ---
cd $(dirname $0)
THIS_SCRIPT_DIR="$(pwd)"
WATERLEAF_DIR="$( readlink -f "$(pwd)/../" )"
ICONSET_IN="$(readlink -m "$WATERLEAF_DIR/../.build1_iconset/Waterleaf/")"
DEBFS_OUT="$(readlink -m "$WATERLEAF_DIR/../.build2_fsdeb/")"

# echo "THIS_SCRIPT_DIR: $THIS_SCRIPT_DIR/"
# echo "WATERLEAF_DIR:   $WATERLEAF_DIR/"
# echo "ICONSET_IN:      $ICONSET_IN/"
# echo "DEBFS_OUT:       $DEBFS_OUT/"
# read -p "Before build debfs, press Enter to continue ..." RDVAR1

if [ ! -d "$DEBFS_OUT/out_iconset1-base/" ] ; then
  if [ ! -d "$ICONSET_IN/" ] ; then
    sh "$WATERLEAF_DIR/99_generate_iconset.sh"
  else
    read -p "[I:] Skipped 99_generate_iconset.sh, Enter to continue ..." RDVAR1
  fi
  rm -rf "$DEBFS_OUT/" ; mkdir -p "$DEBFS_OUT/"
  INITF_SYMLINKS="1" MAPS_PATH="$THIS_SCRIPT_DIR/maps/bb*.map1" sh "$WATERLEAF_DIR/q4os/build_fs.sh" "$ICONSET_IN/" "/tmp/.aaaicg1/"
  mv "/tmp/.aaaicg1/outset1" "$DEBFS_OUT/out_iconset1-base"
  INITF_SYMLINKS="0" MAPS_PATH="$THIS_SCRIPT_DIR/maps/cc*.map1" sh "$WATERLEAF_DIR/q4os/build_fs.sh" "/tmp/.aaaicg1/outset2/" "/tmp/.aaaicg2/"
  mv "/tmp/.aaaicg2/outset1" "$DEBFS_OUT/out_iconset2-tde"
  mv "/tmp/.aaaicg2/outset2" "$DEBFS_OUT/out_iconset3-extra"
else
  read -p "[I:] Skipped build_fs.sh, Enter to continue ..." RDVAR1
fi

read -p "Before packages creating, Enter to continue ..." RDVAR1
cd "$WATERLEAF_DIR/q4os/"
sh /opt/program_files/q4os-devpack/bin/create_q4app_setup.sh installer1.cfg
sh /opt/program_files/q4os-devpack/bin/create_q4app_setup.sh installer2.cfg
sh /opt/program_files/q4os-devpack/bin/create_q4app_setup.sh installer3.cfg

echo
echo "Completed."
