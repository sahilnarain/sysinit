#!/bin/ash

"$(dirname "$0")/tcz-get.sh" kmscon || exit 1

KMSCON_RUNNING=`ps aux | grep /usr/bin/kmscon | grep -v grep`
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
  /usr/bin/kmscon --font-engine unifont --drm --hwaccel
fi
