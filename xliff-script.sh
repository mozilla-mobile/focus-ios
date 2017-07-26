#!/bin/bash
# Note that fil is tl in the l10n repo
#LANGUAGES="el,es-ES,es-MX,kn,ms,ne-NP,ro,ta,te,ur,af,ar,az,bn,br,ca,cs,cy,de,dsb,en-US,eo,es,es-CL,eu,fa,tl,fr,ga-IE,gd,he,hi-IN,hsb,hu,id,is,it,ja,kab,kk,ko,lo,my,nb-NO,nl,nn-NO,pl,pt-BR,pt-PT,ru,ses,sk,sl,sq,sv-SE,th,tr,uk,uz,zh-CN,zh-TW" 
#IFS=","
LANGUAGES="en-US"
IFS=","
for LANG in $LANGUAGES; do
echo $LANG
xcodebuild -exportLocalizations -localizationPath ~/focusios-l10n/$LANG -project Blockzilla.xcodeproj -exportLanguage $LANG 
mv ~/focusios-l10n/$LANG/$LANG.xliff ~/focusios-l10n/$LANG/focus-ios.xliff
done
