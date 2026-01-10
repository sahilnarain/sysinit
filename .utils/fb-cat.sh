#!/bin/ash

####################

TMP_DIR=/tmp/fbcat

FBCAT_REMOTE=https://github.com/sahilnarain/sysinit/releases/download/fbcat-0.5.1/fbcat.tcz
FBCAT_PATH=$TMP_DIR/fbcat.tcz
FBCAT_MD5=3b2c86135f7679a99ade90aadcf326d7

####################

function check_file_exists() {
  if [ -f $1 ]
  then
    return 1
   else
    return 0
   fi
}

function check_file() {
  check_file_exists $1
  if [ $? -eq 0 ]
  then
    return 0
  fi

  result=`md5sum $1 | grep -q $2`
  if [ $? -eq 0 ]
  then
    return 1
  else
    rm -rf $1
    return 0
  fi
}

####################

if [ ! -d $TMP_DIR ]
then
  mkdir $TMP_DIR
fi

cd $TMP_DIR

##########

check_file $FBCAT_PATH $FBCAT_MD5
FBCAT_INTEGRITY=$?

if [[ $FBCAT_INTEGRITY -eq 0 ]]
then
  wget $FBCAT_REMOTE
fi

##########

tce-load -i $TMP_DIR/fbcat.tcz

cd /usr/lib/
find aarch64-linux-gnu/ | xargs -I "{}" sudo ln -s "{}" . 2&> /dev/null

cd /lib/
find aarch64-linux-gnu/ | xargs -I "{}" sudo ln -s "{}" . 2&> /dev/null
