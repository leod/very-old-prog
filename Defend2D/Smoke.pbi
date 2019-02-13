;/
;/Brot
;/Rauch - Wird erzeugt bei Schuss-Map Kollision
;/

Procedure NewSmoke(X,Y)
    AddElement(Smoke())
    Smoke()\X = X
    Smoke()\Y = Y
    Smoke()\Frame = 0
    Smoke()\Time = GetTime()
EndProcedure
Procedure DoSmoke()
    ForEach Smoke()
        DisplayTransparentSprite(#Sprite_SmokePuffIndex+Smoke()\Frame,Smoke()\X+Map\CamX,Smoke()\Y+Map\CamY)
        If Time(Smoke()\Time) > 15
            Smoke()\Time = GetTime()
            Smoke()\Frame + 1
            If Smoke()\Frame > 8
                DeleteElement(Smoke())
            EndIf
        EndIf
    Next
EndProcedure 
; jaPBe Version=2.5.2.6
; Build=0
; FirstLine=0
; CursorPosition=16
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF