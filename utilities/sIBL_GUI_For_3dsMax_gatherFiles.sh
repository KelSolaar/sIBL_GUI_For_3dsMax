#/bin/bash
echo ----------------------------------------------------------------
echo sIBL_GUI For 3dsMax - Files Gathering
echo ----------------------------------------------------------------

#! Gathering Folder Cleanup.
rm -rf ./releases/repository/*

#! Change Log Gathering.
cp ./releases/Change\ Log.html ./releases/repository/

#! Helper Script Gathering.
cd ./src
zip -r ../releases/repository/sIBL_GUI_For_3dsMax.zip *.ms

#! Reaching Original Directory.
cd ../
