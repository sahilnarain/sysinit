#!/bin/ash

function rotateDisplayAnticlockwise(){
  ORIENTATION=`cat /sys/class/graphics/fbcon/rotate`
  NEW_ORIENTATION=$(( (( (($ORIENTATION-1)) + 4 )) % 4))
  echo $NEW_ORIENTATION | sudo tee /sys/class/graphics/fbcon/rotate > /dev/null
}

rotateDisplayAnticlockwise
