;/
;/Brot
;/WeaponInfo Proceduren
;/

Procedure.s ReadCom()
    temp$ = ReadString()
    temp$ = Trim(temp$)
    While Left(temp$,1) = ";"
        temp$ = Trim(ReadString())
    Wend
    returnString$ = RemoveString(temp$,Chr(9))
    tempPos.l = FindString(returnString$,";",0)
    If tempPos.l = 0 
        tempPos.l = Len(returnString$) + 1
    EndIf
    returnString$ = Mid(returnString$,0,tempPos-1)
    ProcedureReturn returnString$
EndProcedure
Procedure LoadWeaponInfoFile(file.s)
    If ReadFile(0,file)
        Repeat
            tempString.s = Trim(ReadCom())
            If tempString.s = ""
                Finite = 1
            Else
                AddElement(WeaponInfo())
                WeaponInfo()\Name = tempString.s
                WeaponInfo()\Power = Val(ReadCom())
                WeaponInfo()\ShootSpeed = Val(ReadCom())
                WeaponInfo()\ShootDelay = Val(ReadCom())
                WeaponInfo()\MagazinSize = Val(ReadCom())
                WeaponInfo()\ReloadTime  = Val(ReadCom())
                WeaponInfo()\MiniSprite = LoadSprite(#PB_Any,GFXPath+"mwp\"+Trim(ReadCom()))
                If WeaponInfo()\MiniSprite = 0
                    Error("Kann WeaponInfo Datei Bild nicht finden!")
                EndIf
                TransparentSpriteColor(WeaponInfo()\MiniSprite,255,255,255)
                WeaponInfo()\SoundID = LoadSound(#PB_Any,SoundPath+Trim(ReadCom()))
                WeaponInfo()\PlayerFrame = Val(ReadCom())
                WeaponInfo()\Streu = Val(ReadCom())
            EndIf
        Until Eof(0) <> 0 Or Finite.l
        CloseFile(0)
        ProcedureReturn 1
    Else
        Error("Kann "+file+" nicht finden!")
        ProcedureReturn 0
    EndIf
EndProcedure 
; jaPBe Version=2.5.2.24
; FoldLines=0005001200130031
; Build=0
; FirstLine=0
; CursorPosition=19
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF