#!/bin/sh
if [ -d /etc/X11/xinit/xinitrc.d ]; then
	for f in /etc/X11/xinit/xinitrc.d/*; do
		[ -x "$f" ] && . "$f"
	done
	unset f
fi
xrandr --output HDMI1 --left-of LVDS1 --mode '1920x1080' &
synclient HorizTwoFingerScroll=1 &
synclient PalmDetect=1 &
nitrogen --restore &
xrdb ~/.Xresources &
dropboxd &
exec i3
