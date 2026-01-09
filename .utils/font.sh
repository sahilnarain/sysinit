#!/bin/ash

clear
mount /dev/mmcblk0p1
set -- `ls /mnt/mmcblk0p1/custom/fonts`

echo "Pick font #"
index=1
for font in `ls /mnt/mmcblk0p1/custom/fonts/`
do
  echo $index : $font
  index=$((index+1))
done
echo

read option

if [[ $option -lt 1 || $option -gt $index ]]
then
  echo "Invalid choice."
  umount /mnt/mmcblk0p1
  exit
fi

eval "font=\$$option"

echo "Setting font: $font"
loadfont < /mnt/mmcblk0p1/custom/fonts/$font
echo "Done"
echo
sleep 1
clear

umount /mnt/mmcblk0p1
