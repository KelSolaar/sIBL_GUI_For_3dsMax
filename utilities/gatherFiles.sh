#/bin/bash
echo ----------------------------------------------------------------
echo sIBL_GUI For 3dsMax - Files Gathering
echo ----------------------------------------------------------------

export PROJECT=/Users/KelSolaar/Documents/Developement/sIBL_GUI_For_3dsMax

export SOURCE=$PROJECT/src
export RELEASES=$PROJECT/releases
export REPOSITORY=$RELEASES/repository

#! Gathering folder cleanup.
rm -rf $REPOSITORY/*

#! Change Log gathering.
cp $RELEASES/Change_Log.html $REPOSITORY/

#! Helper script gathering.
cd $SOURCE
zip -r $REPOSITORY/sIBL_GUI_For_3dsMax.zip *.ms ../README

#! Reaching original directory.
cd ../
