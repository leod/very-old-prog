;/
;/Brot
;/Variablen Datei
;/

;{-Konstanten
;{Einzelne Konstanten
#ScrWidth=1024
#ScrHeight=768
#TileWidth=32
#TileHeight=32
#MenuX=#ScrWidth/3*2
#MenuItems_Count=5
#Menu_Count=2
#Network_Port = 6832
#Bot_Count = 20
#FONT_NORMAL    = %00000000 
#FONT_BOLD      = %00000001 
#FONT_ITALIC    = %00000010 
#FONT_UNDERLINE = %00000100 
#FONT_STRIKEOUT = %00001000 
;}
Enumeration ;Sprites
    #Sprite_Mouse
    #Sprite_Shoot
    #Sprite_Tileset
    #Sprite_Tileset_Choose
    #Sprite_MousePointer
    #Sprite_Fog
    #Sprite_Cross
    #Sprite_Bomb
    #Sprite_InfoField
    #Sprite_Tank
    #Sprite_IsColl
    #Sprite_Selobrain
    #Sprite_SpawnPoint
    #Sprite_SpawnPoint2
    #Sprite_GFXFont
    #Sprite_Grenade
    #Sprite_Bot
    #Sprite_Bot2
    #Sprite_EditorBot
    #Sprite_LoadBalken
    #Sprite_WayPoint
    #Sprite_EnergyCross
    #Sprite_NachLaden
    #Sprite_EnergyBox
    #Sprite_EnergyRahmen
    #Sprite_NachladeBox
    #Sprite_NachladeRahmen
    #Sprite_Radar
    #Sprite_RadarFriend
    
    #Sprite_Menu_BG
    #Sprite_Menu_MousePointer
    #Sprite_Menu_SinglePlayer
    #Sprite_Menu_MultiPlayer
    #Sprite_Menu_Info
    #Sprite_Menu_Editor
    #Sprite_Menu_Options
    #Sprite_Menu_End
    #Sprite_Menu_Button
    #Sprite_Menu_ButtonPressed
    #Sprite_Menu_Training
    #Sprite_Menu_Back
    #Sprite_Menu_Deathmatch
    #Sprite_Menu_TeamDeathmatch
    
    #Sprite_Button_Load
    #Sprite_Button_Save
    #Sprite_Button_Card
    
    ;9 Sprites für Smokepuff reserviert
    #Sprite_SmokePuffIndex
    ;24 Sprites für HE explosion reserviert
    #Sprite_heExplosionIndex = #Sprite_SmokePuffIndex + 9
    ;8 Sprites für Player Frames reserviert
    #Sprite_PlayerIndex = #Sprite_heExplosionIndex + 24
    ;15 Sprites für Blut reserviert
    #Sprite_BloodIndex = #Sprite_PlayerIndex + 8
EndEnumeration
Enumeration ;Sounds
    #Sound_Reload
    #Sound_MagOut
    #Sound_MenuChange
    #Sound_Walk 
    #Sound_Explode
    #Sound_NoAmmo
    
    ;3 Sounds reserviert für Shell
    #Sound_ShellIndex
    ;7 Sounds reserviert für Bullet
    #Sound_BulletIndex = #Sound_ShellIndex + 3
EndEnumeration
Enumeration ;Movies
    #Movie_Selobrain
EndEnumeration
Enumeration ;Fenster
    ;
EndEnumeration
Enumeration ;Gadgets
    ;
EndEnumeration
Enumeration ;Images
    #Image_Tileset
EndEnumeration
Enumeration ;MenuItems_MainMenu
    #MenuItem_SinglePlayer
    #MenuItem_MultiPlayer
    #MenuItem_Info
    #MenuItem_Editor
    #MenuItem_Options
    #MenuItem_End 
EndEnumeration
Enumeration ;MenuItems_SingleplayerMenu
    #MenuItem_Training
    #MenuItem_TeamDeathmatch
    #MenuItem_Back = 5
EndEnumeration
Enumeration ;GameModes
    #GameMode_Training
    #GameMode_TeamDeathmatch
    #GameMode_Multiplayer
EndEnumeration
Enumeration ;WalkMode
    #WalkMode_Walk2Mouse
    #WalkMode_WalkWASD
EndEnumeration
Enumeration ;Menus
    #Menu_Main
    #Menu_Singleplayer
EndEnumeration
Enumeration ;FontMap Ausrichtung
    #FHL               ;Ausrichtung horizontal linksbündig (LEFT)
    #FHC               ;Ausrichtung horizontal zentriert (CENTER)
    #FHR               ;Ausrichtung horizontal rechtsbündig (RIGHT)
EndEnumeration
Enumeration ;FontMap Ausrichtung
    #FVT               ;Ausrichtung vertikal obenbündig (TOP)
    #FVC               ;Ausrichtung vertikal zentriert (CENTER)
    #FVB               ;Ausrichtung vertikal untenbündig (BOTTOM)
EndEnumeration
;}
;{-Strukturen
Structure wh
    w.l
    h.l
EndStructure
Structure Player
    X.f
    Y.f
    RealX.f
    RealY.f
    TileX.l
    TileY.l 
    Kills.l
    IsSpawning.l
    
    Name.s
    
    ZX.l
    ZY.l
    IsBot.l
    WalkTimer.l
    BotShoot.l
    SpawnTime.l
    Team.l
    *Enemy.Player
    HasEnemy.l
    WPW.l[100]
    WPWC.l
    
    IsWalking.l
    Angle.l
    WalkMode.l
    
    ShootTime.l 
    Weapon.l
    
    Frame.l
    
    Speed.f
    RotSpeed.l
    FastSpeed.f
    SlowSpeed.f
    
    Energy.l
    
    SpaceTime.l
    
    Key_Up.l
    Key_Down.l
    Key_Left.l
    Key_Right.l
    Key_Angle_Up.l
    Key_Angle_Down.l
    Key_Shoot.l
    Key_NextWeapon.l
    Key_PrevWeapon.l
    Key_Pressed_NextWeapon.l
    Key_Pressed_PrevWeapon.l 
EndStructure
Structure Shoot
    *OwnerPtr.Player
    X.f
    Y.f
    SpeedX.f
    SpeedY.f
    Power.l
    Weapon.s
    Angle.l
    Owner.l
    Name.s
EndStructure
Structure WeaponInfo
    Name.s
    ShootSpeed.l
    ShootDelay.l
    MagazinSize.l
    ReloadTime.f
    SoundID.l
    MiniSprite.l
    PlayerFrame.l
    Power.l
    Streu.l
EndStructure
Structure Weapon
    WeaponInfoID.l
    MagazinMunition.l
    Magazins.l
    MustReload.l
    ReloadTime.f
EndStructure
Structure Tile
    TX.l
    TY.l
    Coll.l 
EndStructure
Structure Map
    Width.l
    Height.l
    Name.s
    CamX.f
    CamY.f
    EditorSpeed.l
    Time.l
    TimeLimit.l
    ShowMore.l
EndStructure
Structure Box
    X.l
    Y.l
    w.l
    h.l
EndStructure
Structure Editor
    ActTile.Box 
    IsSettingTile.l 
    InScrollArea.POINT 
    LButton.l 
    TileSetScrollX.l
    Tileset.wh 
EndStructure
Structure Smoke
    X.l
    Y.l
    Frame.l
    Time.l
EndStructure
Structure MenuItem
    SpriteID.l
    OnClick.l 
    State.l 
EndStructure
Structure Explosion
    X.l
    Y.l
    Frame.l
    Time.l 
    Type.l
    FrameLim.l 
    *OwnerPtr.Player 
EndStructure
Structure Bomb
    X.l
    Y.l
    Time.l
    Explode.l
    ShootCounter.l
    *OwnerPtr.Player 
EndStructure
Structure Vehicle
    X.l
    Y.l
    Angle.l
    Type.l
EndStructure
Structure NPlayer
    X.l
    Y.l
    Angle.l
    nick.s
EndStructure
Structure Button
    Sprite.l
    IsClicked.l
    X.l
    Y.l
EndStructure
Structure SpawnPoint
    X.l
    Y.l
    Team.l
EndStructure
Structure Grenade
    X.f
    Y.f
    DisAngle.l
    SpeedX.f
    SpeedY.f
    Speed.f
    Time.l
    MovAngle.l
    StopDisAngle.l
    Zoom.l
    ZoomMode.l
    Limit.l
    *OwnerPtr.Player 
EndStructure
Structure Blood
    X.l
    Y.l
    Type.l
    Time.l
EndStructure
Structure Score
    Name.s
    Score.l
    Color.l
EndStructure
Structure WayPoint
    X.l
    Y.l
EndStructure
Structure Prefs
    CrossHair.s
    BotNamesFile.s
    WeaponFile.s
EndStructure
Structure FontMap
    back.l             ;Transparente Hintergrundfarbe des QS
    over.l             ;Veränderliche Vordergrundfarbe des QS
    wide.w             ;Globaler Zeichenabstand
    high.w             ;Globaler Zeilenabstand
    numx.w             ;Feldanzahl in x auf QS
    numy.w             ;Feldanzahl in y auf QS
    lenx.w             ;Feldbreite auf QS
    leny.w             ;Feldhöhe auf QS
    maxi.w[256]        ;Reduzierte Zeichenbreite
    posx.w[256]        ;Position x auf QS
    posy.w[256]        ;Position y auf QS
    imag.l             ;Adresse des Quell-Sprites
    copy.l             ;Adresse des Mirror-Sprites
    acol.l             ;aktuelle Farbe des MS
EndStructure
;}
;{-Listen
NewList Shoot.Shoot() 
NewList WeaponInfo.WeaponInfo() 
NewList Smoke.Smoke() 
NewList Explosion.Explosion() 
NewList Bomb.Bomb() 
NewList Vehicle.Vehicle() 
NewList NPlayer.NPlayer() 
NewList Button.Button()
NewList File.s()
NewList SpawnPoint.SpawnPoint()
NewList Grenade.Grenade()
NewList Player.Player()
NewList FragMsg.s()
NewList Blood.Blood()
NewList Name.s()
NewList UsedName.s()
NewList WayPoint.WayPoint()
NewList FontMap.FontMap()
;}
;{-Arrays
Dim Map.Tile(0,0)
Dim Menu.MenuItem(#Menu_Count,#MenuItems_Count)
Dim Weapon.Weapon(0,0)
Dim Score.Score(0)
;}
;{-Variablen
;{Player
Global tRealX.l
Global tRealY.l
Global tPX.l
Global tPY.l
Global tSpawning.l
Global *Real.Player 
;}
;{Map
Global Map.Map 
Map\EditorSpeed = 5
;}
;{Editor
Global Button_Load
Global Button_Save
Global Button_New
;}
;{Einzelne
Global Editor.Editor 
Global IsEditor.l 
Global GameMode.l
Global Timer_StartTime.l
Global Quit.l
Global Client_Nick.s : Client_Nick = "Leo2"
Global ScreenshotNr.l
Global GameTitle.s : GameTitle = "Brot"
Global SoundPath.s : SoundPath = "Sounds\"
Global GFXPath.s   : GFXPath = "Grafik\"
Global MoviePath.s : MoviePath = "Movie\"
Global *Preferences.Prefs
Global FontMapCount
;}
;{Schriften
Global Font_Standard
Global Font_StandardBig
Global Font_FragMsg
;}
;} 
; jaPBe Version=2.5.2.24
; FoldLines=000600150051005D005E0060006100630064006600670069006A007100720076
; FoldLines=0077007B007C007F00800083008400880089008D008F016D0090000000940000
; FoldLines=00CA000000D6000000E2000000E9000000EE000000F9000000FF000001070000
; FoldLines=010D000001120000011B00000123000001290000012F000001350000013A0000
; FoldLines=01490000014F00000154000001580000015D0000016E018101820187018801AE
; FoldLines=018900000191000001950000019A000001A90000
; Build=0
; FirstLine=13
; CursorPosition=51
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF