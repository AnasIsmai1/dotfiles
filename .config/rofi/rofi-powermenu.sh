#! /bin/sh

chosen=$(printf "⏻ Power Off\n󰜉 Restart\n  Sleep\n󰈆  Exit" | rofi -dmenu -i -p "Power Menu:")

echo "Chosen option: $chosen"

case "$chosen" in
"⏻ Power Off")
  shutdown -h now
  ;;
"󰜉 Restart")
  reboot
  ;;
"  Sleep")
  i3lock - c 000000 && systemctl suspend
  ;;
"󰈆  Exit")
  rofi -show window
  ;;
*)
  echo "Invalid option selected: $chosen"
  exit 1
  ;;
esac
