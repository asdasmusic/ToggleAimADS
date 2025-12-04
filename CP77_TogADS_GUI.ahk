; CP77_TogADS script by p0tat0gunner (Updated for MB4/MB5 + minor fixes)
#SingleInstance, Force
FileInstall, tads_running.wav, %A_WorkingDir%\tads_running.wav, 1
FileInstall, tads_closing.wav, %A_WorkingDir%\tads_closing.wav, 1
FileInstall, tads_disabled.wav, %A_WorkingDir%\tads_disabled.wav, 1
FileInstall, tads_enabled.wav, %A_WorkingDir%\tads_enabled.wav, 1

selhk := false
selmb := false
Toggle := 0  ; Aim toggle state

Menu, Tray, NoStandard
Menu, Tray, Add, Reset, ResetSub
Menu, Tray, Add, Exit, ExitSub
OnExit, ExitSub

; --- GUI Definition (Updated) ---
Gui, Color, 280000, Black
Gui, Font, s13
Gui, Font, cff0000
Gui, Add, Text,, Please enter an Activation Hotkey:
Gui, Font, cffcc00
Gui, Add, Hotkey, vHKA gHKAEvent
Gui, Add, Edit, yp vCtrlHKA
Gui, Font, cff0000
Gui, Add, Text,, Please enter an Exit Hotkey:
Gui, Font, cffcc00
Gui, Add, Hotkey, vHKE gHKEEvent
Gui, Add, Edit, yp vCtrlHKE
Gui, Font, cff0000
Gui, Add, Text,, Please select your in-game Aim Key:
Gui, Font, c00e3ff
Gui, Add, Radio, vMK, Right Mouse Button
Gui, Add, Radio,, Middle Mouse Button
Gui, Add, Radio,, Side Mouse Button Up (MB5)
Gui, Add, Radio,, Side Mouse Button Down (MB4)
Gui, Add, Button, Default gSubmit, Confirm and Run with Selected Keys
Gui, Font, s9
Gui, Font, c00ff5b
Gui, Add, Text, xm+85, © 2021 p0tat0gunner

; Initialize preview fields
HKAEvent()
HKEEvent()

Gui, Show, AutoSize, CP77 Toggle AIM/ADS GUI

; Keep previews refreshed when GUI repaints (optional but harmless)
OnMessage(0x0F, "HKAEvent") ; WM_PAINT

Return

; --- Hotkey preview helpers ---
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

; --- Submit button handler ---
Submit:
Gui, Submit

; Validate activation/exit hotkeys
if (HKA != "" && HKE != "")
{
    if (HKA != HKE)
    {
        selhk := true
    }
    else
    {
        selhk := false
        MsgBox, 16, Error, The Activation and Exit Hotkeys cannot be the same.`nPlease re-assign unique hotkeys!
        Gui, Show
    }
}
else
{
    selhk := false
    MsgBox, 16, Error, The Activation and Exit Hotkeys cannot be None.`nPlease assign both hotkeys!
    Gui, Show
}

; Validate aim key (MK will be 1–4 for the 4 radios)
if (MK >= 1 && MK <= 4)
{
    selmb := true
}
else
{
    selmb := false
    MsgBox, 16, Error, Please select your Aim Key!
    Gui, Show
}

; If both valid, bind hotkeys and start
if (selhk && selmb)
{
    Hotkey, %HKA%, RunHKA
    Hotkey, %HKE%, RunHKE
    SoundPlay, %A_WorkingDir%\tads_running.wav
}
else
{
    MK := 0
    Gui, Show
}
Return

; --- Activation Hotkey: Toggle suspend + sounds ---
RunHKA:
Suspend, Toggle
if (A_IsSuspended)
    SoundPlay, %A_WorkingDir%\tads_disabled.wav
else
    SoundPlay, %A_WorkingDir%\tads_enabled.wav
Return

; --- Exit Hotkey: Clean exit ---
RunHKE:
Suspend, Toggle
SoundPlay, %A_WorkingDir%\tads_closing.wav, Wait
GoSub, DeleteSub
ExitApp
Return

GuiClose:
GoSub, DeleteSub
ExitApp
Return

; --- Toggle Aim/ADS Logic (unchanged behavior) ---

#If (MK = 1) ; Right Mouse Button
*RButton Up::
    if (Toggle := !Toggle) {
        Send {Click Down Right}
    } else {
        Send {RButton Up}
    }
Return
#If

#If (MK = 2) ; Middle Mouse Button
*MButton Up::
    if (Toggle := !Toggle) {
        Send {Click Down Middle}
    } else {
        Send {MButton Up}
    }
Return
#If

#If (MK = 3) ; Side Mouse Button Up (MB5)
*XButton2 Up::
    if (Toggle := !Toggle) {
        Send {Click Down XButton2}
    } else {
        Send {XButton2 Up}
    }
Return
#If

#If (MK = 4) ; Side Mouse Button Down (MB4)
*XButton1 Up::
    if (Toggle := !Toggle) {
        Send {Click Down XButton1}
    } else {
        Send {XButton1 Up}
    }
Return
#If

; --- End Toggle Aim/ADS Logic ---

ExitSub:
if (A_ExitReason not in Logoff, Shutdown)
{
    SoundPlay, null000.wav
    GoSub, DeleteSub
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
