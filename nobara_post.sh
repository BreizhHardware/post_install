if [[ $EUID -ne 0 ]]
then
	sudo chmod +x $(dirname $0)/$0
	sudo $(dirname $0)/$0
	exit;
fi
isvbox=$(LANG=C hostnamectl | grep -i virtualization | grep -c oracle)
isfm=$(grep -c fastestmirror /etc/dnf/dnf.conf)
if [[ "$isfm" -eq "0" ]]
then
	echo "fastestmirror=1" >> /etc/dnf/dnf.conf
fi 

dnf -y --nogpgcheck --refresh upgrade
dnf install -y gnome-shell-extension-dash-to-dock htop nmon inxi figlet
dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
dnf install -y lame\* --exclude=lame-devel
dnf group upgrade -y --with-optional Multimedia
git clone https://github.com/bikass/kora.git
cd kora/
cp -R kora /usr/share/icons/
cd ..
rm -rf kora
dnf -y autoremove blender kdenlive libreoffice-* lutris protonup-qt winehq-staging wine-staging-common wine-staging64 winetricks yumex-dnf inkscape hplip-common hplip-libs hplip-gui
dnf -y autoremove baobab cheese epiphany gnome-{calendar,characters,clocks,contacts,dictionary,disk-utility,font-viewer,logs,maps,photos,user-docs,,weather} gucharmap sushi
echo "[vscode]" > /etc/yum.repos.d/vscode.repo
echo "name=Visual Studio Code" >> /etc/yum.repos.d/vscode.repo
echo "baseurl=https://packages.microsoft.com/yumrepos/vscode" >> /etc/yum.repos.d/vscode.repo
echo "enabled=1" >> /etc/yum.repos.d/vscode.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/vscode.repo
echo "gpgkey=https://packages.microsoft.com/keys/microsoft.asc" >> /etc/yum.repos.d/vscode.repo
rpm --import https://packages.microsoft.com/keys/microsoft.asc
dnf update
dnf install -y code
wget https://raw.githubusercontent.com/BreizhHardware/post_install/main/hwcheck.sh >> hwcheck.sh
chmod u+x hwcheck.sh
sh hwcheck.sh
echo "Préparation terminée, il est recommandé de redémarrer ! Pour appliquer les icons ouvrez ajustement et appliquez kora."