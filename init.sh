#!/bin/bash
HOMEDIR=$HOME
GOINFREDIR="$HOMEDIR/goinfre"
CACHES_DIR="$HOMEDIR/Library/Caches/"
echo  "logged in $(date)" >> log.txt
folders=(".m2" ".npm" ".gradle")
for i in "${folders[@]}"
do
	[[ ! -e "$GOINFREDIR/$i" ]] && mkdir "$GOINFREDIR/$i" && echo "dir $i created"
	[[ ! -e "$HOMEDIR/$i" ]] && ln -s "$GOINFREDIR/$i" ~ && echo "link $i created"
done
defaults write -g com.apple.swipescrolldirection -bool false
defaults write -g com.apple.keyboard.fnState -bool true
defaults write -g TISRomanSwitchState -bool true
for f in "$CACHES_DIR"*; { rm -rf $f && echo "$f deleted"; }
exit 0
