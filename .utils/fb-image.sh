#!/bin/ash

####################

TMP_DIR=/tmp/fbi

FBI_REMOTE=https://github.com/sahilnarain/sysinit/releases/download/fbi-2.14.3/fbi.tcz
FBI_PATH=$TMP_DIR/fbi.tcz
FBI_MD5=5116d5ee382f2343d4fec48b534cf935

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

check_file $FBI_PATH $FBI_MD5
FBI_INTEGRITY=$?

if [[ $FBI_INTEGRITY -eq 0 ]]
then
  wget $FBI_REMOTE
fi

##########

tce-load -i $TMP_DIR/fbi.tcz

cd /usr/lib/
if  [ -d aarch64-linux-gnu ]
then
  find aarch64-linux-gnu/ | xargs -I "{}" sudo ln -s "{}" . 2&> /dev/null
fi

cd /lib/
if  [ -d aarch64-linux-gnu ]
then
  find aarch64-linux-gnu/ | xargs -I "{}" sudo ln -s "{}" . 2&> /dev/null
fi
