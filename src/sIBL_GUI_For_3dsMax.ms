/************************************************************************************************
***
*** Copyright (C) 2008 - 2010 - Thomas Mansencal - thomas.mansencal@gmail.com
***
***********************************************************************************************/

/************************************************************************************************
***	sIBL_GUI_For_3dsMax.ms
***
***	Platform:
***		Windows
***
***	Description:
***		sIBL_GUI For 3dsMax Helper Script.
***
***	Others:
***
***********************************************************************************************/

/**********************************************************************************************
***	MaxScript Begin
**********************************************************************************************/

utility sIBL_GUI_For_3dsMax "sIBL_GUI For 3ds Max" 
(

	local PREFERENCES_FILE = "sIBL_GUI_Preferences.rc"
	
	local DATAS_COLLECTOR_FILE = "_sIBL_GUI_3dsmaxHelperScriptDatasCollector.txt"

	local LOADER_SCRIPTS_DIRECTORY = "HDRLabs\\sIBL_GUI\\io\\loaderScripts\\"
	local LOADER_SCRIPT = "sIBL_3dsmax_Import.ms"
	local HDRLABS_URL = "http://www.hdrlabs.com"
	local WINDOWS_RELEASE_URL = "http://kelsolaar.hdrlabs.com/?dir=./sIBL_GUI/Repository/Builds/Windows"
	local APPLICATION_THREAD_URL = "http://www.hdrlabs.com/cgi-bin/forum/YaBB.pl?num=1271609371"
		
	local sIBL_GUI_For_3dsMax_preferences_Rollout
	local sIBL_GUI_For_3dsMax_interactions_Rollout

	fn sIBL_3dsmax_createRegistryKey hkey keyName &registryKey keyValueName keyValueType keyValue =
	(
		registry.createKey hkey keyName key:&registryKey
		registry.setValue registryKey keyValueName keyValueType keyValue
	)

	fn sIBL_3dsmax_writeSubKeyDatas registryKey subKeyName subKeyType subKeyValue =
	(
		local subKey
		registry.createKey registryKey subKeyName key:&subKey
		registry.setValue subKey "" subKeyType subKeyValue
	)

	fn sIBL_3dsmax_registerOLEServer =
	(
		local registryKey
		local maxVersion_ = ( (maxVersion() )[1] / 1000 ) as string
		
		try
		(	
			sIBL_3dsmax_createRegistryKey HKEY_CLASSES_ROOT "MAX.Application" &registryKey "" #REG_SZ "OLE Automation MAX Application"

			sIBL_3dsmax_writeSubKeyDatas registryKey "Clsid" #REG_SZ "{7FA22CB1-D26F-11d0-B260-00A0240CEEA3}"

			sIBL_3dsmax_writeSubKeyDatas registryKey "CurVer" #REG_SZ ("MAX.Application." + maxVersion_)

			sIBL_3dsmax_createRegistryKey HKEY_CLASSES_ROOT ("MAX.Application." + maxVersion_) &registryKey "" #REG_SZ ("OLE Automation MAX " + maxVersion_ + ".0 Application")

			sIBL_3dsmax_writeSubKeyDatas registryKey "Clsid" #REG_SZ "{7FA22CB1-D26F-11d0-B260-00A0240CEEA3}"

			sIBL_3dsmax_createRegistryKey HKEY_CLASSES_ROOT "CLSID\{7FA22CB1-D26F-11d0-B260-00A0240CEEA3}" &registryKey "" #REG_SZ ("OLE Automation MAX " + maxVersion_ + ".0 Application")

			sIBL_3dsmax_writeSubKeyDatas registryKey "ProgID" #REG_SZ ("MAX.Application." + maxVersion_)
			sIBL_3dsmax_writeSubKeyDatas registryKey "VersionIndependentProgID" #REG_SZ "MAX.Application"
		)
		catch
			messageBox ( "sIBL_GUI | Errors While Accessing Windows Registry, Make Sure 3dsmax Is Running As Administrator In Order To Register The OLE Server!" ) title:"sIBL_GUI Error"
	)

	fn sIBL_3dsmax_readFile file =
	(
		local fileContent = #()
		
		if (doesFileExist file ) then
		(
			local stream = openFile file mode:"rt"
			while not eof stream do
				append fileContent ( readLine stream )
			close stream
		)
	
		return fileContent
	)

	fn sIBL_3dsmax_getApplicationDataDirectory =
	(
		HiddenDOSCommand ( "echo %APPDATA% > " + DATAS_COLLECTOR_FILE )
		fileContent = sIBL_3dsmax_readFile DATAS_COLLECTOR_FILE
		deleteFile DATAS_COLLECTOR_FILE
		
		return fileContent
	)

	fn sIBL_3dsmax_setPreferences executablePath =
	(
		local preferencesFilePath =  ( getDir #maxData ) + "\\" + PREFERENCES_FILE
			
		if (doesFileExist preferencesFilePath == false ) then
			createFile preferencesFilePath

		local stream = openFile preferencesFilePath mode:"wt"
		format sIBL_GUI_For_3dsMax_preferences_Rollout.sIBL_GUI_Path_editText.text to:stream
		flush stream
		close stream
	)
	
	fn sIBL_3dsmax_getPreferences =
	(
		local preferencesFilePath =  ( getDir #maxData ) + "\\" + PREFERENCES_FILE
		sIBL_3dsmax_readFile preferencesFilePath
	)
	
	fn sIBL_3dsmax_executeLoaderScript = 
	(
		local applicationDatasDirectory = sIBL_3dsmax_getApplicationDataDirectory()
		local loaderScriptPath = ( trimRight applicationDatasDirectory[1] ) + "\\" + LOADER_SCRIPTS_DIRECTORY + LOADER_SCRIPT

		if (doesFileExist loaderScriptPath ) then
			fileIn loaderScriptPath
		else
			messageBox ( "sIBL_GUI | No Loader Script File Available In \"" + ( getFilenamePath loaderScriptPath ) + "\" Directory!" ) title:"sIBL_GUI Error"
	)

	fn sIBL_3dsmax_launchApplication = 
	(
		executablePath =  sIBL_GUI_For_3dsMax_preferences_Rollout.sIBL_GUI_Path_editText.text
		if( executablePath != "" ) then
		(
			executableDirectory = getFilenamePath executablePath
			HiddenDOSCommand executablePath startpath:executableDirectory donotwait:true
		)
		else
			messageBox "sIBL_GUI | No sIBL_GUI Executable Path Defined!" title:"sIBL_GUI Error"
	)

	rollout sIBL_GUI_For_3dsMax_preferences_Rollout "Preferences"
	(
		groupBox Preferences_groupBox "sIBL_GUI Path" pos:[8,8] width:144 height:80
		editText sIBL_GUI_Path_editText "" pos:[12,24] width:132 height:24
		button Browse_Button "..." pos:[16,56] width:128 height:24
		button Register_OLE_Server_Button "Register OLE Server" pos:[8,96] width:144 height:24
		
		on sIBL_GUI_Path_editText entered text do
		(
			sIBL_3dsmax_setPreferences sIBL_GUI_Path_editText.text
		)

		on Browse_Button pressed  do
		(
			executablePath = getOpenFileName caption:"Choose sIBL_GUI Executable"
			if( executablePath != undefined ) then
				sIBL_GUI_Path_editText.text = executablePath
				sIBL_3dsmax_setPreferences sIBL_GUI_Path_editText.text
		)
		
		on Register_OLE_Server_Button pressed  do
		(
			sIBL_3dsmax_registerOLEServer()
		)
	)
	
	rollout sIBL_GUI_For_3dsMax_interactions_Rollout "Interactions"
	(
		button Launch_sIBL_GUI_Button "Launch sIBL_GUI" pos:[8,8] width:144 height:24
		button Execute_Loader_Script_Button "Execute Loader Script" pos:[8,40] width:144 height:24
		groupBox Online_groupBox "Online" pos:[8,68] width:144 height:88
		label separator_Label "" pos:[16,84] width:128 height:0
		HyperLink Get_sIBL_GUI_HyperLink "Get sIBL_GUI"  address:WINDOWS_RELEASE_URL color:gray hovercolor:white visitedcolor:gray align:#center
		HyperLink Visit_HDRLabs_HyperLink "Visit HDRLabs"  address:HDRLABS_URL color:gray hovercolor:white visitedcolor:gray align:#center
		HyperLink Visit_sIBL_GUI_Thread_HyperLink "Visit sIBL_GUI Thread"  address:APPLICATION_THREAD_URL color:gray hovercolor:white visitedcolor:gray align:#center

		on Execute_Loader_Script_Button pressed  do
			sIBL_3dsmax_executeLoaderScript()
		
		on Launch_sIBL_GUI_Button pressed  do
			sIBL_3dsmax_launchApplication()
	)

	on sIBL_GUI_For_3dsMax open do
	( 
		addRollout sIBL_GUI_For_3dsMax_preferences_Rollout
		addRollout sIBL_GUI_For_3dsMax_interactions_Rollout
		local sIBL_GUI_preferences = (sIBL_3dsmax_getPreferences())
	
		if( sIBL_GUI_preferences[1] != undefined ) then
			sIBL_GUI_For_3dsMax_preferences_Rollout.sIBL_GUI_Path_editText.text =  sIBL_GUI_preferences[1]
	)

	on sIBL_GUI_For_3dsMax close do
	(
		removeRollout sIBL_GUI_For_3dsMax_preferences_Rollout
		removeRollout sIBL_GUI_For_3dsMax_interactions_Rollout
	)
)

/**********************************************************************************************
***	MaxScript End
**********************************************************************************************/