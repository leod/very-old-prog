;/
;/Brot
;/Intro
;/

Procedure Game_Intro()
    ; ; tTime.l = GetTime()
    ; ; Repeat
        ; ; ExamineMouse()
        ; ; ExamineKeyboard()
        ; ; 
        ; ; ClearScreen(0,0,0)
        ; ; DisplaySprite(#Sprite_Selobrain,#ScrWidth/2-SpriteWidth(#Sprite_Selobrain)/2,#ScrHeight/2-SpriteHeight(#Sprite_Selobrain)/2)
        ; ; 
        ; ; FlipBuffers()
    ; ; Until Time(tTime) > 2000 Or KeyboardPushed(#PB_Key_All) Or MouseButton(1)
    ; PlayMovie(#Movie_Selobrain,ScreenID())
    ; tTime = GetTime()
    ; Repeat
        ; ExamineKeyboard()
        ; ExamineMouse()
        ; 
        ; ; ClearScreen(0,0,0)
        ; ; 
        ; ; Delay(400)
        ; ; 
        ; ; FlipBuffers()
    ; Until KeyboardPushed(#PB_Key_All) Or MouseButton(1) Or Time(tTime) > 5000
    ; StopMovie()
EndProcedure 
; jaPBe Version=2.5.2.24
; Build=0
; FirstLine=0
; CursorPosition=12
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF