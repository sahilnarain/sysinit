#!/bin/ash

mount /dev/mmcblk0p1
set -- `ls /mnt/mmcblk0p1/custom/fonts`

index=1
for font in `ls /mnt/mmcblk0p1/custom/fonts/`
do
  echo $index : $font
  index=$((index+1))
done

read option

if [[ $option -lt 1 || $option -gt $index ]]
then
  echo "Invalid choice."
  umount /mnt/mmcblk0p1
  exit
fi

eval "font=\$$option"

echo $font

echo "Setting font: $font"
loadfont < /mnt/mmcblk0p1/custom/fonts/$font
echo "Done"
sleep 1
clear

umount /mnt/mmcblk0p1
