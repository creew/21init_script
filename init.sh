#!/bin/bash

GOINFREDIR="$HOME/goinfre"
CACHES_DIR="$HOME/Library/Caches/"
SLACK_CACHES_DIR="$HOME/Library/Application Support/Slack/Service Worker/CacheStorage"

idea="https://download.jetbrains.com/idea/ideaIU-2021.3.dmg@IntelliJ IDEA.app"
#vlc="https://mirror.yandex.ru/mirrors/ftp.videolan.org/vlc/3.0.11.1/macosx/vlc-3.0.11.1.dmg@VLC.app"
#cura="https://storage.googleapis.com/software.ultimaker.com/cura/Ultimaker_Cura-4.8.0-Darwin.dmg@Ultimaker Cura.app"

apps=()
echo "logged in $(date)" >>log.txt
folders=(".m2" ".npm" ".gradle" ".brew" "Applications" "Library/Containers/com.docker.docker" ".sdkman" "Library/Java" "VirtualBox VMs" ".vagrant.d")

if [[ ! -e "$GOINFREDIR/.brew/.git" ]]; then
    curl -fsSL https://rawgit.com/kube/42homebrew/master/install.sh | zsh
    brew tap LouisBrunner/valgrind
	brew install --HEAD LouisBrunner/valgrind/valgrind
	brew install sdl2 sdl2_gfx sdl2_image
	mv $HOME/.brew $GOINFREDIR/.brew 
fi
set -- "$@" "10" "-1"

for i in "${folders[@]}"; do
  [[ ! -e "$GOINFREDIR/$i" ]] && mkdir -p "$GOINFREDIR/$i" && echo "dir $i created"
  [[ -d "$HOME/$i" ]] && [[ ! -L "$HOME/$i" ]] && rm -rf "${HOME:?}/$i" && echo "$HOME/$i is not a symlink, deleting..."
  [[ ! -e "$HOME/$i" ]] && ln -s "$GOINFREDIR/$i" "$HOME/$i" && echo "link $i created"
done
set -- "$@" "20" "-1"

defaults write -g com.apple.swipescrolldirection -bool false
defaults write -g com.apple.keyboard.fnState -bool true
defaults write -g TISRomanSwitchState -bool true
set -- "$@" "25" "-1"

for f in "$CACHES_DIR"*; do
  rm -rf "$f" && echo "$f deleted"
done
rm -rf "$SLACK_CACHES_DIR" && echo "$SLACK_CACHES_DIR deleted"
set -- "$@" "30" "-1"

for app in "${apps[@]}"; do
  link=$(echo "$app" | awk -F@ ' { print $1 } ')
  appname=$(echo "$app" | awk -F@ ' { print $2 } ')
  file_name=$(echo "$link" | rev | cut -d/ -f1 | rev)
  if [[ ! -e "$GOINFREDIR/Applications/$appname" ]]; then
    if [[ ! -e "$GOINFREDIR/$file_name" ]]; then
      status_code=$(curl --write-out %{http_code} "$link" -o "$GOINFREDIR/$file_name" -L)
      if [[ "$status_code" -ne 200 ]]; then
        echo "error download $file_name!!!!"
        rm -rf "${GOINFREDIR:?}/$file_name" && echo "$GOINFREDIR/$file_name deleted"
      fi
    fi
    if [[ -e "$GOINFREDIR/$file_name" ]]; then
      volume_name="$(hdiutil attach "$GOINFREDIR/$file_name" | grep '.*\tApple_HFS *\t.*' | awk -F'\t' '{print $3}')"
      echo "$volume_name"
      volume_app="$volume_name/$appname"
      echo "$volume_app"
      if [[ -e "$volume_app" ]]; then
        cp -r "$volume_app" "$GOINFREDIR/Applications" && echo "$appname copied"
      fi
      hdiutil detach "$volume_name"
      rm -rf "${GOINFREDIR:?}/$file_name" && echo "$GOINFREDIR/$file_name deleted"
    fi
  fi
done

exit 0
