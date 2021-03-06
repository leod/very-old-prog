;/
;/Brot
;/Maths-Proceduren
;/

Procedure.l gATan(a.w, b.w)  
    Angle.l = ATan(a/b)*57.2957795  
    If b < 0  
        Angle + 180  
    EndIf  
    If Angle < 0 : Angle + 360 : EndIf  
    If Angle > 359 : Angle - 360 : EndIf  
    ProcedureReturn Angle  
EndProcedure  
Procedure.f gSin(winkel.l)  
    ProcedureReturn Sin(winkel*0.01745329)  
EndProcedure  
Procedure.f gCos(winkel.l)  
    ProcedureReturn Cos(winkel*0.01745329)  
EndProcedure  
Procedure Abstand(zahl1,zahl2)
    ProcedureReturn Int(Pow((Pow(zahl2 - zahl1,2)),0.5))
EndProcedure
Procedure MinMax(zahl)
    ProcedureReturn zahl * Random(1)
EndProcedure
Procedure.f GetMouseAngle() 
    ExamineMouse() 
    x1 = 400 
    y1 = 300 
    x2 = MouseX() 
    y2 = MouseY() 
    a.f = x2-x1 
    b.f = y2-y1 
    c.f = Sqr(a*a+b*b) 
    winkel.f = ACos(a/c)*57.29577 
    If y1 < y2 : winkel=360-winkel : EndIf 
    ProcedureReturn winkel+90 
EndProcedure 
Procedure.f winkel(x1.f, y1.f, x2.f, y2.f) 
    w = ATan((y2 - y1) / (x2 - x1)) * 57.295776 
    If x2 < x1 
        w = 180 + w 
    EndIf 
    If w < 0 : w + 360 : EndIf 
    If w > 360 : w - 360 : EndIf 
    ProcedureReturn w 
EndProcedure
Procedure.l Distanz(x1.l,y1.l,x2.l,y2.l )
    If x1 < x2  
        diff_X = x2 - x1
    Else        
        diff_X = x1 - x2  
    EndIf
    If y1 < y2  
        diff_Y = y2 - y1
    Else         
        diff_Y = y1 - y2  
    EndIf
    ProcedureReturn Sqr((diff_X*diff_X)+(diff_Y*diff_Y))
EndProcedure 
; jaPBe Version=2.5.2.24
; FoldLines=0005000D000E0010001100130014001600170019001A00260027002F0030003C
; Build=0
; FirstLine=0
; CursorPosition=5
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF