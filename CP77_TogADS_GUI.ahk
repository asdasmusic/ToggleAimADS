;CP77_TogADS script by p0tat0gunner (Updated for MB4/MB5)
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

; --- GUI Definition (Updated) ---
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
Gui, add, Radio,, Side Mouse Button Up (MB5) ; New option 3
Gui, add, Radio,, Side Mouse Button Down (MB4) ; New option 4
Gui, add, Button, Default gSubmit, Confirm and Run with Selected Keys
Gui, Font, s9
Gui, Font, c00ff5b
Gui, add, text, xm+85, © 2021 p0tat0gunner ; Updated year
HKAEvent()
HKEEvent()
Gui, show, AutoSize, CP77 Toggle AIM/ADS GUI
OnMessage(0x0F, "HKAEvent") ; WM_PAINT = 0x0F
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

; --- Aim Key Validation (Updated to include 4 options) ---
If MK between 1 and 4
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

; --- Toggle Aim/ADS Logic (Updated to include 4 options) ---
#If MK=1 ; Right Mouse Button
*RButton Up::
If (Toggle := !Toggle){
Send {Click Down Right}
}
Else{
Send {RButton up}
}
Return
#If

#If MK=2 ; Middle Mouse Button
*MButton Up::
If (Toggle := !Toggle){
Send {Click Down Middle}
}
Else{
Send {MButton up}
}
Return
#If

#If MK=3 ; Side Mouse Button Up (MB5)
*XButton2 Up::
If (Toggle := !Toggle){
Send {Click Down XButton2}
}
Else{
Send {XButton2 up}
}
Return
#If

#If MK=4 ; Side Mouse Button Down (MB4)
*XButton1 Up::
If (Toggle := !Toggle){
Send {Click Down XButton1}
}
Else{
Send {XButton1 up}
}
Return
#If
; --- End Toggle Aim/ADS Logic ---

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
