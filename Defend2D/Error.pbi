;/
;/Brot
;/Error Proceduren
;/

Procedure Init(init.l,msg.s)
    If init = 0
        If msg = "dx7e" :
            msg = "Sie ben�tigen DirectX 7.0 oder h�her, um dieses Spiel zu spielen!"
        EndIf
        MessageRequester(GameTitle + " - Error",msg)
        End 
    EndIf
EndProcedure
Procedure Error(msg.s)
    If IsScreenActive() : CloseScreen() : EndIf 
    MessageRequester(GameTitle + " - Error",msg)
    End 
EndProcedure
; ExecutableFormat=
; EOF