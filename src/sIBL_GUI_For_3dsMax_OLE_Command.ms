/************************************************************************************************************************
***	sIBL_GUI_For_3dsMax_OLE_Command.ms
***
***	Platform :
***		Windows
***
***	Description :
***		sIBL_GUI For 3dsMax OLE Command Registration.
***
***	Others :
***
************************************************************************************************************************/

global ExecuteSIBLLoaderScript
		
fn ExecuteSIBLLoaderScript object_ = 
(
	try
	(
		execute object_
		return true
	)
	catch
		return false
)

registerOLEInterface #( ExecuteSIBLLoaderScript )
