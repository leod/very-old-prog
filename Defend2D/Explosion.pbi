;/
;/Brot
;/Explosionen
;/

Procedure NewExplosion(X,Y,Type,OwnerPtr.l)
    AddElement(Explosion())
    Explosion()\Type = Type
    Explosion()\X = X
    Explosion()\Y = Y
    Explosion()\Time = GetTime()
    Explosion()\OwnerPtr = OwnerPtr
    Select Explosion()\Type 
        Case #Sprite_heExplosionIndex
            Explosion()\FrameLim = 23
    EndSelect
    PlaySound(#Sound_Explode)
EndProcedure
Procedure DoExplosion()
    ForEach Explosion()
        ForEach Player()
            If Player()\IsBot = 1
                If SpriteCollision(Explosion()\Type,Explosion()\X,Explosion()\Y,#Sprite_Bot,Player()\X,Player()\Y)
                    Player()\Energy - 100
                    If Player()\Energy <= 0
                        ReSpawnPlayer()
                        For I = 0 To 20
                            NewBlood(Player()\X-MinMax(Random(22))+MinMax(Random(Random(Random(20)))),Player()\Y-MinMax(Random(22))+MinMax(Random(Random(Random(20)))))
                        Next 
                        Explosion()\OwnerPtr\Kills + 1
                        AddFragMsg(Explosion()\OwnerPtr\Name+ "'s explosion killed "+Player()\Name)
                    EndIf
                EndIf
            Else
                If SpriteCollision(Explosion()\Type,Explosion()\X+Map\CamX,Explosion()\Y+Map\CamY,#Sprite_PlayerIndex,Player()\X,Player()\Y) And Player()\IsSpawning = 0
                    Player()\Energy - 100
                    If Player()\Energy <= 0
                        ReSpawnPlayer()
                        For I = 0 To 20
                            NewBlood(Player()\X-MinMax(Random(22))+MinMax(Random(Random(Random(20)))),Player()\Y-MinMax(Random(22))+MinMax(Random(Random(Random(20)))))
                        Next 
                        Explosion()\OwnerPtr\Kills + 1
                        AddFragMsg(Explosion()\OwnerPtr\Name + "'s explosion killed "+Player()\Name)
                    EndIf
                EndIf
            EndIf
        Next
        ForEach Bomb()
            If SpriteCollision(Explosion()\Type,Explosion()\X,Explosion()\Y,#Sprite_Bomb,Bomb()\X,Bomb()\Y)
                Bomb()\Explode = 1
            EndIf
        Next
        DisplayTransparentSprite(Explosion()\Type+Explosion()\Frame,Explosion()\X+Map\CamX,Explosion()\Y+Map\CamY)
        If Time(Explosion()\Time) > 10
            Explosion()\Frame + 1
            Explosion()\Time = GetTime()
            If Explosion()\Frame > Explosion()\FrameLim 
                DeleteElement(Explosion())
            EndIf
        EndIf
    Next
EndProcedure 
; jaPBe Version=2.5.2.24
; FoldLines=000500110012003D
; Build=0
; FirstLine=0
; CursorPosition=18
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF