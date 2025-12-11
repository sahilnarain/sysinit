#!/bin/ash

####################

TMP_DIR=/tmp/fbterm

FBTERM_REMOTE=https://github.com/sahilnarain/sysinit/releases/download/fbterm-1.7.5/fbterm.tcz
FBTERM_PATH=$TMP_DIR/fbterm.tcz
FBTERM_MD5=cd9e29cb1ef7ef31c1a240d2e01fac47

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

check_file $FBTERM_PATH $FBTERM_MD5
FBTERM_INTEGRITY=$?

if [[ $FBTERM_INTEGRITY -eq 0 ]]
then
  wget $FBTERM_REMOTE
fi

##########

tce-load -i $TMP_DIR/fbterm.tcz

cd /usr/lib/
find aarch64-linux-gnu/ | xargs -I "{}" sudo ln -s "{}" . 2&> /dev/null

cd /lib/
find aarch64-linux-gnu/ | xargs -I "{}" sudo ln -s "{}" . 2&> /dev/null

/usr/bin/fbterm --font-name="JetBrains Mono:style=SemiBold" --font-size=12 -- /bin/login
