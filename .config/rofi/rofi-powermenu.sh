#! /bin/sh

chosen=$(printf "⏻ Power Off\n󰜉 Restart\n  Sleep\n" | rofi -dmenu -i -p "Power Menu:")

echo "Chosen option: $chosen"

case "$chosen" in
	"⏻ Power Off")
		shutdown -h now ;;
	"󰜉 Restart")
		reboot ;;
	"  Sleep")
		i3lock && systemctl suspend ;;
	*)
		echo "Invalid option selected: $chosen";	exit 1 ;;
esac 
