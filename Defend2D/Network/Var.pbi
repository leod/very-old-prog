;/
;/Brot
;/Server - Var
;/

;{Konstanten
#Network_Port = 6832
;}
;{Strukturen
Structure client
    nick.s
    id.l
EndStructure
;}
;{Listen
NewList Client.client()
;}
;{Variablen
ReceiveBuffer_Lenght = 1000
ReceiveBuffer = AllocateMemory(ReceiveBuffer_Lenght)
;} 
; jaPBe Version=2.5.2.6
; Build=0
; FirstLine=0
; CursorPosition=16
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF