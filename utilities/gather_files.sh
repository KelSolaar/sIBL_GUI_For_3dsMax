#/bin/bash
echo ----------------------------------------------------------------
echo sIBL_GUI For 3dsMax - Files Gathering
echo ----------------------------------------------------------------

export PROJECT_DIRECTORY=$(cd $( dirname "${BASH_SOURCE[0]}" )/..; pwd)

export SOURCE_DIRECTORY=$PROJECT_DIRECTORY/src
export RELEASES_DIRECTORY=$PROJECT_DIRECTORY/releases
export REPOSITORY_DIRECTORY=$RELEASES_DIRECTORY/repository

#! Gathering folder cleanup.
rm -rf $REPOSITORY_DIRECTORY/*

#! Change Log gathering.
cp $RELEASES_DIRECTORY/Change_Log.html $REPOSITORY_DIRECTORY/

#! Helper script gathering.
cd $SOURCE_DIRECTORY
zip -r $REPOSITORY_DIRECTORY/sIBL_GUI_For_3dsMax.zip *.ms ../README

#! Reaching original directory.
cd ../
