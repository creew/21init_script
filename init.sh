#!/bin/bash
HOMEDIR=$HOME
GOINFREDIR="$HOMEDIR/goinfre"
IDEA="ideaIU-2020.2.3.dmg"
VOLUMES_IDEA="/Volumes/IntelliJ IDEA/IntelliJ IDEA.app"
CACHES_DIR="$HOMEDIR/Library/Caches/"
JAVA_15="15.0.1.j9-adpt"

echo  "logged in $(date)" >> log.txt
folders=(".m2" ".npm" ".gradle" "Applications" ".sdkman")
for i in "${folders[@]}"
do
	[[ ! -e "$GOINFREDIR/$i" ]] && mkdir "$GOINFREDIR/$i" && echo "dir $i created"
	[[ -d "$HOMEDIR/$i" ]] && [[ ! -L "$HOMEDIR/$i" ]] && rm -rf "${HOMEDIR:?}/$i" && echo "$HOMEDIR/$i is not a symlink, deleting..."
	[[ ! -e "$HOMEDIR/$i" ]] && ln -s "$GOINFREDIR/$i" ~ && echo "link $i created"
done
defaults write -g com.apple.swipescrolldirection -bool false
defaults write -g com.apple.keyboard.fnState -bool true
defaults write -g TISRomanSwitchState -bool true
for f in "$CACHES_DIR"*; do
  rm -rf "$f" && echo "$f deleted"
done
if [[ ! -e "$GOINFREDIR/$IDEA" ]] ;then
  status_code=$(curl --write-out %{http_code} "https://download.jetbrains.com/idea/$IDEA" -o "$GOINFREDIR/$IDEA" -L)
  if [[ "$status_code" -ne 200 ]] ; then
    echo "error download idea!!!!"
    rm -rf "${GOINFREDIR:?}/$IDEA" && echo "$GOINFREDIR/$IDEA deleted";
  fi
fi

if [[ ! -e "$GOINFREDIR/Applications/IntelliJ IDEA.app" ]] ;then
  if [[ ! -e "$GOINFREDIR/$IDEA" ]] ;then
   status_code=$(curl --write-out %{http_code} "https://download.jetbrains.com/idea/$IDEA" -o "$GOINFREDIR/$IDEA" -L)
    if [[ "$status_code" -ne 200 ]] ; then
     echo "error download idea!!!!"
     rm -rf "${GOINFREDIR:?}/$IDEA" && echo "$GOINFREDIR/$IDEA deleted";
    fi
  fi
  if [[ -e "$GOINFREDIR/$IDEA" ]] ;then
    hdiutil attach "$GOINFREDIR/$IDEA"
    if [[ -e "$VOLUMES_IDEA" ]] ;then
     cp -r "$VOLUMES_IDEA" "$GOINFREDIR/Applications" && echo "IntelliJ IDEA.app copied";
    fi
    hdiutil detach "$GOINFREDIR/$IDEA"
  fi
fi

if [[ ! -e "$HOMEDIR/.sdkman/bin" ]] ;then
  curl -s "https://get.sdkman.io" | sed 's#if \[ -d \"$SDKMAN_DIR\" \]; then#if \[ -d \"$SDKMAN_DIR/bin\" \]; then#g' | bash
fi

source "${HOMEDIR}/.sdkman/bin/sdkman-init.sh"

if sdk version; then
  sdk install java $JAVA_15
fi

exit 0
