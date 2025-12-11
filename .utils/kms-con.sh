#!/bin/ash

####################

TMP_DIR=/tmp/kmscon

KMSCON_REMOTE=https://github.com/sahilnarain/sysinit/releases/download/kmscon-9.0.0/kmscon.tcz
KMSCON_PATH=$TMP_DIR/kmscon.tcz
KMSCON_MD5=ff2099e3b7ed3ffc79e3f07538b3e4b6

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

check_file $KMSCON_PATH $KMSCON_MD5
KMSCON_INTEGRITY=$?

if [[ $KMSCON_INTEGRITY -eq 0 ]]
then
  wget $KMSCON_REMOTE
fi

##########

tce-load -i $TMP_DIR/kmscon.tcz

cd /usr/lib/
find aarch64-linux-gnu/ | xargs -I "{}" sudo ln -s "{}" . 2&> /dev/null

cd /lib/
find aarch64-linux-gnu/ | xargs -I "{}" sudo ln -s "{}" . 2&> /dev/null

KMSCON_RUNNING=`ps aux | grep /usr/libexec/kmscon/kmscon | grep -v grep`
if [ $? -eq 0 ]
then
  KMSCON_RUNNING=1
else
  KMSCON_RUNNING=0
fi

PTS=`tty | grep -q pts`
if [ $? -eq 0 ]
then
  PTS=1
else
  PTS=0
fi

if [[ $KMSCON_RUNNING -eq 1 && $PTS -eq 1 ]]
then
  echo "Nesting KMSCon can be dangerous. Exiting..."
else
  echo "Running KMS..."
  /usr/libexec/kmscon/kmscon --font-engine unifont --drm --hwaccel
fi
