;/
;/Brot
;/Einstellungen laden
;/

Procedure ReadPrefs(file.s)
    If OpenPreferences(file)
        
        *ret.Prefs = AllocateMemory(SizeOf(Prefs))
        
        PreferenceGroup("Files")
        *ret\WeaponFile   = ReadPreferenceString("WeaponFile","")
        *ret\BotNamesFile = ReadPreferenceString("BotNamesFile","")
        PreferenceGroup("Images")
        *ret\CrossHair    = ReadPreferenceString("CrossHair","")
        
        ClosePreferences()
        ProcedureReturn *ret
    Else
        Error("Kann "+file+" nicht finden!")
        ProcedureReturn 0
    EndIf
EndProcedure 
; jaPBe Version=2.5.2.24
; Build=0
; FirstLine=0
; CursorPosition=5
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF