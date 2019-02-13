;/
;/Brot
;/Game
;/

Procedure ColorFromTeam(Team.l)
    If Team = 0
        ProcedureReturn RGB(255,0,0)
    Else
        ProcedureReturn RGB(0,0,255)
    EndIf
EndProcedure
Procedure.s GetTeamName(Team.l)
    If Team = 0
        ProcedureReturn "Rebellen"
    Else
        ProcedureReturn "VCS"
    EndIf
EndProcedure
Procedure UpdateScore()
    *el = @Player()
    Dim Score.Score(CountList(Player()))
    ResetList(Player())
    For I = 0 To CountList(Player()) - 1
        NextElement(Player())
        Score(I)\Name = Player()\Name
        Score(I)\Score = Player()\Kills 
        Score(I)\Color = ColorFromTeam(Player()\Team)
    Next
    SortStructuredArray(@Score(),1,OffsetOf(Score\Score),#PB_Sort_Long)    
    ChangeCurrentElement(Player(),*el)
EndProcedure
Procedure GetSpawnPoint4Team()
    Ok = 0
    Repeat
        SelectElement(SpawnPoint(),Random(CountList(SpawnPoint())))
        If SpawnPoint()\Team = Player()\Team 
            Ok = 1
        EndIf
    Until Ok = 1    
EndProcedure
Procedure ReSpawnPlayer()
    GetSpawnPoint4Team()
    Player()\Energy = 100
    Player()\HasEnemy = 0
    Player()\ZX = -1
    Player()\ZY = -1
    If Player()\IsBot = 0
        Player()\IsSpawning = 1
    Else
        Player()\X = SpawnPoint()\X
        Player()\Y = SpawnPoint()\Y 
    EndIf 
    
    For I = 0 To 99
        Player()\WPW[I] = 0
    Next
    
    UpdateScore()
EndProcedure
Procedure RealReSpawnPlayer()
    GetSpawnPoint4Team()
    Map\CamX = -SpawnPoint()\X + *Real\X
    Map\CamY = -SpawnPoint()\Y + *Real\Y 
    *Real\IsSpawning = 0
    *Real\Energy = 100
    UpdateScore()
EndProcedure
Procedure NewGame(bots.l,Limit.l)
    ;{Grund Spieler
    ClearList(Player())
    AddElement(Player())
    Player()\X = #ScrWidth / 2 - #TileWidth / 2
    Player()\Y = #ScrHeight / 2 - #TileHeight / 2
    Player()\Key_Up = #PB_Key_W
    Player()\Key_Down = #PB_Key_S
    Player()\Key_Left = #PB_Key_A
    Player()\Key_Right = #PB_Key_D 
    Player()\Key_Angle_Up = #PB_Key_Left
    Player()\Key_Angle_Down = #PB_Key_Right
    Player()\Key_Shoot = #PB_Key_Space 
    Player()\Key_NextWeapon = #PB_Key_X
    Player()\Key_PrevWeapon = #PB_Key_Z 
    Player()\RotSpeed = 5
    Player()\SlowSpeed = 1
    Player()\FastSpeed = 3
    Player()\Speed = Player()\FastSpeed
    Player()\Angle = 270
    Player()\WalkMode = #WalkMode_WalkWASD 
    Player()\Energy = 100
    Player()\Name = "Player"
    Player()\Kills = 1
    Player()\ShootTime = GetTime()
    Player()\Team = 0
    *Real = @Player()
    ;}
    ;{Karten laden    
    IsEditor = 0
    Map\Time = GetTime()
    Map\TimeLimit = Limit.l
    Map\CamX = 0
    Map\CamY = 0
    Screen_LoadMap()
    ;}
    ;{Bots erzeugen
    a = bots
    b = bots
    If a = *Real\Team
        b - 1
    ElseIf b = *Real\Team
        a - 1
    EndIf
    For I = 0 To b
        NewBot(0)
        ReSpawnPlayer()
    Next
    For I = 0 To a
        NewBot(1)
        ReSpawnPlayer()
    Next
    FirstElement(Player())
    ReSpawnPlayer()
    ;}
    ;{Alte Listen leeren
    ClearList(FragMsg())
    ClearList(Shoot())
    ClearList(Explosion())
    ClearList(Bomb())
    ClearList(Grenade())
    ClearList(Smoke())
    ;}
    ;{Waffen initialisieren    
    Dim Weapon.Weapon(CountList(Player()),CountList(WeaponInfo()))
    For X = 0 To CountList(Player())
        ForEach WeaponInfo()
            Weapon(X,ListIndex(WeaponInfo()))\Magazins = 5
            Weapon(X,ListIndex(WeaponInfo()))\MagazinMunition = WeaponInfo()\MagazinSize
            Weapon(X,ListIndex(WeaponInfo()))\WeaponInfoID = ListIndex(WeaponInfo())
        Next
    Next 
    FirstElement(WeaponInfo())
    ;}
EndProcedure
Procedure Game_Game()
    ;{Var-Init
    If GameMode = #GameMode_Multiplayer
        Init(InitNetwork(),"Kann keine Verbindung finden!")
        Client_Connection = Client_Connect("192.168.1.7",#Network_Port,Client_Nick)
        ReceiveBuffer_Lenght = 1000
    EndIf 
    If GameMode = #GameMode_Training
        NewGame(0,0)
    ElseIf GameMode = #GameMode_TeamDeathmatch
        NewGame(Screen_BotCount()-1,200000)
    EndIf 
    ;}
    Repeat
        ExamineKeyboard()
        ExamineMouse()
        ClearScreen(0,0,0) 
        
        ;{/Steuerung
        FirstElement(Player())
        tSpawning = Player()\IsSpawning 
        ;{-Screenshot,Beenden,Einstellungen
        If KeyboardPushed(1) 
            Quit = #True 
        EndIf
        If KeyboardReleased(#PB_Key_F12)
            MakeScreenshot()
        EndIf 
        If KeyboardReleased(#PB_Key_V)
            Map\ShowMore ! 1
        EndIf
        ;}
        ;{-Waffen
        ;{Schiessen
        ForEach Player()
            ;{Variablen Init
            id = ListIndex(Player())
            w = Player()\Weapon
            SelectElement(WeaponInfo(),w)
            tLongX = Player()\RealX + Map\CamX
            tLongY = Player()\RealY + Map\CamY
            ;}
            If Time(Player()\ShootTime) => WeaponInfo()\ShootDelay And Weapon(id,w)\MustReload = 0
                If KeyboardPushed(Player()\Key_Shoot) Or MouseButton(1) Or Player()\BotShoot = 1
                    Player()\ShootTime = GetTime()
                    If Weapon(id,w)\MagazinMunition > 0 
                        If WeaponInfo()\Name = "Bomb"
                            NewBomb(Player()\X-Map\CamX,Player()\Y-Map\CamY,@Player())
                            Weapon(id,w)\MagazinMunition - 1 
                        ElseIf WeaponInfo()\Name = "Grenade"
                            Weapon(id,w)\MagazinMunition - 1  
                        Else ;Normale Schusswaffe
                            ;{Schuss Positionen festlegen
                            If Player()\IsBot = 1
                                tSX = gCos(Player()\Angle+180+MinMax(Random(7))+MinMax(Random(WeaponInfo()\Streu)))*WeaponInfo()\ShootSpeed
                                tSY = gSin(Player()\Angle+180+MinMax(Random(7))+MinMax(Random(WeaponInfo()\Streu)))*WeaponInfo()\ShootSpeed
                                TX = Map\CamX+gCos(Player()\Angle)+SpriteWidth(#Sprite_Bot)/2+Player()\X;*SpriteWidth(#Sprite_Bot)+Player()\X+SpriteWidth(#Sprite_Bot)
                                TY = Map\CamY+gSin(Player()\Angle)+SpriteHeight(#Sprite_Bot)/2+Player()\Y;*SpriteHeight(#Sprite_Bot)+Player()\Y+SpriteHeight(#Sprite_Bot)
                            Else
                                tSX = gCos(Player()\Angle+MinMax(Random(WeaponInfo()\Streu+(Player()\IsWalking*Random(20)))))*WeaponInfo()\ShootSpeed
                                tSY = gSin(Player()\Angle+MinMax(Random(WeaponInfo()\Streu+(Player()\IsWalking*Random(20)))))*WeaponInfo()\ShootSpeed
                                TX = gCos(Player()\Angle)*SpriteWidth(#Sprite_PlayerIndex)+Player()\X+SpriteWidth(#Sprite_PlayerIndex)/2
                                TY = gSin(Player()\Angle)*SpriteHeight(#Sprite_PlayerIndex)+Player()\Y+SpriteHeight(#Sprite_PlayerIndex)/2
                            EndIf
                            ;}
                            ;{Neuen Schuss erzeugen?!
                            shoot = 1
                            If Player()\IsBot = 1
                                If Player()\HasEnemy = 0
                                    shoot = 0
                                Else 
                                    If Player()\Enemy\Energy <= 0
                                        shoot = 0
                                    EndIf
                                    If TestShot(Player()\RealX/#TileWidth,Player()\RealY/#TileHeight,Player()\Enemy\RealX/#TileWidth,Player()\Enemy\RealY/#TileHeight) = 0
                                        shoot = 0
                                    EndIf
                                EndIf
                            Else
                                If Player()\IsSpawning = 1
                                    shoot = 0
                                EndIf
                            EndIf
                            ;}
                            ;{Schuss erstellen                            
                            If shoot = 1
                                NewShoot(TX,TY,tSX.l,tSY.l,WeaponInfo()\Power,ListIndex(Player()),Player()\Angle,WeaponInfo()\Name,Player()\Name,@Player())
                                Sound(WeaponInfo()\SoundID,tLongX,tLongY)
                                SoundFrequency(WeaponInfo()\SoundID,20000+MinMax(Random(2000)))
                                Sound(#Sound_ShellIndex,tLongX,tLongY)
                                PlaySound(#Sound_ShellIndex+Random(2))
                                Weapon(id,w)\MagazinMunition - 1 
                            EndIf 
                            ;}
                            ;{Nachladen?
                            If Weapon(id,w)\MagazinMunition <= 0
                                Weapon(id,w)\MustReload = 1
                                Weapon(id,w)\ReloadTime = GetTime()
                                StopSound(WeaponInfo()\SoundID)
                                PlaySound(#Sound_MagOut)
                            EndIf
                            ;}
                        EndIf 
                    Else
                        ;{Keine Munition
                        If Player()\IsBot = 0
                            PlaySound(#Sound_NoAmmo)
                        Else
                            Player()\Weapon + 1
                        EndIf 
                        ;}
                    EndIf 
                    ;{Handgranaten Weite
                    If Player()\IsBot = 0
                        If Player()\SpaceTime = 0
                            Player()\SpaceTime = GetTime()
                        EndIf
                    EndIf 
                    ;}
                Else 

                EndIf 
            EndIf 
            If KeyboardPushed(Player()\Key_Shoot) = 0 And MouseButton(1) = 0 
                ;{Granaten werfen
                If Player()\SpaceTime And Player()\IsSpawning = 0
                    tTime = Time(Player()\SpaceTime)
                    If tTime > 1000
                        tTime = 1000
                    EndIf
                    If WeaponInfo()\Name = "Grenade"
                        NewGrenade(gCos(Player()\Angle)*SpriteWidth(#Sprite_PlayerIndex)+(Player()\X-Map\CamX)+SpriteWidth(#Sprite_PlayerIndex)/2 ,gSin(Player()\Angle)*SpriteHeight(#Sprite_PlayerIndex)+(Player()\Y-Map\CamY)+SpriteHeight(#Sprite_PlayerIndex)/2,Player()\Angle,tTime,@Player())
                    EndIf
                    Player()\SpaceTime = 0
                EndIf 
                ;}
            EndIf
            ;{Nachladen
            If Weapon(id,w)\MustReload = 1 
                If Time(Weapon(id,w)\ReloadTime) => WeaponInfo()\ReloadTime
                    Player()\ShootTime = GetTime()
                    If Weapon(id,w)\Magazins > 0
                        Weapon(id,w)\MagazinMunition = WeaponInfo()\MagazinSize
                        Weapon(id,w)\Magazins - 1
                        If tLongX > 800 Or tLongX < -800 Or tLongY > 600 Or tLongY < -600
                            SoundVolume(WeaponInfo()\SoundID,50)
                        EndIf
                        If Player()\IsBot = 0 
                            SoundVolume(WeaponInfo()\SoundID,100)
                        EndIf
                        PlaySound(#Sound_Reload)
                    EndIf
                    Weapon(id,w)\ReloadTime = 0
                    Weapon(id,w)\MustReload = 0
                EndIf 
            EndIf
            ;}
            ;{Wirkliche Positionen der Bots
            If Player()\IsBot = 1
                Player()\RealX = Player()\X
                Player()\RealY = Player()\Y
            EndIf
            ;}
            ;{Bots schießen?
            If Player()\IsBot = 1
                Player()\BotShoot = 1
            EndIf 
            ;}
        Next 
        ;{Auf Grund Player setzen
        FirstElement(Player())
        SelectElement(WeaponInfo(),Player()\Weapon)
        id = ListIndex(Player())
        w = Player()\Weapon
        ;}
        ;}
        ;{Waffen auswahl
        If Player()\IsSpawning = 0
            If KeyboardPushed(Player()\Key_NextWeapon) Or MouseWheel() > 0
                If Player()\Key_Pressed_NextWeapon = 0
                    Player()\Weapon + 1
                    If Player()\Weapon => CountList(WeaponInfo())
                        Player()\Weapon = 0
                    EndIf
                    SelectElement(WeaponInfo(),Weapon(id,w)\WeaponInfoID)
                    Player()\Key_Pressed_NextWeapon = 1
                EndIf 
            Else
                Player()\Key_Pressed_NextWeapon = 0
            EndIf
            If KeyboardReleased(Player()\Key_PrevWeapon) Or MouseWheel() < 0
                If Player()\Key_Pressed_PrevWeapon = 0
                    Player()\Weapon - 1
                    If Player()\Weapon <= 0
                        Player()\Weapon = CountList(WeaponInfo())
                    EndIf
                    SelectElement(WeaponInfo(),Weapon(id,w)\WeaponInfoID)
                    Player()\Key_Pressed_PrevWeapon = 1
                EndIf 
            Else
                Player()\Key_Pressed_PrevWeapon = 0
            EndIf
        EndIf 
        ;}
        ;}
        ;{-Laufen 
        ;{Oben, unten, links, rechts laufen
        If KeyboardPushed(Player()\Key_Up)
            If Player()\WalkMode = #WalkMode_Walk2Mouse
                MoveX = (gCos(Player()\Angle) * Player()\Speed)
                MoveY = (gSin(Player()\Angle) * Player()\Speed)  
            Else
                MoveY + -Player()\Speed
            EndIf 
            CheckColl = 1
        EndIf
        If KeyboardPushed(Player()\Key_Down)
            If Player()\WalkMode = #WalkMode_Walk2Mouse
                MoveX = (gCos(Player()\Angle) * Player()\Speed)  *-1
                MoveY = (gSin(Player()\Angle) * Player()\Speed)  *-1
            Else 
                MoveY + Player()\Speed
            EndIf 
            CheckColl = 1
        EndIf
        If KeyboardPushed(Player()\Key_Left)
            If Player()\WalkMode = #WalkMode_Walk2Mouse
                MoveX = (gCos(Player()\Angle-90) * Player()\Speed / 2)
                MoveY = (gSin(Player()\Angle-90) * Player()\Speed / 2)
            Else
                MoveX + -Player()\Speed
            EndIf 
            CheckColl = 1
        EndIf
        If KeyboardPushed(Player()\Key_Right)
            If Player()\WalkMode = #WalkMode_Walk2Mouse
                MoveX = (gCos(Player()\Angle-90) * Player()\Speed / 2) *-1
                MoveY = (gSin(Player()\Angle-90) * Player()\Speed / 2) *-1
            Else
                MoveX + Player()\Speed
            EndIf 
            CheckColl = 1
        EndIf
        ;}
        ;{Kollisionscheck 
        If WeaponInfo()\Name = "MG"
            Player()\Speed = Player()\SlowSpeed
        Else
            Player()\Speed = Player()\FastSpeed
        EndIf
        If CheckColl
            If Player()\IsSpawning = 0
                If MoveX < 0
                    If Map(Int((Player()\RealX - MoveX) / #TileWidth),Int(Player()\RealY / #TileHeight)+1)\Coll = 1
                        MoveX = 0
                    EndIf 
                ElseIf MoveX > 0
                    If Map(Int((Player()\RealX + MoveX) / #TileWidth)+1,Int(Player()\RealY / #TileHeight)+1)\Coll = 1
                        MoveX = 0
                    EndIf 
                EndIf
                If MoveY < 0
                    If Map(Int((Player()\RealX) / #TileWidth)+1,Int((Player()\RealY - MoveY) / #TileHeight))\Coll = 1
                        MoveY = 0
                    EndIf 
                ElseIf MoveY > 0
                    If Map(Int((Player()\RealX) / #TileWidth)+1,Int((Player()\RealY + MoveY) / #TileHeight)+1)\Coll = 1
                        MoveY = 0
                    EndIf 
                EndIf
            EndIf 
            Map\CamX - MoveX  
            Map\CamY - MoveY 
            CheckColl = 0
            SendNet = 1
            Player()\IsWalking = 1
            FirstElement(Player())
        Else
            SoundWas = 0
            Player()\IsWalking = 0
        EndIf 
        ;}
        ;{Lauf Frames + Lauf Sound
        If Player()\IsWalking = 1 And Player()\IsSpawning = 0
            If SoundWas = 0
                PlaySound(#Sound_Walk,1)
                SoundVolume(#Sound_Walk,50)
                SoundWas = 1
            EndIf 
        ElseIf Player()\IsWalking = 0 
            StopSound(#Sound_Walk)
        EndIf
        Player()\Frame = WeaponInfo()\PlayerFrame
        ;}
        ;}
        ;{-Respawnen
        If Player()\IsSpawning = 1
            If KeyboardPushed(#PB_Key_R) 
                RealReSpawnPlayer()
            EndIf
        EndIf
        ;}
        ;} 
        ;{/Berechnungen
        ;{-Player() Position
        *Real\RealX = (*Real\X+Map\CamX*-1)
        *Real\RealY = (*Real\Y+Map\CamY*-1)
        *Real\TileX = *Real\RealX / #TileWidth
        *Real\TileY = *Real\RealY / #TileHeight
        tRealX = *Real\RealX
        tRealY = *Real\RealY
        tPX = *Real\X
        tPY = *Real\Y 
        ;}
        ;{-Look2Mouse 
        mx = MouseX() - 16
        my = MouseY() - 16
        a.l = mx - *Real\X
        b.l = my - *Real\Y 
        *Real\Angle = gATan(b, a) 
        
        MoveX = 0
        MoveY = 0
        ;}
        ;{-Zielkreuz "zittern lassen"
        tmx = MouseX() - 16
        tmy = MouseY() - 16
        If ShowRandomCross
            tmx + MinMax(2)
            tmy + MinMax(2)
            ShowRandomCross = 0
        EndIf
        ;}        
        ;{-Zeit Limit
        
        ;}
        ;}
        ;{/Netzwerk
        ;##########################################################
        ;MÜLL!!!!!!!!!!!
        ;##########################################################
        ;Alles neu proggen! Völlig falsche Idee! -_-
        If GameMode = #GameMode_Multiplayer
            If SendNet 
                Client_Send(Client_Connection,"/m "+Str(Player()\RealX)+"|"+Str(Player()\RealY))
                SendNet = 0
            EndIf 
            Select NetworkClientEvent(Client_Connection)
                Case 2
                    FreeMemory(ReceiveBuffer)
                    ReceiveBuffer = AllocateMemory(ReceiveBuffer_Lenght)
                    ReceiveNetworkData(Client_Connection,ReceiveBuffer,ReceiveBuffer_Lenght)
                    tString.s = PeekS(ReceiveBuffer)
                    tCommand.s = Trim(StringField(tString,1," "))
                    tExpr.s = Trim(StringField(tString,2," "))
                    Select tCommand
                        Case "/nl"
                            Debug tString
                            Client_ReceivePlayerList(Client_Connection,tExpr)
                        Case "/m"
                            tName.s = StringField(tExpr,3,"|")
                            tXPos.l = Val(StringField(tExpr,2,"|"))
                            tYPos.l = Val(StringField(tExpr,1,"|"))
                            If Trim(tName) <> ""
                                If tName <> Client_Nick
                                    ForEach NPlayer()
                                        If NPlayer()\nick = tName
                                            NPlayer()\X = tXPos
                                            NPlayer()\Y = tYPos
                                        EndIf
                                    Next
                                EndIf
                            EndIf
                    EndSelect
            EndSelect
        EndIf 
        ;}
        ;{/Anzeigen
        DisplayMap()
        DoBlood()
        DoShoot()
        DoBomb()
        DoSmoke()
        DoExplosion()
        DoBot()
        If Map\ShowMore = 1
            EditorDisplaySpawnPoints()
            EditorDisplayWayPoints()
        EndIf
        DisplayFragMsg()
        
        ;{-3D-Rendering
        Start3D()
        ;{Spieler
        If Player()\IsSpawning = 0
            RotateSprite3D(#Sprite_PlayerIndex+*Real\Frame,*Real\Angle + 90,0)
            DisplaySprite3D(#Sprite_PlayerIndex+*Real\Frame,*Real\X,*Real\Y)
        EndIf 
        ;}
        ;{Bots
        DisplayBot()
        ;}
        ;{Netzwerkspieler
        If GameMode = #GameMode_Multiplayer
            ForEach NPlayer()
                RotateSprite3D(#Sprite_PlayerIndex,NPlayer()\Angle,0)
                DisplaySprite3D(#Sprite_PlayerIndex,NPlayer()\X,NPlayer()\Y)
            Next
        EndIf
        ;}
        ;{Handgranaten
        DoGrenade()
        ;}
        Stop3D()
        ;}
        ;{-Nachladebalken
        If Weapon(id,w)\MustReload = 1 And *Real\IsSpawning = 0
            DisplaySprite(#Sprite_LoadBalken,#ScrWidth/2-100,#ScrHeight/2-45)
        EndIf 
        ;}        
        ;{-Waffen Informationen
        SelectElement(WeaponInfo(),Player()\Weapon)
        DisplayTransparentSprite(WeaponInfo()\MiniSprite,900,#ScrHeight-115)
        FontMapOutput(Font_StandardBig,Str(Weapon(id,w)\MagazinMunition)+"/"+Str(Weapon(id,w)\Magazins*WeaponInfo()\MagazinSize),900,#ScrHeight-50,#FHL,#FVT,$FFFFFF)
        FontMapOutput(Font_Standard,WeaponInfo()\Name,900,#ScrHeight-135,#FHL,#FVT,$FFFFFF)
        ;}      
        ;{-ReSpawn-Info
        If Player()\IsSpawning = 1 Or KeyboardPushed(#PB_Key_Tab)
            locX = #ScrWidth/4
            locY = #ScrHeight/4
            For I = 0 To CountList(Player()) - 1
                FontMapOutput(Font_Standard,Score(I)\Name,locX,locY+I*FontMapHigh(Font_Standard,Score(I)\Name),#FHL,#FVT,Score(I)\Color)
                FontMapOutput(Font_Standard,Str(Score(I)\Score-1),locX+200,locY+I*FontMapHigh(Font_Standard,Score(I)\Name),#FHL,#FVT,Score(I)\Color)
            Next
            UpdateScore()
            If Player()\IsSpawning = 1
                FontMapOutput(Font_Standard,"R zum Spawnen",500,500,#FHL,#FVT,$FFFFFF)
            EndIf 
        EndIf
        ;}
        ;{-Info über Bots
        ForEach Player()
            If Player()\IsBot = 1
                If Player()\Team = *Real\Team Or Map\ShowMore
                    FontMapOutput(Font_Standard,Player()\Name,Player()\x+Map\CamX,Player()\y+Map\CamY,#FHL,#FVT,$FFFFFF)
                EndIf 
            EndIf
        Next
        ;}
        ;{-Nachlade anzeige
        If Weapon(id,w)\MustReload = 1 And Player()\IsSpawning = 0
            ClipSprite(#Sprite_NachladeBox,0,0,(Time(Weapon(id,w)\ReloadTime) / WeaponInfo()\ReloadTime * 200),30)
            DisplaySprite(#Sprite_NachladeBox,#ScrWidth/2-100,#ScrHeight/2-45)
            DisplayTransparentSprite(#Sprite_NachladeRahmen,#ScrWidth/2-100,#ScrHeight/2-45)
        EndIf
        ;}
        ;{-Fadenkreuz
        DisplayTransparentSprite(#Sprite_Cross,tmx,tmy)
        ;}
        ;{-Energie Anzeige
        DisplayTransparentSprite(#Sprite_EnergyCross,50,#ScrHeight-100)
        FontMapOutput(Font_StandardBig,Str(*Real\Energy),100,#ScrHeight-94,#FHL,#FVT,$FFFFFF)
        ClipSprite(#Sprite_EnergyBox,0,0,30,*Real\Energy*2)
        DisplaySprite(#Sprite_EnergyBox,10,#ScrHeight-110+(100-*Real\Energy*2))
        DisplayTransparentSprite(#Sprite_EnergyRahmen,10,#ScrHeight-210)
        ;}
        ;{-FPS
        FontMapOutput(Font_Standard,Str(FPS()),950,0,#FHL,#FVT,$FFFFFF)
        ;}
        ;{-Radar
        DisplayRadar()
        ;}
        ;}
         
        FlipBuffers()
    Until Quit=#True 
    ;{Deconnect
    If GameMode = #GameMode_Multiplayer
        CloseNetworkConnection(Client_Connection)
    EndIf
    ;}
EndProcedure 
; jaPBe Version=2.5.2.24
; FoldLines=0005000B000C00120013001F002000280029003B003C00430044008E00450000
; FoldLines=0060000000680000007B0000008300000090009B00A101BD00A4000000AF0000
; FoldLines=00B0000000B2000000C3000000D0000000E3000000ED000000F7000000FF0000
; FoldLines=010B000001180000012C00000132000001380000013F0000015C0000015D0000
; FoldLines=0183000001A9000001B6000001BE01DF01BF000001C9000001D3000001DC0000
; FoldLines=01E002070216022D02180000021E00000221000002290000022E023202330238
; FoldLines=02640266026B026F
; Build=0
; FirstLine=19
; CursorPosition=581
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF