;/
;/Brot
;/Array Funktionen
;/

Procedure NewArray(size.l)
    *a.LONG = AllocateMemory(SizeOf(LONG)*size)
    *a\l = size 
    ProcedureReturn *a
EndProcedure
Procedure GetArraySize(*a.LONG)
    ProcedureReturn *a\l
EndProcedure
Procedure SetArrayVal(*a.LONG,index.l,val.l)
    *b.LONG = *a + (index * SizeOf(LONG)) + 4
    *b\l = val
EndProcedure
Procedure GetArrayVal(*a.LONG,index.l)
    *b.LONG = *a + (index * SizeOf(LONG)) + 4
    ProcedureReturn *b\l
EndProcedure
Procedure ReDimArray(*a.LONG,size.l)
    ReAllocateMemory(*a,SizeOf(LONG)*size)
EndProcedure 
; jaPBe Version=2.5.2.24
; Build=0
; FirstLine=0
; CursorPosition=23
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF