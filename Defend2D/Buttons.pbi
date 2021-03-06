;/
;/Brot
;/Button Engine
;/

Procedure NewButton(Sprite,X,Y)
    AddElement(Button())
    Button()\Sprite = Sprite 
    Button()\X = X
    Button()\Y = Y
    ProcedureReturn @Button()
EndProcedure

Procedure DeleteButton(id)
    ChangeCurrentElement(Button(),id)
    DeleteElement(Button(),1)
EndProcedure

Procedure IsButtonClicked(id.l)
    ChangeCurrentElement(Button(),id)
    ret.l = Button()\IsClicked
    Button()\IsClicked = 0
    ProcedureReturn ret
EndProcedure

Procedure DoButtons()
    ForEach Button()
        DisplayTransparentSprite(Button()\Sprite,Button()\X,Button()\Y)
        If MouseX() => Button()\X And MouseX() <= Button()\X + SpriteWidth(Button()\Sprite)
            If MouseY() => Button()\Y And MouseY() <= Button()\Y + SpriteHeight(Button()\Sprite)
                If MouseButton(1)
                    Button()\IsClicked = 1 
                EndIf
                StartDrawing(ScreenOutput())
                DrawingMode(4)
                Box(Button()\X-1,Button()\Y-1,SpriteWidth(Button()\Sprite)+2,SpriteHeight(Button()\Sprite)+2,RGB(0,0,255))
                StopDrawing()
            EndIf
        EndIf
    Next
EndProcedure 
; jaPBe Version=2.5.2.24
; Build=0
; FirstLine=0
; CursorPosition=36
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF