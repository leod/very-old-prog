;/
;/Brot
;/Blood
;/

Procedure NewBlood(X.l,Y.l)
    AddElement(Blood())
    Blood()\X = X
    Blood()\Y = Y
    Blood()\Type = Random(9)
    Blood()\Time = GetTime()
EndProcedure

Procedure DoBlood()
    ForEach Blood()
        DisplayTransparentSprite(#Sprite_BloodIndex+Blood()\Type,Blood()\X+Map\CamX,Blood()\Y+Map\CamY)
        If Time(Blood()\Time) > 5000
            DeleteElement(Blood())
        EndIf
    Next
EndProcedure 
; jaPBe Version=2.5.2.24
; Build=0
; FirstLine=0
; CursorPosition=16
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF