;/
;/Brot
;/Procedure zum schnellen anzeigen
;/

Procedure FastText(str.s,X,Y)
    ClearScreen(0,0,0)
    StartDrawing(ScreenOutput())
    DrawingMode(1)
    FrontColor(255,255,255)
    Locate(X,Y)
    DrawText(str)
    StopDrawing()
    FlipBuffers()
EndProcedure 
; jaPBe Version=2.5.2.24
; Build=0
; FirstLine=0
; CursorPosition=14
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF