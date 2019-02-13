;/
;/Brot
;/Netzwerk Funktionen
;/

Procedure Client_SendNick(connID.l,nick.s)
    SendNetworkString(connID,"/nick "+nick.s)
EndProcedure
Procedure Client_Connect(ip.s,Port.l,nick.s)
    connID = OpenNetworkConnection(ip,Port)
    If connID
        Client_SendNick(connID,nick.s)
    EndIf
    ProcedureReturn connID
EndProcedure
Procedure Client_Send(connID,str.s)
    SendNetworkString(connID,str)
EndProcedure
Procedure Client_GetPlayerList(connID)
    Client_Send(connID,"/nl")
EndProcedure
Procedure Client_ReceivePlayerList(connID,str.s)
    ClearList(NPlayer())
    For I = 1 To CountString(str,"|")
        If StringField(str,I,"|") <> Client_Nick
            AddElement(NPlayer())
            NPlayer()\nick = StringField(str,I,"|")
        EndIf
    Next
    ; Debug "PlayerList: "+str
EndProcedure 
; jaPBe Version=2.5.2.6
; Build=0
; FirstLine=0
; CursorPosition=30
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF