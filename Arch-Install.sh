timedatectl set-ntp true
mkfs.fat -F32 /dev/sda1
mkfs.btrfs /dev/sda2
mount /dev/sda2 /mnt
cd /mnt
btrfs subvolume create @
btrfs subvolume create @home
btrfs subvolume create @var
cd
umount /mnt
mount -o noatime,subvol=@ /dev/sda2 /mnt
mkdir /mnt/{boot,home,var}
mount -o noatime,subvol=@home /dev/sda2 /mnt/home
mount -o noatime,subvol=@var /dev/sda2 /mnt/var
mkdir /mnt/boot/EFI
mount /dev/sda1 /mnt/boot/EFI
reflector -c GB -a 6 --sort rate --save /etc/pacman.d/mirrorlist
pacstrap -i /mnt base linux-lts linux-firmware intel-ucode intel-media-sdk grub efibootmgr vim sudo networkmanager
genfstab -U -p /mnt >> /mnt/etc/fstab
arch-chroot /mnt
timedatectl set-ntp true
timedatectl set-timezone Europe/London
ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc
vim /etc/locale.gen
locale-gen
echo "LANG_en_GB.UTF-8" >> /etc/locale.conf
echo "KEYMAP=uk" /etc/vconsole.conf
echo "cigar" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 cigar.localdomain cigar" >> /etc/hosts
visudo
systemctl enable NetworkManager
loadkeys uk
echo root:password | chpasswd
useradd -mG wheel cigar
echo cigar:password | chpasswd
grub-install /boot/EFI
grub-mkconfig -o /boot/grub/grub.cfg
exit
umount -R /mnt
reboot
