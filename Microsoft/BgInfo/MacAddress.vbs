Const wbemFlagReturnImmediately = &h10
Const wbemFlagForwardOnly = &h20
 
'*** Connect to this PC's WMI Service
Set objWMI = GetObject("winmgmts:\\.\root\CIMV2")
 
'*** Query WMI
Set Win32MacAddr = objWMI.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration Where IPEnabled = True")
 
For Each Item In Win32MacAddr
   MacAddr = Item.MACAddress
Next
 
Echo MacAddr