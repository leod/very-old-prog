;/
;/Brot
;/Procedure zum Laden aller Dateien
;/

Procedure LoadSpriteEx(id.l,file.s)
    If LoadSprite(id,file) = 0
        Error("Kann "+file+" nicht finden!")
    Else
        ProcedureReturn 1
    EndIf
EndProcedure
Procedure LoadSpriteEx_Mode(id.l,file.s,mode.l)
    If LoadSprite(id,file,mode) = 0
        Error("Kann "+file+" nicht finden!")
    Else
        ProcedureReturn 1
    EndIf
EndProcedure
Procedure LoadSoundEx(id.l,file.s)
    If LoadSound(id,file) = 0 
        Error("Kann "+file+" nicht finden!")
    Else
        ProcedureReturn 1
    EndIf
EndProcedure
Procedure LoadMovieEx(id.l,file.s)
    If LoadMovie(id,file) = 0
        Error("Kann "+file+" nicht finden!")
    Else
        ProcedureReturn 1 
    EndIf 
EndProcedure
Procedure CreateFont(Name$,Size,style) 
    If (Style & #FONT_BOLD)      : bold = 700    : EndIf 
    If (Style & #FONT_ITALIC)    : italic = 1    : EndIf 
    If (Style & #FONT_UNDERLINE) : underline = 1 : EndIf 
    If (Style & #FONT_STRIKEOUT) : strikeout = 1 : EndIf 
    ProcedureReturn CreateFont_(Size,0,0,0,bold,italic,underline,strikeout,0,0,0,0,0,Name$) 
EndProcedure 
Procedure LoadFiles()
    UsePNGImageDecoder()
    UseJPEGImageDecoder()
    ;{-Sounds
    FastText("Lade Sounds",300,300)
    LoadSoundEx(#Sound_Reload,SoundPath+"reload.wav")
    LoadSoundEx(#Sound_MagOut,SoundPath+"magout.wav")
    LoadSoundEx(#Sound_MenuChange,SoundPath+"menuchange.wav")
    LoadSoundEx(#Sound_Walk,SoundPath+"laufen.wav")
    LoadSoundEx(#Sound_Explode,SoundPath+"explosion.wav")
    LoadSoundEx(#Sound_NoAmmo,SoundPath+"noammo.wav")
    ;{Shell
    For I=1 To 3
        LoadSoundEx(#Sound_ShellIndex+I-1,SoundPath+"shell"+Str(I)+".wav")
    Next
    ;}
    ;{Bullet
    For I=1 To 7
        LoadSoundEx(#Sound_BulletIndex+I-1,SoundPath+"bullet"+Str(I)+".wav")
    Next
    ;}
    ;}
    ;{-Sprites
    FastText("Lade Bilder",300,300)
    ;{Smokepuff
    For I=1 To 9
        LoadSpriteEx(#Sprite_SmokePuffIndex+I-1,GFXPath+"Smoke\smokepuff"+Str(I)+".bmp")
    Next
    ;}
    ;{Explosionen
    For I=1 To 24
        LoadSpriteEx(#Sprite_heExplosionIndex+I-1,GFXPath+"Explosion\HE_explosion"+Str(I)+".bmp")
        TransparentSpriteColor(#Sprite_heExplosionIndex+I-1,255,255,255)
    Next
    ;}
    ;{Player
    For I=1 To 4
        LoadSpriteEx_Mode(#Sprite_PlayerIndex+I-1,GFXPath+"Player\figur"+Str(I)+".png",#PB_Sprite_Texture)
        CreateSprite3D(#Sprite_PlayerIndex+I-1,#Sprite_PlayerIndex+I-1)
    Next 
    For I=0 To 9
        LoadSpriteEx(#Sprite_BloodIndex+I,GFXPath+"Blood\blood_3_"+Str(I)+".bmp")
        TransparentSpriteColor(#Sprite_BloodIndex+I,248,252,248)
    Next
    LoadSpriteEx(#Sprite_Cross,GFXPath+"CrossHair\"+*Preferences\CrossHair)
    LoadSpriteEx(#Sprite_Selobrain,GFXPath+"selobrain2.bmp")
    LoadSpriteEx(#Sprite_Shoot,GFXPath+"Shoot.bmp")
    LoadSpriteEx(#Sprite_Tileset,GFXPath+"Tileset.bmp")
    LoadSpriteEx(#Sprite_InfoField,GFXPath+"intro.png")
    LoadSpriteEx(#Sprite_Tank,GFXPath+"Cars\tank.bmp")
    LoadSpriteEx(#Sprite_MousePointer,GFXPath+"Editor\MousePointer.png")
    LoadSpriteEx(#Sprite_Bomb,GFXPath+"bomb.bmp")
    LoadSpriteEx(#Sprite_LoadBalken,GFXPath+"nachladebalken.png")
    LoadSpriteEx(#Sprite_EnergyCross,GFXPath+"kreuz.bmp")
    LoadSpriteEx(#Sprite_EnergyBox,GFXPath+"EnergyBox.bmp")
    LoadSpriteEx(#Sprite_EnergyRahmen,GFXPath+"EnergyRahmen.bmp")
    LoadSpriteEx(#Sprite_NachladeBox,GFXPath+"NachladeBox.bmp")
    LoadSpriteEx(#Sprite_NachladeRahmen,GFXPath+"NachladeRahmen.bmp")
    LoadSpriteEx(#Sprite_Radar,GFXPath+"Radar.png")
    LoadSpriteEx(#Sprite_RadarFriend,GFXPath+"Friend.png")
    LoadSpriteEx_Mode(#Sprite_Grenade,GFXPath+"granate2.png",#PB_Sprite_Texture)
    LoadSpriteEx_Mode(#Sprite_Fog,GFXPath+"fog.bmp",#PB_Sprite_Texture)
    LoadSpriteEx_Mode(#Sprite_Bot,GFXPath+"Player\bot1.bmp",#PB_Sprite_Texture)
    LoadSpriteEx_Mode(#Sprite_Bot2,GFXPath+"Player\bot2.bmp",#PB_Sprite_Texture)
    CreateSprite3D(#Sprite_Bot,#Sprite_Bot)
    CreateSprite3D(#Sprite_Bot2,#Sprite_Bot2)
    CreateSprite3D(#Sprite_Fog,#Sprite_Fog)
    CreateSprite3D(#Sprite_Grenade,#Sprite_Grenade)
    TransparentSpriteColor(#Sprite_Bomb,255,255,255)
    TransparentSpriteColor(#Sprite_MousePointer,255,0,255)
    TransparentSpriteColor(#Sprite_Cross,255,0,255)
    TransparentSpriteColor(#Sprite_Fog,255,255,255)
    TransparentSpriteColor(#Sprite_EnergyCross,255,0,255)
    TransparentSpriteColor(#Sprite_EnergyRahmen,255,255,255)
    TransparentSpriteColor(#Sprite_NachladeRahmen,255,255,255)
    TransparentSpriteColor(#Sprite_Radar,255,255,255)
    TransparentSpriteColor(#Sprite_RadarFriend,255,255,255)
    ;}
    ;{Menu Grafiken
    LoadSpriteEx(#Sprite_Menu_BG,GFXPath+"Menu\hintergrund.jpg")
    LoadSpriteEx(#Sprite_Menu_MousePointer,GFXPath+"Menu\maus.bmp")
    LoadSpriteEx(#Sprite_Menu_SinglePlayer,GFXPath+"Menu\singleplayer.bmp")
    LoadSpriteEx(#Sprite_Menu_Button,GFXPath+"Menu\balkenunpressed.bmp")
    LoadSpriteEx(#Sprite_Menu_MultiPlayer,GFXPath+"Menu\multiplayer.bmp")
    LoadSpriteEx(#Sprite_Menu_Info,GFXPath+"Menu\info.bmp")
    LoadSpriteEx(#Sprite_Menu_Editor,GFXPath+"Menu\editor.bmp")
    LoadSpriteEx(#Sprite_Menu_Options,GFXPath+"Menu\optionen.bmp")
    LoadSpriteEx(#Sprite_Menu_End,GFXPath+"Menu\beenden.bmp")
    LoadSpriteEx(#Sprite_Menu_ButtonPressed,GFXPath+"Menu\balkenpressed.bmp")
    LoadSpriteEx(#Sprite_Menu_Training,GFXPath+"Menu\training.bmp")
    LoadSpriteEx(#Sprite_Menu_Back,GFXPath+"Menu\back.bmp")
    LoadSpriteEx(#Sprite_Menu_Deathmatch,GFXPath+"Menu\deathmatch.png")
    LoadSpriteEx(#Sprite_Menu_TeamDeathmatch,GFXPath+"Menu\teamdeathmatch.png")
    TransparentSpriteColor(#Sprite_Menu_Button,255,255,255)
    TransparentSpriteColor(#Sprite_Menu_MousePointer,255,255,255)
    TransparentSpriteColor(#Sprite_Menu_SinglePlayer,255,0,255)
    TransparentSpriteColor(#Sprite_Menu_MultiPlayer,255,0,255)
    TransparentSpriteColor(#Sprite_Menu_Info,255,0,255)
    TransparentSpriteColor(#Sprite_Menu_Editor,255,0,255)
    TransparentSpriteColor(#Sprite_Menu_Options,255,0,255)
    TransparentSpriteColor(#Sprite_Menu_End,255,0,255)
    TransparentSpriteColor(#Sprite_Menu_ButtonPressed,255,255,255)
    TransparentSpriteColor(#Sprite_Menu_Training,255,0,255)
    TransparentSpriteColor(#Sprite_Menu_Back,255,0,255)
    TransparentSpriteColor(#Sprite_Menu_TeamDeathmatch,255,0,255)
    TransparentSpriteColor(#Sprite_Menu_Deathmatch,255,0,255)
    ;}
    ;{Editor
    LoadSpriteEx(#Sprite_IsColl,GFXPath+"coll.bmp")
    LoadSpriteEx(#Sprite_Button_Load,GFXPath+"Buttons\"+"Laden.png")
    LoadSpriteEx(#Sprite_Button_Save,GFXPath+"Buttons\"+"Speichern.png")
    LoadSpriteEx(#Sprite_SpawnPoint,GFXPath+"Editor\spawnpoint.bmp")
    LoadSpriteEx(#Sprite_SpawnPoint2,GFXPath+"Editor\spawnpoint2.bmp")
    LoadSpriteEx(#Sprite_Button_Card,GFXPath+"Buttons\"+"Karte.png")
    LoadSpriteEx(#Sprite_WayPoint,GFXPath+"Editor\WayPoint.bmp")
    TransparentSpriteColor(#Sprite_SpawnPoint,255,255,255)
    TransparentSpriteColor(#Sprite_SpawnPoint2,255,255,255)
    TransparentSpriteColor(#Sprite_Button_Card,255,0,255)
    TransparentSpriteColor(#Sprite_Button_Load,255,0,255)
    TransparentSpriteColor(#Sprite_Button_Save,255,0,255)
    TransparentSpriteColor(#Sprite_WayPoint,255,255,255)
    ;}    
    ;{Tileset einstellungen
    Editor\Tileset\w = SpriteWidth(#Sprite_Tileset)
    Editor\Tileset\h = SpriteWidth(#Sprite_Tileset)
    LoadImage(#Image_Tileset,GFXPath+"Tileset.bmp")
    CopySprite(#Sprite_Tileset,#Sprite_Tileset_Choose)
    ;}
    ;}
    ;{-Movies
    ;LoadMovieEx(#Movie_Selobrain,MoviePath+"selobrain.mov")
    ;}
    ;{-Schriften
    FastText("Lade Schriften",300,300)
    Font_Standard    = FontMapLoad("Fonts\AgastTall.bmp")
    Font_FragMsg     = FontMapLoad("Fonts\Monkey1.bmp")
    Font_StandardBig = FontMapLoad("Fonts\AgastLarge.bmp")
    ;}
EndProcedure 
; jaPBe Version=2.5.2.24
; FoldLines=0005000B000C001200130019001A002000210027002B003D0033000000380000
; FoldLines=004000440045004A00760092009300A100A200A700A900AB00AC00B1
; Build=0
; FirstLine=9
; CursorPosition=106
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF