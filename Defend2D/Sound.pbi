;/
;/Brot
;/Sound
;/

Procedure Sound(sound.l,X.l,Y.l)
    tLongX = tRealX - X
    tLongY = tRealY - Y
    If tLongX > 1000 Or tLongX < -1000 Or tLongY > 800 Or tLongY < -800
        SoundVolume(sound,20)
    EndIf
    If Player()\IsBot = 0 
        SoundVolume(sound,100)
    EndIf    
    PlaySound(sound)
EndProcedure 
; jaPBe Version=2.5.2.24
; Build=0
; FirstLine=0
; CursorPosition=14
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF