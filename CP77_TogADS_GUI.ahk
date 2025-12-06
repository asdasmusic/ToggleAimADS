; CP77_TogADS script by p0tat0gunner (Updated for MB4/MB5 + persistence + Keyboard Aim)

;@Ahk2Exe-SetVersion 1.2.0.0
;@Ahk2Exe-SetName Cyberpunk 2077 Toggle ADS Mod
;@Ahk2Exe-SetDescription Enables Toggle ADS for Cyberpunk 2077
;@Ahk2Exe-SetCompanyName p0tat0gunner
;@Ahk2Exe-SetCopyright COPYRIGHT © 2025 p0tat0gunner
;@Ahk2Exe-AddResource disable.ico, 206

#SingleInstance, Force
FileInstall, tads_running.wav, %A_WorkingDir%\tads_running.wav, 1
FileInstall, tads_closing.wav, %A_WorkingDir%\tads_closing.wav, 1
FileInstall, tads_disabled.wav, %A_WorkingDir%\tads_disabled.wav, 1
FileInstall, tads_enabled.wav, %A_WorkingDir%\tads_enabled.wav, 1

selhk := false
selmb := false
Toggle := 0  ; Aim toggle state
AimKey := "" ; Keyboard aim key (for MK = 5)
PrevAimKey := "" ; last registered keyboard aim hotkey

IniFile := A_WorkingDir . "\CP77_TogADS_keys.ini"

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

; Aim key radios (with hwnd handles)
Gui, Add, Radio, vMK hwndhAim1, Right Mouse Button
Gui, Add, Radio, hwndhAim2, Middle Mouse Button
Gui, Add, Radio, hwndhAim3, Side Mouse Button Up (MB5)
Gui, Add, Radio, hwndhAim4, Side Mouse Button Down (MB4)
Gui, Add, Radio, hwndhAim5, Keyboard (enter Key below)

; Keyboard Aim key input (Hotkey + display text)
Gui, Font, cff0000
Gui, Add, Text,, If using Keyboard, choose an Aim Key:
Gui, Font, cffcc00
Gui, Add, Hotkey, vAimKey gAimKeyEvent
Gui, Add, Edit, yp vCtrlAimKey

; Persistence buttons (just above Confirm and Run)
Gui, Add, Button, xm gSaveKeys, Save Keys
Gui, Add, Button, x+10 gLoadKeys, Load Keys

Gui, Add, Button, xm y+10 Default gSubmit, Confirm and Run with Selected Keys
Gui, Font, s9
Gui, Font, c00ff5b
Gui, Add, Text, xm+85, © 2025 p0tat0gunner

; Initialize preview fields
HKAEvent()
HKEEvent()
AimKeyEvent()

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

AimKeyEvent() {
    GuiControlGet, AimKey

    ; If empty, show None and stop
    if (AimKey = "")
    {
        GuiControl, , CtrlAimKey, None
        return
    }

    ; Disallow combos: no Ctrl(^), Alt(!), Shift(+), Win(#)
    if (InStr(AimKey, "^") || InStr(AimKey, "!") || InStr(AimKey, "+") || InStr(AimKey, "#"))
    {
        AimKey := ""
        GuiControl, , AimKey,      ; clear Hotkey control
        GuiControl, , CtrlAimKey, None
        MsgBox, 16, Error, Keyboard Aim Key must be a single key (no Ctrl/Alt/Shift/Win).`nPlease press just one key.
        return
    }

    ; Valid single key: show as-is (formatted)
    AimKeyText := Format("{:T}", AimKey)
    GuiControl, , CtrlAimKey, % AimKeyText ? AimKeyText : "None"
}

; --- Save Keys button: persist HKA, HKE, MK, AimKey ---
SaveKeys:
Gui, Submit, NoHide

; Basic validation before saving
if (HKA = "" || HKE = "")
{
    MsgBox, 16, Error, The Activation and Exit Hotkeys cannot be None.`nPlease assign both hotkeys before saving!
    Return
}
if (HKA = HKE)
{
    MsgBox, 16, Error, The Activation and Exit Hotkeys cannot be the same.`nPlease re-assign unique hotkeys before saving!
    Return
}
if (MK < 1 || MK > 5)
{
    MsgBox, 16, Error, Please select your Aim Key before saving!
    Return
}
if (MK = 5 && AimKey = "")
{
    MsgBox, 16, Error, Please choose a Keyboard Aim Key before saving!
    Return
}

; Keyboard AimKey must not match Activation or Exit keys when saving
if (MK = 5)
{
    if (AimKey = HKA)
    {
        MsgBox, 16, Error, Keyboard Aim Key cannot be the same as the Activation Hotkey!
        Return
    }
    if (AimKey = HKE)
    {
        MsgBox, 16, Error, Keyboard Aim Key cannot be the same as the Exit Hotkey!
        Return
    }
}

IniWrite, %HKA%,    %IniFile%, Keys, HKA
IniWrite, %HKE%,    %IniFile%, Keys, HKE
IniWrite, %MK%,     %IniFile%, Keys, MK
IniWrite, %AimKey%, %IniFile%, Keys, AimKey

MsgBox, 64, Saved, Keys have been saved successfully.
Return

; --- Load Keys button: load last saved HKA, HKE, MK, AimKey ---
LoadKeys:
; Turn off any currently active hotkeys and reset toggle state.
; This ensures loading config does NOT make anything active until Confirm is pressed.
if (HKA != "")
    Hotkey, %HKA%, Off
if (HKE != "")
    Hotkey, %HKE%, Off
if (PrevAimKey != "")
    Hotkey, *%PrevAimKey% Up, KeyboardAim, Off

Suspend, Off
Toggle := 0
selhk := false
selmb := false

if !FileExist(IniFile)
{
    MsgBox, 16, Error, Please Save Keys first!
    Return
}

IniRead, sHKA,    %IniFile%, Keys, HKA,
IniRead, sHKE,    %IniFile%, Keys, HKE,
IniRead, sMK,     %IniFile%, Keys, MK, 0
IniRead, sAimKey, %IniFile%, Keys, AimKey,

; If missing/invalid, treat as not saved yet
if (sHKA = "" || sHKE = "" || sMK < 1 || sMK > 5)
{
    MsgBox, 16, Error, Please Save Keys first!
    Return
}

; If keyboard selected but aim key missing, also treat as invalid
if (sMK = 5 && sAimKey = "")
{
    MsgBox, 16, Error, Please Save Keys first! (Keyboard Aim key missing)
    Return
}

; Apply loaded values to variables
HKA    := sHKA
HKE    := sHKE
MK     := sMK
AimKey := sAimKey

; Update hotkey GUI controls
GuiControl, , HKA,    %HKA%
GuiControl, , HKE,    %HKE%
GuiControl, , AimKey, %AimKey%

; Clear all aim radios
GuiControl, , %hAim1%, 0
GuiControl, , %hAim2%, 0
GuiControl, , %hAim3%, 0
GuiControl, , %hAim4%, 0
GuiControl, , %hAim5%, 0

; Check the correct one based on MK (1–5)
if (MK = 1)
    GuiControl, , %hAim1%, 1
else if (MK = 2)
    GuiControl, , %hAim2%, 1
else if (MK = 3)
    GuiControl, , %hAim3%, 1
else if (MK = 4)
    GuiControl, , %hAim4%, 1
else if (MK = 5)
    GuiControl, , %hAim5%, 1

; Refresh preview text (this will also re-validate AimKey)
HKAEvent()
HKEEvent()
AimKeyEvent()
Return

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

; Validate aim key (MK will be 1–5 for the 5 radios)
if (MK >= 1 && MK <= 5)
{
    if (MK = 5 && AimKey = "")
    {
        selmb := false
        MsgBox, 16, Error, Please choose a Keyboard Aim Key!
        Gui, Show
    }
    else
        selmb := true
}
else
{
    selmb := false
    MsgBox, 16, Error, Please select your Aim Key!
    Gui, Show
}

; Keyboard AimKey must not match Activation or Exit keys when confirming
if (selmb && MK = 5)
{
    if (AimKey = HKA)
    {
        selmb := false
        MsgBox, 16, Error, Keyboard Aim Key cannot be the same as the Activation Hotkey!
        Gui, Show
    }
    else if (AimKey = HKE)
    {
        selmb := false
        MsgBox, 16, Error, Keyboard Aim Key cannot be the same as the Exit Hotkey!
        Gui, Show
    }
}

; If both valid, bind hotkeys and start
if (selhk && selmb)
{
    Hotkey, %HKA%, RunHKA
    Hotkey, %HKE%, RunHKE

    ; Set up keyboard aim hotkey if MK = 5
    if (MK = 5 && AimKey != "")
    {
        ; Safely switch dynamic keyboard hotkey
        if (PrevAimKey != "")
            Hotkey, *%PrevAimKey% Up, KeyboardAim, Off
        Hotkey, *%AimKey% Up, KeyboardAim, On
        PrevAimKey := AimKey
    }

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

; --- Toggle Aim/ADS Logic ---

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

; For MK = 5 (Keyboard), the hotkey is dynamic via Hotkey command
KeyboardAim:
    ; Extra safety: only act if MK = 5 and AimKey is set
    if (MK != 5 || AimKey = "")
        Return

    if (Toggle := !Toggle) {
        Send {%AimKey% down}
    } else {
        Send {%AimKey% up}
    }
Return

; --- End Toggle Aim/ADS Logic ---

ExitSub:
    ; Always delete temp sound files
    GoSub, DeleteSub
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
