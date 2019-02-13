;/
;/Brot
;/Frag Messages
;/

Procedure DisplayFragMsg()
    ForEach FragMsg()
        Locate(0,15*ListIndex(FragMsg()))
        Color = $FFFFFF
        If FindString(FragMsg(),Player()\Name,0)
            Color = $FF0000 
        EndIf
        FontMapOutput(Font_FragMsg,FragMsg(),200,FontMapHigh(Font_FragMsg,FragMsg())*ListIndex(FragMsg()),#FHL,#FVT,Color)
    Next
EndProcedure
Procedure AddFragMsg(msg.s)
    AddElement(FragMsg())
    FragMsg() = msg
    If CountList(FragMsg()) > 4
        FirstElement(FragMsg())
        DeleteElement(FragMsg(),1)
    EndIf
EndProcedure 
; jaPBe Version=2.5.2.24
; Build=0
; FirstLine=0
; CursorPosition=12
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF