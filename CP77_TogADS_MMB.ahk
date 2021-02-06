;CP77_TogADS script by p0tat0gunner
#SingleInstance, Force
FileInstall, tads_running.wav, %A_WorkingDir%\tads_running.wav, 1
FileInstall, tads_closing.wav, %A_WorkingDir%\tads_closing.wav, 1
FileInstall, tads_disabled.wav, %A_WorkingDir%\tads_disabled.wav, 1
FileInstall, tads_enabled.wav, %A_WorkingDir%\tads_enabled.wav, 1
SoundPlay, %A_WorkingDir%\tads_running.wav
Menu, Tray, NoStandard
Menu, Tray, Add, Exit, ExitSub
OnExit, ExitSub
Return
*MButton Up::
If (Toggle := !Toggle){
Send {Click Down Middle}
}
Else{
Send {MButton up}
}
Return
F1::
Suspend, Toggle
If Suspend:=!Suspend
SoundPlay, %A_WorkingDir%\tads_disabled.wav
Else	
SoundPlay, %A_WorkingDir%\tads_enabled.wav
Return
ExitSub:
If A_ExitReason not in Logoff,Shutdown
{
SoundPlay, null000.wav
GoSub DeleteSub
}
ExitApp
Return
F4::
Suspend, Toggle
SoundPlay, %A_WorkingDir%\tads_closing.wav, Wait
GoSub DeleteSub
ExitApp
Return
DeleteSub:
FileDelete, %A_WorkingDir%\tads_disabled.wav
FileDelete, %A_WorkingDir%\tads_enabled.wav
FileDelete, %A_WorkingDir%\tads_running.wav
FileDelete, %A_WorkingDir%\tads_closing.wav
Return