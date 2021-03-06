;/
;/Brot
;/Schuss Proceduren
;/

Procedure NewShoot(X.l,Y.l,SX.f,SY.f,Power.l,Owner.l,Angle.l,Weapon.s,Name.s,OwnerPtr.l)
    AddElement(Shoot())
    Shoot()\X = X
    Shoot()\Y = Y
    Shoot()\SpeedX = SX 
    Shoot()\SpeedY = SY 
    Shoot()\Power = Power
    Shoot()\Owner = Owner
    Shoot()\Angle = Angle 
    Shoot()\Weapon = Weapon
    Shoot()\Name = Name 
    Shoot()\Owner = Owner
    Shoot()\OwnerPtr = OwnerPtr
EndProcedure
Procedure DoShoot()
    ForEach Shoot()
        ;{Anzeigen & Bewegen
        DisplaySprite(#Sprite_Shoot,Shoot()\X,Shoot()\Y)
        Shoot()\X + Shoot()\SpeedX 
        Shoot()\Y + Shoot()\SpeedY
        ;}
        ForEach Player()
            If Player()\IsBot = 1 
                ;{Schuss - Bot Kollision
                If SpriteCollision(#Sprite_Shoot,Shoot()\X,Shoot()\Y,#Sprite_Bot,Player()\X+Map\CamX,Player()\Y+Map\CamY)
                    tString.s = Shoot()\Name
                    tOwner.l = Shoot()\Owner
                    tString2.s = Player()\Name
                    tWP.s = Shoot()\Weapon
                    If Player()\Name <> Shoot()\Name And Player()\Team <> Shoot()\OwnerPtr\Team
                        Player()\Enemy = Shoot()\OwnerPtr
                        Player()\Energy - Shoot()\Power 
                        DeleteElement(Shoot())
                        If Random(5) = 5
                            NewRandomZ()
                        EndIf 
                        Broken = 1
                        Test = 1
                        X = Player()\X 
                        Y = Player()\Y
                    EndIf 
                EndIf
                ;}
            Else
                ;{Schuss - Spieler Kollision
                If Player()\IsSpawning = 0
                    If SpriteCollision(#Sprite_Shoot,Shoot()\X,Shoot()\Y,#Sprite_PlayerIndex,Player()\X,Player()\Y)
                        tString.s = Shoot()\Name
                        tOwner.l = Shoot()\Owner
                        tString2.s = Player()\Name
                        tWP.s = Shoot()\Weapon
                        Player()\Energy - Shoot()\Power / 3
                        DeleteElement(Shoot())
                        Broken = 1
                        Test = 1
                        X = Player()\RealX
                        Y = Player()\RealY 
                    EndIf
                EndIf 
                ;}
            EndIf 
            ;{Sterben
            If Test
                Do = 1
                If Player()\Energy <= 0 And tString <> tString2
                    If ListIndex(Player()) = 0
                        ClearList(Shoot())
                        If Player()\IsSpawning = 1
                            Do = 0
                        EndIf 
                    EndIf
                    If Do = 1
                        ReSpawnPlayer()
                        thisName.s = Player()\Name
                        If Random(2) = 2
                            AddFragMsg(tString + "'s "+tWP+" killed "+tString2) 
                        Else
                            AddFragMsg(tString  + " killed "+tString2) 
                        EndIf 
                        SelectElement(Player(),tOwner)
                        Player()\Kills + 1
                    EndIf 
                EndIf
                Break 
            EndIf
            ;}
        Next
        ;{Blut erzeugen
        If Broken = 1
            For I = 0 To 5
                NewBlood(X-MinMax(Random(22))+MinMax(Random(Random(Random(20)))),Y-MinMax(Random(22))+MinMax(Random(Random(Random(20)))))
            Next 
        EndIf
        ;}
        ;{Auf Bomben schie�en        
        If Broken = 0
            ForEach Bomb()
                If SpriteCollision(#Sprite_Bomb,Bomb()\X+Map\CamX,Bomb()\Y+Map\CamY,#Sprite_Shoot,Shoot()\X,Shoot()\Y)
                    PlaySound(#Sound_BulletIndex+Random(6))
                    NewSmoke(Shoot()\X-Map\CamX-16-MinMax(Random(6)),Shoot()\Y-Map\CamY-16-MinMax(Random(6)))
                    DeleteElement(Shoot())
                    Bomb()\ShootCounter + 1
                    If Bomb()\ShootCounter > 6
                        Bomb()\Explode = 1
                    EndIf
                    Break 
                EndIf
            Next
        EndIf 
        Broken = 0
        ;}
    Next
EndProcedure 
; jaPBe Version=2.5.2.24
; FoldLines=0005001200150019001C002F003100400042005A00630073
; Build=0
; FirstLine=0
; CursorPosition=96
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF