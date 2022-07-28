#!/usr/bin/sh

REBOOT_REQUIRED="no"
### NVIDIA DRIVER CHECK ####

nvgpu=$(lspci | grep -iE 'VGA|3D' | grep -i nvidia | cut -d ":" -f 3)
nvkernmod=$(lspci -k | grep -iEA3 'VGA|3D' | grep -iA3 nvidia | grep -i 'kernel driver' | grep -iE 'vfio-pci|nvidia')

if [[ ! -z $nvgpu ]]; then
    if [[ -z $nvkernmod  ]]; then
      # Check for internet connection
      wget -q --spider http://google.com
      if [ $? -eq 0 ]; then

      zenity --question \
        --title="Nvidia GPU Hardware Detected" \
        --width=600 \
        --text="`printf "The following Nvidia hardware has been found on your system:\n\n
                $nvgpu\n\n
This hardware requires 3rd party Nvidia drivers to be installed in order to function correctly.\n\n
By pressing 'Yes', you will be prompted for your password in order to install these drivers.\n\n"`"

case $? in
    0)
      PASSWD="$(zenity --password)\n"
      (
        echo "# Installing Nvidia drivers"
        echo "10"; sleep 1
        echo "# Installing Nvidia drivers"
        echo "50"; sleep 1
        echo "# Updating to latest kernel (required for Nvidia drivers)"
        echo -e $PASSWD | sudo -S dnf install -y kernel kernel-headers
        echo "# Purging any previous lingering nvidia drivers/packages"
        sudo -S dnf remove -y akmod-nvidia xorg-x11-drv-nvidia-cuda
        sudo -S dnf remove -y nvidia-settings xorg-x11-drv-nvidia* kmod-nvidia
        echo "# Installing Nvidia drivers"
        sudo -S dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
        echo "75"; sleep 1
        echo "# Nvidia driver installation complete!"
        echo "100"; sleep 1
      ) | zenity --title "Nvidia GPU Hardware Detected" --progress --no-cancel --width=600 --percentage=0
      # reset kscsreen settings
      rm -Rf /home/$USER/.local/share/kscreen
      # remove any previous declined answer
      rm /home/$USER/.config/nvcheck-declined
      REBOOT_REQUIRED="yes"
	;;
	*)
	# User declined to install nvidia drivers
    zenity --info\
        --title="Nvidia GPU Hardware Detected" \
        --width=600 \
        --text="`printf "We will not ask you this again until your next login.\n\n"`"
	echo 1 > /home/$USER/.config/nvcheck-declined
	exit 0
	;;
esac
      else
        # No internet connection found
        zenity --info\
          --title="No Internet connection." \
          --width=600 \
          --text="`printf "An internet connection is required to install Nvidia drivers. Once your system is connected to the internet, run 'hwcheck.sh' from the terminal to restart the installer.\n\n"`"
        echo 1 > /home/$USER/.config/nvcheck-declined
        exit 0
      fi
    fi
fi

### END NVIDIA DRIVER CHECK ####

### XBOX CONTROLLER FIRMWARE CHECK ####

lpf=$(rpm -qa | grep 'lpf-xone-firmware')
xbfirmware=$(rpm -qa | grep 'xone-firmware'| wc -l)

if [[ ! -z $lpf ]]; then
  if [ "$xbfirmware" != "2" ]; then
      # Check for internet connection
      wget -q --spider http://google.com
      if [ $? -eq 0 ]; then

      zenity --question\
        --title="Xbox Controller firmware installer" \
        --width=600 \
        --text="`printf "A firmware update is required for Xbox Wireless controllers to work. Would you like to perform this now?\n\n"`"

case $? in
    0)
      PASSWD="$(zenity --password)\n"
      (
        echo -e $PASSWD | sudo -S usermod -aG pkg-build $USER
        echo -e $PASSWD | sudo -S dnf install -y lpf-xone-firmware xone
        echo -e $PASSWD | sudo -S dnf remove -y xone-firmware
        echo -e $PASSWD | sudo -S exec su - $USER
        echo -e $PASSWD | sudo -S -u $USER lpf reset xone-firmware
        echo -e $PASSWD | sudo -S -u $USER lpf approve xone-firmware
        echo -e $PASSWD | sudo -S -u $USER lpf build xone-firmware
        echo -e $PASSWD | sudo -S -u $USER lpf install xone-firmware
        echo "75"; sleep 1
        echo "# Xbox Controller firmware installation complete!"
        echo "100"; sleep 1
      ) | zenity --title="Xbox Controller firmware installer" --progress --no-cancel --width=600 --percentage=0
      # remove any previous declined answer
      rm /home/$USER/.config/xbcheck-declined
      REBOOT_REQUIRED="yes"
	;;
	*)
	# User declined to install firmware
    zenity --info\
        --title="Xbox Controller firmware installer" \
        --width=600 \
        --text="`printf "We will not ask you this again until your next login.\n\n"`"
	echo 1 > /home/$USER/.config/xbcheck-declined
	exit 0
	;;
esac
      else
        # No internet connection found
        zenity --info\
          --title="No Internet connection." \
          --width=600 \
          --text="`printf "An internet connection is required to install the Xbox Controller firmware. Once your system is connected to the internet, run 'hwcheck.sh' from the terminal to restart the installer.\n\n"`"
        echo 1 > /home/$USER/.config/xbcheck-declined
        exit 0
      fi
  fi
fi
### END XBOX CONTROLLER FIRMWARE CHECK ####

if [ "$REBOOT_REQUIRED" == "yes" ]; then

     zenity --question \
       --title="Reboot Required." \
       --width=600 \
       --text="`printf "The system requires a reboot before newly installed drivers and firmware can take effect. Would you like to reboot now?\n\n"`"

     if [ $? = 0 ]; then
       reboot
     else
   	exit 0
     fi
fi


exit 0
