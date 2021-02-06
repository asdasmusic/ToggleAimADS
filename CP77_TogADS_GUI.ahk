;CP77_TogADS script by p0tat0gunner
#SingleInstance, Force
FileInstall, tads_running.wav, %A_WorkingDir%\tads_running.wav, 1
FileInstall, tads_closing.wav, %A_WorkingDir%\tads_closing.wav, 1
FileInstall, tads_disabled.wav, %A_WorkingDir%\tads_disabled.wav, 1
FileInstall, tads_enabled.wav, %A_WorkingDir%\tads_enabled.wav, 1
selhk:= false
selmb:= false
Menu, Tray, NoStandard
Menu, Tray, Add, Reset, ResetSub
Menu, Tray, Add, Exit, ExitSub
OnExit, ExitSub
Gui, Color, 280000, Black
Gui, Font, s13
Gui, Font, cff0000
Gui, add, text,, Please enter an Activation Hotkey:
Gui, Font, cffcc00
Gui, add, Hotkey, vHKA gHKAEvent
Gui, Add, Edit, yp vCtrlHKA
Gui, Font, cff0000
Gui, add, text,, Please enter an Exit Hotkey:
Gui, Font, cffcc00
Gui, add, Hotkey, vHKE gHKEEvent
Gui, Add, Edit, yp vCtrlHKE
Gui, Font, cff0000
Gui, add, text,, Please select your in-game Aim Key:
Gui, Font, c00e3ff
Gui, add, Radio, vMK, Right Mouse Button
Gui, add, Radio,, Middle Mouse Button
Gui, add, Button, Default gSubmit, Confirm and Run with Selected Keys
Gui, Font, s9
Gui, Font, c00ff5b
Gui, add, text, xm+85, © 2020 p0tat0gunner
HKAEvent()
HKEEvent()
Gui, show, AutoSize, CP77 Toggle AIM/ADS GUI
OnMessage(0x0F, "HKAEvent")  ; WM_PAINT = 0x0F
Return
HKAEvent() {
GuiControlGet, HKA
HKA := Format("{:T}", HKA)
HKA := StrReplace(HKA, "+", "Shift + ")
HKA := StrReplace(HKA, "^", "Ctrl + ")
HKA := StrReplace(HKA, "!", "Alt + ")
GuiControl, , CtrlHKA, % HKA ? HKA : "None"
HKEEvent()
}
HKEEvent() {
GuiControlGet, HKE
HKE := Format("{:T}", HKE)
HKE := StrReplace(HKE, "+", "Shift + ")
HKE := StrReplace(HKE, "^", "Ctrl + ")
HKE := StrReplace(HKE, "!", "Alt + ")
GuiControl, , CtrlHKE, % HKE ? HKE : "None"
}
Submit:
Gui, Submit
If(HKA<>"" and HKE<>"")
{
IfNotEqual, HKA, %HKE%
{
selhk:=true
}
else
{
selhk:= false
Msgbox, 16, Error, The Activation and Exit Hotkeys cannot be Same, Please Re-assign Unique Hotkeys!
Gui, show
}
}
else
{
selhk:= false
Msgbox, 16, Error, The Activation and Exit Hotkeys cannot be None, Please Assign Both Hotkeys!
Gui, show
}
If MK between 1 and 2
{
selmb:= true
}
else
{
selmb:= false
Msgbox, 16, Error, Please Select your Aim Key!
Gui, show
}
If (selhk==true and selmb==true)
{
Hotkey, % HKA, RunHKA
Hotkey, % HKE, RunHKE
SoundPlay, %A_WorkingDir%\tads_running.wav
}
else
{
MK=0
Gui, show
}
Return
RunHKA:
Suspend, Toggle
If Suspend:=!Suspend
SoundPlay, %A_WorkingDir%\tads_disabled.wav
Else	
SoundPlay, %A_WorkingDir%\tads_enabled.wav
Return
RunHKE:
Suspend, Toggle
SoundPlay, %A_WorkingDir%\tads_closing.wav, Wait
GoSub DeleteSub
ExitApp
Return
GuiClose:
GoSub DeleteSub
ExitApp
Return
#If MK=1
*RButton Up::
If (Toggle := !Toggle){
Send {Click Down Right}
}
Else{
Send {RButton up}
}
Return
#If
#If MK=2
*MButton Up::
If (Toggle := !Toggle){
Send {Click Down Middle}
}
Else{
Send {MButton up}
}
Return
#If
ExitSub:
If A_ExitReason not in Logoff,Shutdown
{
SoundPlay, null000.wav
GoSub DeleteSub
}
ExitApp
Return
ResetSub:
Reload
Return
DeleteSub:
FileDelete, %A_WorkingDir%\tads_disabled.wav
FileDelete, %A_WorkingDir%\tads_enabled.wav
FileDelete, %A_WorkingDir%\tads_running.wav
FileDelete, %A_WorkingDir%\tads_closing.wav
Return