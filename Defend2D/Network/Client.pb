;/
;/Brot
;/Network test - Client
;/

;{-Proceduren
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
;}
;{-Init
If InitNetwork() = 0
    MessageRequester("Error", "Can't initialize the network !", 0)
    End
EndIf
;}
;{-Variablen etc.
#Network_Port = 6832
Client_Nick.s = "jaadasd"
Client_Connection = Client_Connect("192.168.1.7", #Network_Port,Client_Nick)
ReceiveBuffer_Lenght = 1000
ReceiveBuffer = AllocateMemory(ReceiveBuffer_Lenght)
;}
;{-Chat Fenster
hWnd=OpenWindow(0,0,0,640,480,#PB_Window_ScreenCentered|#PB_Window_SystemMenu,"Chat")
CreateGadgetList(hWnd)
ListViewGadget(0,10,10,620,430)
StringGadget(1,10,450,530,20,"")
ButtonGadget(2,550,450,80,20,"Senden")
;}

Repeat
    ;{-Fenster events
    Select WindowEvent()
        Case #PB_Event_CloseWindow 
            Quit = #True 
        Case #PB_Event_Gadget
            Select EventGadgetID()
                Case 2
                    SendNetworkString(Client_Connection,"/c "+GetGadgetText(1))
                    SetGadgetText(1,"")
            EndSelect
    EndSelect
    ;}
    ;{-Network events
    Select NetworkClientEvent(Client_Connection)
        Case 2
            FreeMemory(ReceiveBuffer)
            ReceiveBuffer = AllocateMemory(ReceiveBuffer_Lenght)
            ReceiveNetworkData(Client_Connection,ReceiveBuffer,ReceiveBuffer_Lenght)
            tString.s = PeekS(ReceiveBuffer)
            tCommand.s = Trim(StringField(tString,1," "))
            tExpr.s = Trim(StringField(tString,2," "))
            Select tCommand
                Case "/gn"
                    Client_SendNick(Client_Connection,Client_Nick)
                Case "/c"
                    AddGadgetItem(0,-1,tExpr)
            EndSelect
    EndSelect
    ;}
    Delay(15)
Until Quit = #True  
; jaPBe Version=2.5.2.6
; Build=0
; FirstLine=1
; CursorPosition=26
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF