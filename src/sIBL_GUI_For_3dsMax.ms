/************************************************************************************************************************
***	sIBL_GUI_For_3dsMax.ms
***
***	Platform :
***		Windows
***
***	Description :
***		sIBL_GUI For 3dsMax Helper Script.
***
***	Others :
***
************************************************************************************************************************/

utility sIBL_GUI_For_3dsMax "sIBL_GUI For 3ds Max" 
(

	local PREFERENCES_FILE = "sIBL_GUI_Preferences.rc"
	
	local DATAS_COLLECTOR_FILE = "_sIBL_GUI_3dsmaxHelperScriptDatasCollector.txt"

	local HDRLABS_URL = "http://www.hdrlabs.com"
	local WINDOWS_RELEASE_URL = "http://kelsolaar.hdrlabs.com/?dir=./sIBL_GUI/Repository/Builds/Windows"
	local APPLICATION_THREAD_URL = "http://www.hdrlabs.com/cgi-bin/forum/YaBB.pl?num=1271609371"
		
	local sIBL_GUI_For_3dsMax_preferences_Rollout
	local sIBL_GUI_For_3dsMax_interactions_Rollout

	fn createRegistryKey hkey keyName &registryKey keyValueName keyValueType keyValue =
	(
		registry.createKey hkey keyName key:&registryKey
		registry.setValue registryKey keyValueName keyValueType keyValue
	)

	fn writeSubKeyDatas registryKey subKeyName subKeyType subKeyValue =
	(
		local subKey
		registry.createKey registryKey subKeyName key:&subKey
		registry.setValue subKey "" subKeyType subKeyValue
	)

	fn registerOLEServer =
	(
		local registryKey
		local maxVersion_ = ( (maxVersion() )[1] / 1000 ) as string
		
		try
		(	
			createRegistryKey HKEY_CLASSES_ROOT "MAX.Application" &registryKey "" #REG_SZ "OLE Automation MAX Application"

			writeSubKeyDatas registryKey "Clsid" #REG_SZ "{7FA22CB1-D26F-11d0-B260-00A0240CEEA3}"

			writeSubKeyDatas registryKey "CurVer" #REG_SZ ("MAX.Application." + maxVersion_)

			createRegistryKey HKEY_CLASSES_ROOT ("MAX.Application." + maxVersion_) &registryKey "" #REG_SZ ("OLE Automation MAX " + maxVersion_ + ".0 Application")

			writeSubKeyDatas registryKey "Clsid" #REG_SZ "{7FA22CB1-D26F-11d0-B260-00A0240CEEA3}"

			createRegistryKey HKEY_CLASSES_ROOT "CLSID\{7FA22CB1-D26F-11d0-B260-00A0240CEEA3}" &registryKey "" #REG_SZ ("OLE Automation MAX " + maxVersion_ + ".0 Application")

			writeSubKeyDatas registryKey "ProgID" #REG_SZ ("MAX.Application." + maxVersion_)
			writeSubKeyDatas registryKey "VersionIndependentProgID" #REG_SZ "MAX.Application"
		)
		catch
			messageBox ( "sIBL_GUI | Errors while accessing Windows registry, make sure 3dsmax is running as with Administrator privileges in order to register the OLE server!" ) title:"sIBL_GUI Error"
	)

	fn readFile file =
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

	fn setPreferences =
	(
		local preferencesFilePath =  ( getDir #maxData ) + "\\" + PREFERENCES_FILE
			
		if (doesFileExist preferencesFilePath == false ) then
			createFile preferencesFilePath

		local stream = openFile preferencesFilePath mode:"wt"
		format sIBL_GUI_For_3dsMax_preferences_Rollout.Executable_Path_editText.text to:stream
		format "\n" to:stream
		format sIBL_GUI_For_3dsMax_preferences_Rollout.Loader_Script_Path_editText.text to:stream
		flush stream
		close stream
	)
	
	fn getPreferences =
	(
		local preferencesFilePath =  ( getDir #maxData ) + "\\" + PREFERENCES_FILE
		readFile preferencesFilePath
	)
	
	fn sIBL_3dsmax_launchApplication = 
	(
		executablePath =  sIBL_GUI_For_3dsMax_preferences_Rollout.Executable_Path_editText.text
		if( executablePath != "" ) then
		(
			executableDirectory = getFilenamePath executablePath
			HiddenDOSCommand executablePath startpath:executableDirectory donotwait:true
		)
		else
			messageBox "sIBL_GUI | No sIBL_GUI executable path defined!" title:"sIBL_GUI Error"
	)

	fn executeLoaderScript = 
	(
		loaderScriptPath =  sIBL_GUI_For_3dsMax_preferences_Rollout.Loader_Script_Path_editText.text
		if (doesFileExist loaderScriptPath ) then
			fileIn loaderScriptPath
		else
			messageBox ( "sIBL_GUI | No Loader Script file available In \"" + ( getFilenamePath loaderScriptPath ) + "\" Directory!" ) title:"sIBL_GUI Error"
	)

	rollout sIBL_GUI_For_3dsMax_preferences_Rollout "Preferences"
	(
		groupBox Executable_Path_groupBox "sIBL_GUI Path" pos:[8,8] width:144 height:80
		editText Executable_Path_editText "" pos:[12,24] width:132 height:24
		button Executable_Path_button "..." pos:[16,56] width:128 height:24
		groupBox Loader_Script_Path_groupBox "Loader Script Path" pos:[8,88] width:144 height:80
		editText Loader_Script_Path_editText "" pos:[12,104] width:132 height:24
		button Loader_Script_Path_button "..." pos:[16,136] width:128 height:24
		button Register_OLE_Server_button "Register OLE Server" pos:[8,176] width:144 height:24
		
		on Executable_Path_editText entered text do
		(
			setPreferences()
		)

		on Executable_Path_button pressed  do
		(
			executablePath = getOpenFileName caption:"Choose sIBL_GUI Executable"
			if( executablePath != undefined ) then
				Executable_Path_editText.text = executablePath
				setPreferences()
		)
	
		on Loader_Script_Path_editText entered text do
		(
			setPreferences()
		)

		on Loader_Script_Path_button pressed  do
		(
			loaderScriptPath = getOpenFileName caption:"Choose Loader Script Path"
			if( loaderScriptPath != undefined ) then
				Loader_Script_Path_editText.text = loaderScriptPath
				setPreferences()
		)

		on Register_OLE_Server_button pressed  do
		(
			registerOLEServer()
		)
	)
	
	rollout sIBL_GUI_For_3dsMax_interactions_Rollout "Interactions"
	(
		button Launch_sIBL_GUI_button "Launch sIBL_GUI" pos:[8,8] width:144 height:24
		button Execute_Loader_Script_button "Execute Loader Script" pos:[8,40] width:144 height:24
		groupBox Online_groupBox "Online" pos:[8,68] width:144 height:88
		label separator_Label "" pos:[16,84] width:128 height:0
		HyperLink Get_sIBL_GUI_hyperLink "Get sIBL_GUI ..."  address:WINDOWS_RELEASE_URL color:gray hovercolor:white visitedcolor:gray align:#center
		HyperLink Visit_HDRLabs_hyperLink "Visit HDRLabs ..."  address:HDRLABS_URL color:gray hovercolor:white visitedcolor:gray align:#center
		HyperLink Visit_sIBL_GUI_Thread_hyperLink "Visit sIBL_GUI Thread ..."  address:APPLICATION_THREAD_URL color:gray hovercolor:white visitedcolor:gray align:#center

		on Execute_Loader_Script_button pressed  do
			executeLoaderScript()
		
		on Launch_sIBL_GUI_button pressed  do
			sIBL_3dsmax_launchApplication()
	)

	on sIBL_GUI_For_3dsMax open do
	( 
		addRollout sIBL_GUI_For_3dsMax_preferences_Rollout
		addRollout sIBL_GUI_For_3dsMax_interactions_Rollout
		local sIBL_GUI_preferences = (getPreferences())
	
		if( sIBL_GUI_preferences[1] != undefined ) then
		(
			sIBL_GUI_For_3dsMax_preferences_Rollout.Executable_Path_editText.text =  sIBL_GUI_preferences[1]
			sIBL_GUI_For_3dsMax_preferences_Rollout.Loader_Script_Path_editText.text =  sIBL_GUI_preferences[2]
		)
	)

	on sIBL_GUI_For_3dsMax close do
	(
		removeRollout sIBL_GUI_For_3dsMax_preferences_Rollout
		removeRollout sIBL_GUI_For_3dsMax_interactions_Rollout
	)
)