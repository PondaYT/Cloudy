#!/bin/sh
SENSITIVE_DIR="Cloudy/Submodule/CloudySensitives/AdMob"

# Check if the sensitive directory exists
if [ ! -d $SENSITIVE_DIR ] 
then
    echo "No senstitive data existing. " 
    exit 0
fi

# Write the Google ad id to the Info.plist
GAD=`cat $SENSITIVE_DIR/ID-App.txt`
echo "Using GAD: '$GAD' for '$BUILT_PRODUCTS_DIR/$INFOPLIST_PATH'"

CMD="/usr/libexec/PlistBuddy -c \"Set :GADApplicationIdentifier $GAD\" \"$BUILT_PRODUCTS_DIR/$INFOPLIST_PATH\""
echo $CMD
eval $CMD