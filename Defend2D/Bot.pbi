;/
;/Brot
;/Bots
;/

Procedure TestShot(x1.l,y1.l,x2.l,y2.l)
    If x1 = 0 Or y1 = 0 Or x2 = 0 Or y2 = 0 
        ProcedureReturn 0
    Else
        DX.f = x2-x1
        If DX<0
            SignX = -1
            DX = Abs(DX)
        Else
            SignX = 1
        EndIf
        
        DY.f = y2-y1
        If DY<0
            SignY = -1
            DY = Abs(DY)
        Else
            SignY = 1
        EndIf
        
        Result = 1
        
        If DY < DX
            Stp.f = DY/DX
            For n=0 To Int(DX) 
                X = x1+(n*SignX)
                Y = y1+(n*Stp*SignY)
                If Map(X,Y)\Coll = 1
                    Result = 0
                EndIf
            Next
        Else
            Stp.f = DX/DY
            For n=0 To Int(DY) 
                X = x1+(n*Stp*SignX)
                Y = y1+(n*SignY)
                If Map(X,Y)\Coll = 1
                    Result = 0
                EndIf
            Next
        EndIf
        
        ProcedureReturn Result 
    EndIf 
EndProcedure
Procedure ReadBotNames(file.s)
    If ReadFile(0,file)
        While Eof(0) = 0 
            AddElement(Name())
            Name() = ReadString()
        Wend
        CloseFile(0)
        ProcedureReturn 1
    Else
        Error("Kann "+file+" nicht finden!")
        ProcedureReturn 0
    EndIf
EndProcedure
Procedure SetBotZXY(X.l,Y.l)
    Player()\ZX = (X / #TileWidth ) * #TileWidth
    Player()\ZY = (Y / #TileHeight) * #TileHeight
EndProcedure
Procedure NewRandomZ()
    SetBotZXY(Player()\X+MinMax(350),Player()\Y+MinMax(350))
EndProcedure
Procedure NewBot(Team.l)
    AddElement(Player())
    Player()\Speed = 1.5
    Player()\Energy = 100
    Player()\IsBot = 1
    Player()\ShootTime = GetTime()
    Player()\WalkTimer = GetTime()
    Player()\Kills = 1
    Player()\Team = Team
    Player()\HasEnemy = 0
    Player()\ZX = -1
    Player()\ZY = -1
    Repeat
        SelectElement(Name(),Random(CountList(Name())))
        tString.s = Name()
        ForEach UsedName()
            If UsedName() = tString
                Ok = 0
            Else 
                Ok = 1
                AddElement(UsedName())
                UsedName() = tString 
            EndIf
        Next 
        If CountList(UsedName()) = 0 
            Ok = 1
        EndIf
    Until Ok = 1
    Player()\Name = tString.s
EndProcedure 
Procedure DoBot()
    ForEach Player()
        If Player()\IsBot = 1
            
            ;{/Bewegen
            If Player()\ZX <> -1 And Player()\ZY <> -1
                TX = Player()\X / #TileWidth
                TY = Player()\Y / #TileHeight
                If Player()\X < Player()\ZX And Map(TX+1,TY)\Coll = 0
                    Player()\X + Player()\Speed
                EndIf
                If Player()\X > Player()\ZX And Map(TX-1,TY)\Coll = 0
                    Player()\X - Player()\Speed
                EndIf
                If Player()\Y < Player()\ZY And Map(TX,TY+1)\Coll = 0
                    Player()\Y + Player()\Speed
                EndIf
                If Player()\Y > Player()\ZY And Map(TX,TY-1)\Coll = 0
                    Player()\Y - Player()\Speed
                EndIf
            EndIf 
            Player()\RealX = Player()\X
            Player()\RealY = Player()\Y
            ;}
            ;{/Winkel anpassen
            If Player()\HasEnemy 
                Player()\Angle = winkel(Player()\Enemy\RealX,Player()\Enemy\RealY,Player()\X,Player()\Y)
            Else
                If Player()\ZX <> -1 And Player()\ZY <> -1
                    Player()\Angle = winkel(Player()\X,Player()\Y,Player()\ZX,Player()\ZY) + 180
                EndIf
            EndIf 
            ;}
            ;{/Kein Gegner = Nächsten Waypoint suchen             
            If Player()\HasEnemy = 0 
                If Distanz(Player()\X,Player()\Y,Player()\ZX,Player()\ZY) < 10 Or (Player()\ZX = -1 And Player()\ZY = -1)
                    *littleWP.WayPoint = 0
                    ForEach WayPoint()
                        dis = Distanz(WayPoint()\X,WayPoint()\Y,Player()\X,Player()\Y) 
                        goOn = 1
                        For I = 0 To Player()\WPWC
                            If @WayPoint() = Player()\WPW[I]
                                goOn = 0
                            EndIf
                        Next
                        If goOn
                            If *littleWP
                                If dis < Distanz(*littleWP\X,*littleWP\Y,Player()\X,Player()\Y) 
                                    *littleWP = @WayPoint()
                                EndIf
                            Else
                                *littleWP = @WayPoint()
                            EndIf
                            If Distanz(Player()\X,Player()\Y,WayPoint()\X,WayPoint()\Y) < 5
                                Player()\WPW[Player()\WPWC] = @WayPoint()
                                Player()\WPWC + 1
                            EndIf
                        EndIf
                    Next
                    If *littleWP
                        SetBotZXY(*littleWP\X,*littleWP\Y)
                    EndIf 
                EndIf 
            EndIf
            ;}
            ;{/Neues Lauf/Enemy Ziel setzen
            ;{Nächsten Gegner suchen 
            *temp.Player = @Player()
            *little.Player = 0
            ForEach Player()
                If Distanz(*temp\RealX,*temp\RealY,Player()\RealX,Player()\RealY) < 400 And Player()\Team <> *temp\Team And Player()\Name <> *temp\Name And Player()\Energy > 0 And Player()\IsSpawning = 0
                    If *little 
                        If Distanz(*little\RealX,*little\RealY,Player()\RealX,Player()\RealY) < Distanz(*temp\RealX,*temp\RealY,Player()\RealX,Player()\RealY)  And TestShot(*temp\RealX,*temp\RealY,Player()\RealX,Player()\RealY) = 1
                            *little = @Player()
                        EndIf
                    ElseIf *little = 0 And TestShot(*temp\RealX,*temp\RealY,Player()\RealX,Player()\RealY) = 1
                        *little = @Player()
                    EndIf 
                EndIf
            Next
            ;}
            ;{Ziel zum neuen Gegner setzen                
            If *little 
                If *temp\HasEnemy = 0 And *little\Team <> *temp\Team And *little\Name <> *temp\Name 
                    *temp\Enemy = *little
                    *temp\HasEnemy = 1
                    *temp\ZX = *little\RealX 
                    *temp\ZY = *little\RealY 
                EndIf 
            Else
                *temp\HasEnemy = 0
            EndIf
            ChangeCurrentElement(Player(),*temp)
            ;}
            ;{Nicht existierende Gegner löschen
            If Player()\HasEnemy
                If Player()\Enemy\Energy <= 0 Or Player()\Enemy\IsSpawning = 1 Or Distanz(Player()\RealX,Player()\RealY,Player()\Enemy\RealX,Player()\Enemy\RealY) > 600
                    Player()\HasEnemy = 0
                EndIf
            EndIf
            ;}
            ;}            
            If Time(Player()\WalkTimer) > 250  
                ;{-Enemy Ziel setzen
                If Random(5) = 2
                    If Player()\HasEnemy = 1
                        If Distanz(Player()\X,Player()\Y,Player()\Enemy\X,Player()\Enemy\Y) > 400
                            SetBotZXY(Player()\Enemy\RealX+MinMax(Random(150)),Player()\Enemy\RealY+MinMax(Random(150)))
                        EndIf 
                    EndIf 
                EndIf 
                ;}
                Player()\WalkTimer = GetTime()
            EndIf
            
        EndIf 
    Next
    FirstElement(Player())
EndProcedure
Procedure DisplayBot()
    ForEach Player()
        If Player()\IsBot = 1
            RotateSprite3D(#Sprite_Bot+Player()\Team,Player()\Angle-90,0)
            DisplaySprite3D(#Sprite_Bot+Player()\Team,Player()\X+Map\CamX,Player()\Y+Map\CamY)
        EndIf 
    Next
    FirstElement(Player())
EndProcedure 
; jaPBe Version=2.5.2.24
; FoldLines=00050031003F004200430045004600630068007B007C0084008500A400A500C9
; FoldLines=00A6000000B5000000C2000000CB00D300DB00E3
; Build=0
; FirstLine=0
; CursorPosition=59
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF