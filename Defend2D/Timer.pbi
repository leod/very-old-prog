;/
;/Brot
;/Timer Funktionen
;/

Procedure InitTimer()
    Shared _GT_DevCaps.TIMECAPS 
    SetPriorityClass_(GetCurrentProcess_(),#HIGH_PRIORITY_CLASS) 
    timeGetDevCaps_(_GT_DevCaps,SizeOf(TIMECAPS)) 
    timeBeginPeriod_(_GT_DevCaps\wPeriodMin)
    ProcedureReturn 1
EndProcedure

Procedure GetTime()
    ProcedureReturn timeGetTime_();GetTickCount_() - Timer_StartTime
EndProcedure

Procedure Time(var.l)
    ProcedureReturn GetTime() - var
EndProcedure 
; jaPBe Version=2.5.2.24
; Build=0
; FirstLine=0
; CursorPosition=5
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF