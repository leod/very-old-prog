;/
;/Brot
;/Radar
;/

Procedure DisplayRadar()
    DisplayTransparentSprite(#Sprite_Radar,0,0)
    ForEach Player()
        If Player()\IsBot = 1
            x = (Player()\RealX - *Real\RealX) / 10 + 100
            y = (Player()\RealY - *Real\RealY) / 10 + 100
            t = Sqr((x*x)+(y*y))
            Debug t
            If t < 200
                DisplayTransparentSprite(#Sprite_RadarFriend,x,y)
            EndIf 
        EndIf
    Next
EndProcedure 
; jaPBe Version=2.5.2.24
; Build=0
; FirstLine=0
; CursorPosition=5
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF