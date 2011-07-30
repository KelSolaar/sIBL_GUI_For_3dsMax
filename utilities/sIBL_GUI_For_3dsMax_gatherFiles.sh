#/bin/bash
echo ----------------------------------------------------------------
echo sIBL_GUI For 3dsMax - Files Gathering
echo ----------------------------------------------------------------

#! Gathering folder cleanup.
rm -rf ./releases/repository/*

#! Change log gathering.
cp ./releases/Change\ Log.html ./releases/repository/

#! Helper script gathering.
cd ./src
zip -r ../releases/repository/sIBL_GUI_For_3dsMax.zip *.ms ../README

#! Reaching original directory.
cd ../
