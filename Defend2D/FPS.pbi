;/
;/Brot
;/FPS ausrechnen
;/

Procedure.l FPS()  
    Shared Zeit, Frames, Ausgabe  
    If GetTickCount_() < Zeit + 1000  
        Frames + 1  
    Else  
        Ausgabe = Frames  
        Frames  = 0  
        Zeit    = GetTickCount_()  
    EndIf  
    If Ausgabe > 0  
        ProcedureReturn Ausgabe  
    Else  
        ProcedureReturn 60  
    EndIf   
EndProcedure  
; jaPBe Version=2.5.2.24
; Build=0
; FirstLine=0
; CursorPosition=19
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF