#!/bin/ash

sudo ifconfig wlan0 down
sudo ifconfig wlan0 up

sudo wpa_supplicant -B -i wlan0 -c ~/.config/wpa.conf -d
sudo udhcpc -i wlan0 -r "192.168.1.254"
