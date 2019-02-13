;{- Init
EnableExplicit

InitSound()
InitSprite()

; OpenConsole()

; Define screenSettings.DEVMODE
; screenSettings\dmSize = SizeOf(DEVMODE)
; screenSettings\dmPelsWidth = 32
; screenSettings\dmPelsWidth = 800
; screenSettings\dmPelsHeight = 600
; screenSettings\dmFields = #DM_BITSPERPEL | #DM_PELSWIDTH | #DM_PELSHEIGHT
; 
; Define Result.l = ChangeDisplaySettings_(@screenSettings, #CDS_FULLSCREEN | #CDS_RESET)

OpenWindow(0, 0, 0, 320, 288, "Jump'n'run", #PB_Window_ScreenCentered)

; CreateGadgetList(WindowID(0))
; LoadImage(0, "Data/Gameboy.bmp")
; Debug ImageID(0)
; ImageGadget(0, 0, 0, 483, 372, ImageID(0))
; SetWindowColor(WindowID(0), RGB(0, 0, 0)) ; Crash.

; Define Brush.l = CreateSolidBrush_(RGB(0, 0, 0)) 
; SetClassLong_(WindowID(0), #GCL_HBRBACKGROUND, Brush) 
; InvalidateRect_(WindowID(0), #Null, #True)
; 
; hBrush2 = CreateSolidBrush_(RGB(100, 100, 100)) 
; SetClassLong_(hWnd2, #GCL_HBRBACKGROUND, hBrush2) 
; 
; InvalidateRect_(hWnd1, #Null, #True) 
; InvalidateRect_(hWnd2, #Null, #True) 

; 320 | 288

; DMSim_CreateScreen(WindowID(0), (800 - 320) / 2, (600 - 288) / 2)

DMSim_CreateScreen(WindowID(0), 0, 0)

;}
;{- Constants
#Screen_Width = 160
#Screen_Height = 144
#Gravity = 1

Enumeration
    #Collision_None
    #Collision_TopLeft
    #Collision_TopRight
    #Collision_BottomLeft
    #Collision_BottomRight
EndEnumeration

Enumeration
    #Direction_Left
    #Direction_Right
    
    #Direction_Up
    #Direction_Down
EndEnumeration

Enumeration
    #Mode_Nothing
    #Mode_Game
    #Mode_Editor
    #Mode_Menu
EndEnumeration

; LeoD <3 globals
Global PreviousMode.l = #Mode_Nothing
Global GameMode.l = #Mode_Menu

Procedure SetGameMode(Mode.l)
    PreviousMode = GameMode
    GameMode = Mode
    
    ; Debug Str(PreviousMode) + "|" + Str(GameMode)
EndProcedure

; Assert(PreviousMode = #Mode_Nothing)
;}
;{- Utils
Macro DoubleQuote
    "
EndMacro

Macro Assert(__Expr, __Msg = "Error")
    If Not __Expr : PrintN("ASSERTION FAILED (" + Str(#PB_Compiler_Line) + "): " + DoubleQuote#__Expr#DoubleQuote + " (" + __Msg + ")")  : Input() : End : EndIf
EndMacro

Procedure Rect(X.l, Y.l, Width.l, Height.l, LightRate.l)
    DMSim_Quad(X, Y, X + Width, Y + 1, LightRate.l)
    DMSim_Quad(X, Y, X + 1, Y + Height, LightRate)
    DMSim_Quad(X, Y + Height, X + Width, Y + Height - 1, LightRate)
    DMSim_Quad(X + Width, Y + Height, X + Width - 1, Y, LightRate)
EndProcedure

; Macro Static_Sprite(File, Name = Sprite)
    ; Static Name#.l = #Null
    ; 
    ; If Not Name
        ; Name = DMSim_ImportSpriteFromFile(File)
    ; EndIf
; EndMacro

Procedure.l GetSprite(File.s)
    Structure LoadedSprite
        File.s
        Sprite.l
    EndStructure
    
    Static NewList Sprites.LoadedSprite()
    
    ForEach Sprites()
        If Sprites()\File = File
            ProcedureReturn Sprites()\Sprite
        EndIf
    Next

    AddElement(Sprites())
    Sprites()\File = File
    Sprites()\Sprite = DMSim_ImportSpriteFromFile("Data/" + File)
    
    Assert(Sprites()\Sprite, "sprite not found: " + File)
    
    ProcedureReturn Sprites()\Sprite
EndProcedure

Procedure.l GetSound(File.s)
    Structure LoadedSound
        File.s
        Sound.l
    EndStructure
    
    Static NewList Sounds.LoadedSound()
    
    ForEach Sounds()
        If Sounds()\File = File
            ProcedureReturn Sounds()\Sound
        EndIf
    Next
    
    AddElement(Sounds())
    Sounds()\File = File
    Sounds()\Sound = LoadSound(#PB_Any, "Data/" + File)
    
    Assert(Sounds()\Sound, "sound not found: " + File)
    
    ProcedureReturn Sounds()\Sound
EndProcedure

Macro RenderSound(Name)
    CompilerIf Defined(__Sound_#Name, #PB_Variable) = #False
        Static __Sound_#Name#.l
    CompilerEndIf
   
    If Not __Sound_#Name
        __Sound_#Name = GetSound(DoubleQuote#Name#DoubleQuote + ".wav")
    EndIf
    
    PlaySound(__Sound_#Name)
EndMacro

Macro HaltSound(Name)
    CompilerIf Defined(__Sound_#Name, #PB_Variable) = #False
        Static __Sound_#Name#.l
    CompilerEndIf
    
    If Not __Sound_#Name
        __Sound_#Name = GetSound(DoubleQuote#Name#DoubleQuote + ".wav")
    EndIf
    
    StopSound(__Sound_#Name)
EndMacro

Procedure SmartDelay(Time.l)
    Define Begin.l = ElapsedMilliseconds()
    
    While ElapsedMilliseconds() - Begin < Time
        While WindowEvent() : Wend
        Delay(10)
    Wend
EndProcedure
;}
;{- Classes
;{ Array
Class Array

    Array(ElementSize.l, Count.l = 0)
    Release()
    
    GetCount()
    
    Set(Index.l, Value.l)
    Get(Index.l)
    
    Allocate(Count.l)
    Append(Value.l)
    
    ; Can change the elements' order
    Remove(Index.l)
    
    Clear()
    
    *Entries.l
    ElementSize.l
    Count.l
    
EndClass

Procedure Array\Array(ElementSize.l, Count.l = 0)
    This\ElementSize = ElementSize

    If Count <> 0
        This\Allocate(Count)
    EndIf
EndProcedure

Procedure Array\Release()
    If This\Entries
        FreeMemory(This\Entries)
    EndIf
EndProcedure

Procedure Array\GetCount()
    ProcedureReturn This\Count
EndProcedure

Procedure Array\Set(Index.l, Value.l)
    Assert(Index >= 0)
    Assert(Index < This\Count)
    
    CopyMemory(Value, This\Entries + Index * This\ElementSize, This\ElementSize)
EndProcedure

Procedure Array\Get(Index.l)
    Assert(Index >= 0)
    Assert(Index < This\Count)
    
    ProcedureReturn This\Entries + Index * This\ElementSize
EndProcedure

Procedure Array\Allocate(Count.l)
    This\Count = Count
    This\Entries = ReAllocateMemory(This\Entries, This\Count * This\ElementSize)
EndProcedure

Procedure Array\Append(Value.l)
    This\Allocate(This\Count + 1)
    This\Set(This\Count - 1, Value)
EndProcedure

Procedure Array\Remove(Index.l)
    Assert(This\Count)
    This\Count - 1
    
    If This\Count = 0 Or Index = This\Count
        ProcedureReturn
    EndIf
    
    CopyMemory(This\Entries + This\Count * This\ElementSize, This\Entries + Index * This\ElementSize, This\ElementSize)
EndProcedure

Procedure Array\Clear()
    This\Count = 0
    FreeMemory(This\Entries)
    This\Entries = #Null
EndProcedure
;}
;{ Camera
Class Camera
    
    GetX()
    GetY()
    
    SetX(X.l)
    SetY(Y.l)

    ; Convert absolute into relative coordinates
    ConvX(X.l)
    ConvY(Y.l)

    X.l
    Y.l

EndClass

Procedure Camera\GetX()
    ProcedureReturn This\X
EndProcedure

Procedure Camera\GetY()
    ProcedureReturn This\Y
EndProcedure

Procedure Camera\SetX(X.l)
    This\X = X
EndProcedure

Procedure Camera\SetY(Y.l)
    This\Y = Y
EndProcedure

Procedure Camera\ConvX(X.l)
    ProcedureReturn X - This\X
EndProcedure

Procedure Camera\ConvY(Y.l)
    ProcedureReturn Y - This\Y
EndProcedure
;}
;{ Game interface
Prototype.l Entity_Constructor(X.l, Y.l)

Structure EntityType
    Name.c[64]
    
    *Constructor.Entity_Constructor
    Sprite.l ; Preview for the editor
EndStructure

Class GameInterface
    Abstract PlayerDead()
    Abstract PlayerHitSavePoint(X.l, Y.l)
    Abstract PlayerHitWarp(Target.l)
    
    Abstract AddLife()
    Abstract AddCoin()
    
    Abstract GetPlayer()
    Abstract GetEntities()
    Abstract GetMap()
    
    Abstract AddEntity(Entity.l)
    Abstract GetEntityType(Name.s)
    Abstract CreateEntity(*EntityType.EntityType, X.l, Y.l)
EndClass

;}
;{ Map
#Tile_Width = 10
#Tile_Height = 10

Structure Tile
    IsSet.l
    X.l : Y.l ; Needed?
    Type.l ; Pointer to a TileType
EndStructure

Prototype TileType_OnBottomHit(*Tile.Tile, *Game.GameInterface)
Prototype TileType_OnTopHit(*Tile.Tile, *Game.GameInterface)
Prototype TileType_OnHit(*Tile.Tile, *Game.GameInterface)

Structure TileType
    Name.c[64]
    Sprite.l
    
    ; Callbacks, called by Player
    *OnBottomHit.TileType_OnBottomHit
    *OnTopHit.TileType_OnTopHit
    *OnHit.TileType_OnHit
EndStructure

Class Map
    
    Map(Width.l, Height.l)
    Release()
    
    AddTileType(Name.s, Sprite.l, *OnBottomHit.TileType_OnBottomHit, *OnTopHit.TileType_OnTopHit, *OnHit.TileType_OnHit)
    GetTileType(Name.s)
    GetTileTypes()
    
    GetTile(X.l, Y.l)
    SetTile(X.l, Y.l, Type.s)
    
    GetWidth()
    GetHeight()
    
    Render(*Camera.Camera)
        
    *TileTypes.Array
        
    Width.l
    Height.l
        
    *Tiles.Array
    
EndClass

Procedure Map\Map(Width.l, Height.l)
    This\TileTypes = NewObject Array(SizeOf(TileType))
    This\Width = Width
    This\Height = Height
    This\Tiles = NewObject Array(SizeOf(Tile), This\Width * This\Height)
EndProcedure

Procedure Map\Release()
    DeleteObject This\Tiles
EndProcedure

Procedure Map\AddTileType(Name.s, Sprite.l, *OnBottomHit.TileType_OnBottomHit, *OnTopHit.TileType_OnTopHit, *OnHit.TileType_OnHit)
    Define TileType.TileType
    
    CopyMemory(@Name, @TileType\Name, Len(Name) + 1)
    TileType\Sprite = Sprite
    TileType\OnBottomHit = *OnBottomHit
    TileType\OnTopHit = *OnTopHit
    TileType\OnHit = *OnHit

    This\TileTypes\Append(@TileType)
EndProcedure

Procedure Map\GetTileType(Name.s)
    Define I.l
    
    For I = 0 To This\TileTypes\GetCount() - 1
        Define *TileType.TileType = This\TileTypes\Get(I)
        
        If PeekS(@*TileType\Name) = Name
            ProcedureReturn *TileType
        EndIf
    Next
    
    Assert(#False, "tile type '" + Name + "' not found")
EndProcedure

Procedure Map\GetTileTypes()
    ProcedureReturn This\TileTypes
EndProcedure

Procedure Map\GetTile(X.l, Y.l)
    Assert(X >= 0)
    Assert(X < This\Width)
    Assert(Y >= 0)
    Assert(Y < This\Height)
    
    ProcedureReturn This\Tiles\Get(Y * This\Width + X)
EndProcedure

Procedure Map\SetTile(X.l, Y.l, Type.s)
    Define *Tile.Tile = This\GetTile(X, Y)
    
    *Tile\IsSet = #True
    *Tile\X = X
    *Tile\Y = Y
    *Tile\Type = This\GetTileType(Type)
EndProcedure

Procedure Map\GetWidth()
    ProcedureReturn This\Width
EndProcedure

Procedure Map\GetHeight()
    ProcedureReturn This\Height
EndProcedure

Procedure Map\Render(*Camera.Camera)
    Define StartX.l = *Camera\GetX() / #Tile_Width
    Define EndX.l = StartX + #Screen_Width / #Tile_Width
    Define StartY.l = *Camera\GetY() / #Tile_Height
    Define EndY.l = StartY + #Screen_Width / #Tile_Width
    
    If StartX < 0 : StartX = 0 : EndIf
    If StartX >= This\Width : StartX = This\Width - 1 : EndIf
    If StartY < 0 : StartY = 0 : EndIf
    If StartY >= This\Height : StartY = This\Height - 1 : EndIf
    If EndX < 0 : EndX = 0 : EndIf
    If EndX >= This\Width : EndX = This\Width - 1 : EndIf
    If EndY < 0 : EndY = 0 : EndIf
    If EndY >= This\Height : EndY = This\Height - 1 : EndIf 

    Define X.l, Y.l
    
    For Y = StartY To EndY
        For X = StartX To EndX
            
            Define *Tile.Tile = *This\GetTile(X, Y)
            Define *Type.TileType = *Tile\Type

            If *Tile\IsSet
                DMSim_DisplayTransparentSprite(*Type\Sprite, *Camera\ConvX(X * #Tile_Width), *Camera\ConvY(Y * #Tile_Height), 0)
            EndIf
            
        Next
    Next
EndProcedure
;}
;{ Entity
Enumeration
    #Entity_Player
    #Entity_Shoot
    #Entity_Enemy
    #Entity_SavePoint
    #Entity_Platform
    #Entity_Warp
    #Entity_PowerUp
    #Entity_Coin
    #Entity_CoinBlink
    #Entity_Killer
    #Entity_Spawner
    #Entity_Boss
    #Entity_Bomb
EndEnumeration

Prototype Entity_Attributes_Callback(UserDefined.l, Name.s, Description.s, Type.l, Pointer.l)

Class Entity

    Entity()
    
    IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
    Init() ; Called after all attributes have been loaded
    
    Kill()
    
    Abstract Update()
    Abstract Render()
    
    GetX()
    GetY()
    
    SetX(X.l)
    SetY(Y.l)
    
    GetWidth()
    GetHeight()

    GetType()
    GetEntityType()
    
    IsActive()
    IsSolid()
    
    CheckTileCollision(X.l, Y.l, *OutTile.Long = #Null)
    IsMapCollision(X.l, Y.l, *OutTile.Long = #Null)
    
    IsEntityCollision(Object.l, X.l, Y.l)
    
    Move(X.f, Y.f, *OutTile.Long = #Null)
    
    RequestRemoval()
    ShallBeRemoved()

    DoRemove.l
    
    Active.l
    Solid.l
    
    ; Type
    Type.l
    EntityType.l ; Actually a pointer to a structure
    
    ; Absolute position
    X.f
    Y.f
    
    ; Game manager
    *Game.GameInterface
    
    ; Dimension
    Width.l
    Height.l
    
    ; Camera
    *Camera.Camera
    
    ; Map
    *Map.Map
    
    ; Entity list
    *Entities.Array

EndClass

Procedure Entity\Entity()
    This\Active = #True
    This\Solid = #True
EndProcedure

Procedure Entity\IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
    
EndProcedure

Procedure Entity\Init()
    
EndProcedure

Procedure Entity\Kill()
    
EndProcedure

Procedure Entity\GetX()
    ProcedureReturn This\X
EndProcedure

Procedure Entity\GetY()
    ProcedureReturn This\Y
EndProcedure

Procedure Entity\SetX(X.l)
    This\X = X
EndProcedure

Procedure Entity\SetY(Y.l)
    This\Y = Y
EndProcedure

Procedure Entity\GetWidth()
    ProcedureReturn This\Width
EndProcedure

Procedure Entity\GetHeight()
    ProcedureReturn This\Height
EndProcedure

Procedure Entity\GetType()
    ProcedureReturn This\Type
EndProcedure

Procedure Entity\GetEntityType()
    ProcedureReturn This\EntityType
EndProcedure

Procedure Entity\IsActive()
    ProcedureReturn This\Active
EndProcedure

Procedure Entity\IsSolid()
    ProcedureReturn This\Solid
EndProcedure

Procedure Entity\CheckTileCollision(X.l, Y.l, *OutTile.Long = #Null)
    Define TileX.l = X / #Tile_Width, TileY.l = Y / #Tile_Height
    
    If TileY < 0
        ProcedureReturn #False
    EndIf
    
    ; If *thisM = This\Game\GetPlayer()
        ; Debug TileX
    ; EndIf
    
    If TileX >= 0 And TileX < This\Map\GetWidth() And TileY < This\Map\GetHeight() ;And TileY >= 0 
        Define *Tile.Tile = This\Map\GetTile(TileX, TileY)

        If *Tile\IsSet
            If *OutTile
                If Not *OutTile\l
                    *OutTile\l = *Tile
                Else
                    Define *Tile1.Tile = *Tile
                    Define *Tile2.Tile = *OutTile\l
                    
                    Define X1.l = *Tile1\X * #Tile_Width
                    Define X2.l = *Tile2\X * #Tile_Width
                    
                    Define Dist1.l = Abs(X1 - X)
                    Define Dist2.l = Abs(X2 - X)
                    
                    If Dist1 < Dist2
                        *OutTile\l = *Tile
                    EndIf
                EndIf
            EndIf

            ProcedureReturn #True
        EndIf
        
        ProcedureReturn #False
    EndIf
    
    ProcedureReturn #True
EndProcedure

Procedure Entity\IsMapCollision(X.l, Y.l, *OutTile.Long = #Null)
    Define RestX.l = X % #Tile_Width
    Define Type.l
    
    If This\CheckTileCollision(X - RestX, Y + This\Height, *OutTile)
        Type = #Collision_BottomLeft
    EndIf
    
    If This\CheckTileCollision(X - RestX, Y, *OutTile)
        Type = #Collision_TopLeft
    EndIf
    
    If X + This\Width > X + #Tile_Width - RestX
        If This\CheckTileCollision(X + #Tile_Width - RestX, Y + This\Height, *OutTile)
            Type = #Collision_BottomRight
        EndIf
        
        If This\CheckTileCollision(X + #Tile_Width - RestX, Y, *OutTile)
            Type = #Collision_TopRight
        EndIf
    EndIf
    
    ProcedureReturn Type
EndProcedure

Procedure Entity\IsEntityCollision(Object.l, X.l, Y.l)
    Define *Entity.sEntity = Object
    
    If Not *Entity\Active Or Not *Entity\Solid
        ProcedureReturn #False
    EndIf
    
    If X + This\Width >= *Entity\X And X <= *Entity\X + *Entity\Width And Y + This\Height >= *Entity\Y And Y <= *Entity\Y + *Entity\Height
        ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
EndProcedure

Procedure Entity\Move(X.f, Y.f, *OutTile.Long = #Null)
    Define.l Result = This\IsMapCollision(This\X + X, This\Y + Y, *OutTile)
    
    If Not Result
        This\X + X
        This\Y + Y
    EndIf
   
    ProcedureReturn Result
EndProcedure

Procedure Entity\RequestRemoval()
    This\DoRemove = #True
EndProcedure

Procedure Entity\ShallBeRemoved()
    ProcedureReturn This\DoRemove
EndProcedure

Procedure Entity_SetAttribute(Type.l, Pointer.l, Value.s)
    Select Type
        Case #Long
            PokeL(Pointer, Val(Value))
            
        Case #String
            PokeL(Pointer, ReAllocateMemory(PeekL(Pointer), Len(Value) + 1))
            PokeS(PeekL(Pointer), Value)
            
        Case #Float
            PokeF(Pointer, ValF(Value))
            
        Default
            Assert(#False, "unknown attribute type")
    EndSelect
EndProcedure

Procedure.s Entity_GetAttribute(Type.l, Pointer.l)
    Select Type
        Case #Long
            ProcedureReturn Str(PeekL(Pointer))
            
        Case #String
            Define Address.l = PeekL(Pointer)
            
            If Not Address
                ProcedureReturn ""
            EndIf
            
            ProcedureReturn PeekS(Address)
            
        Case #Float
            ProcedureReturn StrF(PeekF(Pointer))
            
        Default
            Assert(#False, "unknown attribute type")
    EndSelect
EndProcedure

; Callbacks for Entity\IterateAttributes
Procedure Entity_Attributes_Input(UserDefined.l, Name.s, Description.s, Type.l, Pointer.l)
    Entity_SetAttribute(Type, Pointer, InputRequester("Set attribute: " + Name, Description, Entity_GetAttribute(Type, Pointer)))
EndProcedure

Procedure Entity_Attributes_Save(XMLNode.l, Name.s, Description.s, Type.l, Pointer.l)
    SetXMLAttribute(XMLNode, Name, Entity_GetAttribute(Type, Pointer))
EndProcedure

Procedure Entity_Attributes_Load(XMLNode.l, Name.s, Description.s, Type.l, Pointer.l)
    Entity_SetAttribute(Type, Pointer, GetXMLAttribute(XMLNode, Name))
EndProcedure
;}
;{ Goomba
; Boohoooooooo, why doesn't PureObject allow me to inherit in more than one level? :'(
; I want Entity -> Enemy -> Goomba, but it won't allow me..

Class Goomba Extends Entity

    Goomba(X.l, Y.l)
    
    Force IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
    
    Force Kill()
    
    Update()
    Render()
    
    Sprite.l

    MoveSpeed.f
    
    FallFromBorders.l
    
    DoWalk.l
    Direction.l
    
    KillTime.l
    
    Frame.l
    NextFrame.l
    
EndClass

Procedure Goomba\Goomba(X.l, Y.l)
    This\Entity()
    
    This\Type = #Entity_Enemy
    
    This\DoWalk = #False
    This\Direction = #Direction_Left
    This\FallFromBorders = #True
    
    This\X = X
    This\Y = Y
    This\Width = 10
    This\Height = 8
    This\Sprite = GetSprite("Goomba.bmp")
    This\MoveSpeed = 0.3
EndProcedure

Procedure Goomba\IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
    *Callback(UserDefined, "fall-from-borders", "fall down (1) from borders, or change direction (0)?", #Long, @This\FallFromBorders)
EndProcedure

Procedure Goomba\Kill()
    RenderSound(Goomba)
    
    This\Solid = #False
    This\KillTime = 100
    This\Frame = 2
EndProcedure

Procedure Goomba\Update()
    ;{ Getting killed
    If This\KillTime
        This\KillTime - 1
        
        If This\KillTime = 0
            This\RequestRemoval()
        EndIf
        
        ProcedureReturn
    EndIf
    ;}
    ;{ Walk animation
    This\NextFrame + 1
    
    If This\NextFrame = 25
        This\Frame ! 1
        This\NextFrame = 0
    EndIf
    ;}
    ;{ Check visibility
    If Not This\DoWalk
        Define *Player.Entity = This\Game\GetPlayer()
        
        If Not *Player
            This\DoWalk = #True
        Else
            If Abs(This\X - *Player\GetX()) <= #Screen_Width + This\Width + *Player\GetWidth() And Abs(This\Y - *Player\GetY()) <= #Screen_Height + This\Height + *Player\GetHeight()
                This\DoWalk = #True
            Else
                This\DoWalk = #False
                ProcedureReturn
            EndIf
        EndIf
    EndIf
    
    Define MoveSpeed.f = This\MoveSpeed
    If This\Direction = #Direction_Left : MoveSpeed * -1 : EndIf
    ;}
    ;{ Collision with other enemies
    Define *Entity.Entity
    Define I.l
    
    For I = 0 To This\Entities\GetCount() - 1 
        *Entity = PeekL(This\Entities\Get(I))
        If *Entity = This Or *Entity\GetType() <> #Entity_Enemy : Continue : EndIf
        
        If This\IsEntityCollision(*Entity, This\X + MoveSpeed, This\Y + #Gravity)
            This\Direction ! 1
            
            ProcedureReturn
        EndIf
    Next
    ;}
    ;{ Move
    Define *Tile.Tile
    
    If This\Move(0, #Gravity, @*Tile)
        If This\Move(MoveSpeed, 0)
            This\Direction ! 1
        Else
            ;{ Prevent falling from borders
            If Not This\FallFromBorders And *Tile
                If This\Direction = #Direction_Left And *Tile\X - 1 >= 0 And This\X - *Tile\X * #Tile_Width < This\MoveSpeed + 1
                    Define *LeftTile.Tile = This\Map\GetTile(*Tile\X - 1, *Tile\Y)
                    
                    If Not *LeftTile\IsSet
                        This\Direction ! 1
                    EndIf
                ElseIf This\Direction = #Direction_Right And *Tile\X + 1 < This\Map\GetWidth() - 1 And *Tile\X * #Tile_Width - This\X < This\MoveSpeed + 1
                    Define *RightTile.Tile = This\Map\GetTile(*Tile\X + 1, *Tile\Y)
                    
                    If Not *RightTile\IsSet
                        This\Direction ! 1
                    EndIf
                EndIf
            EndIf
            ;}
        EndIf
    EndIf
    ;}
EndProcedure

Procedure Goomba\Render()
    DMSim_ClipSprite(This\Sprite, This\Frame * 9, 0, 9, 8)
    DMSim_DisplayTransparentSprite(This\Sprite, This\Camera\ConvX(This\X), This\Camera\ConvY(This\Y), 0)
EndProcedure
;}
;{ Bomb
Class Bomb Extends Entity

    Bomb(X.l, Y.l)

    Update()
    Render()
    
    IsExploding()
    
    BombSprite.l
    ExplosionSprite.l
    
    T.l
    Exploding.l
    
EndClass
    
Procedure Bomb\Bomb(X.l, Y.l)
    This\Entity()
    
    This\Type = #Entity_Bomb
    
    This\X = X
    This\Y = Y
    
    This\Width = 5
    This\Height = 5
    
    This\BombSprite = GetSprite("Bomb.bmp")
    This\ExplosionSprite = GetSprite("Explosion.bmp")
    
    This\T = 140
EndProcedure

Procedure Bomb\Update()
    If This\T
        This\T - 1
        
        If Not This\T
            This\Exploding = 30
            
            This\Width = 16
            This\Height = 8
            This\X - 4
            This\Y - 3
        EndIf
    ElseIf This\Exploding
        This\Exploding - 1
        
        If Not This\Exploding
            This\RequestRemoval()
        EndIf
    EndIf
EndProcedure

Procedure Bomb\Render()
    If This\T
        Define Frame.l
        
        If This\T % 10 < 5
            Frame = 1
        EndIf
        
        DMSim_ClipSprite(This\BombSprite, Frame * This\Width, 0, This\Width, This\Height)
        DMSim_DisplayTransparentSprite(This\BombSprite, This\Camera\ConvX(This\X), This\Camera\ConvY(This\Y), 0)
    ElseIf This\Exploding
        If This\Exploding % 5 <= 2
            DMSim_DisplayTransparentSprite(This\ExplosionSprite, This\Camera\ConvX(This\X), This\Camera\ConvY(This\Y), 0)
        EndIf
    EndIf
EndProcedure

Procedure Bomb\IsExploding()
    ProcedureReturn This\Exploding
EndProcedure
;}
;{ Tortoise
Class Tortoise Extends Entity

    Tortoise(X.l, Y.l)
    
    Force Kill()
        
    Update()
    Render()
        
    LeftSprite.l
    RightSprite.l
    
    MoveSpeed.f

    DoWalk.l
    Direction.l
    
    Frame.l
    NextFrame.l
    
EndClass

Procedure Tortoise\Tortoise(X.l, Y.l)
    This\Entity()
    
    This\Type = #Entity_Enemy
    
    This\DoWalk = #False
    This\Direction = #Direction_Left
    
    This\X = X
    This\Y = Y
    This\Width = 8
    This\Height = 12
    This\LeftSprite = GetSprite("LeftTortoise.bmp")
    This\RightSprite = GetSprite("RightTortoise.bmp")
    This\MoveSpeed = 0.3
EndProcedure

Procedure Tortoise\Kill()
    RenderSound(Goomba)
    
    This\Solid = #False
    
    Define *Bomb.Entity = NewObject Bomb(This\X, This\Y + 8)
    This\Game\AddEntity(*Bomb)
    
    This\RequestRemoval()
EndProcedure

Procedure Tortoise\Update()
    ;{ Walk animation
    This\NextFrame + 1
    
    If This\NextFrame = 25
        This\Frame ! 1
        This\NextFrame = 0
    EndIf
    ;}
    ;{ Check visibility
    If Not This\DoWalk
        Define *Player.Entity = This\Game\GetPlayer()
        
        If Not *Player
            This\DoWalk = #True
        Else
            If Abs(This\X - *Player\GetX()) <= #Screen_Width + This\Width + *Player\GetWidth() And Abs(This\Y - *Player\GetY()) <= #Screen_Height + This\Height + *Player\GetHeight()
                This\DoWalk = #True
            Else
                This\DoWalk = #False
                ProcedureReturn
            EndIf
        EndIf
    EndIf
    
    Define MoveSpeed.f = This\MoveSpeed
    If This\Direction = #Direction_Left : MoveSpeed * -1 : EndIf
    ;}
    ;{ Collision with other enemies
    Define *Entity.Entity
    Define I.l
    
    For I = 0 To This\Entities\GetCount() - 1 
        *Entity = PeekL(This\Entities\Get(I))
        If *Entity = This Or *Entity\GetType() <> #Entity_Enemy : Continue : EndIf
        
        If This\IsEntityCollision(*Entity, This\X + MoveSpeed, This\Y + #Gravity)
            This\Direction ! 1
            
            ProcedureReturn
        EndIf
    Next
    ;}
    ;{ Move
    Define *Tile.Tile
    
    If This\Move(0, #Gravity, @*Tile)
        If This\Move(MoveSpeed, 0)
            This\Direction ! 1
        Else
            ;{ Prevent falling from borders
            If *Tile
                If This\Direction = #Direction_Left And *Tile\X - 1 >= 0 And This\X - *Tile\X * #Tile_Width < This\MoveSpeed + 1
                    Define *LeftTile.Tile = This\Map\GetTile(*Tile\X - 1, *Tile\Y)
                    
                    If Not *LeftTile\IsSet
                        This\Direction ! 1
                    EndIf
                ElseIf This\Direction = #Direction_Right And *Tile\X + 1 < This\Map\GetWidth() - 1 And *Tile\X * #Tile_Width - This\X < This\MoveSpeed + 1
                    Define *RightTile.Tile = This\Map\GetTile(*Tile\X + 1, *Tile\Y)
                    
                    If Not *RightTile\IsSet
                        This\Direction ! 1
                    EndIf
                EndIf
            EndIf
            ;}
        EndIf
    EndIf
    ;}
EndProcedure

Procedure Tortoise\Render()
    Define Sprite.l = This\LeftSprite
    If This\Direction = #Direction_Right : Sprite = This\RightSprite : EndIf
    
    DMSim_ClipSprite(Sprite, This\Frame * This\Width, 0, This\Width, This\Height)
    DMSim_DisplayTransparentSprite(Sprite, This\Camera\ConvX(This\X), This\Camera\ConvY(This\Y), 0)
EndProcedure
;}
;{ Fly
Class Fly Extends Entity

    Fly(X.l, Y.l)

    Force Kill()
    
    Update()
    Render()
    
    Sprite.l
    XSpeed.f
    YSpeed.f
    WaitTime.l
    KillTime.l
    Frame.l
    DoWalk.l

EndClass

Procedure Fly\Fly(X.l, Y.l)
    This\Entity()
    
    This\Type = #Entity_Enemy
    
    This\X = X
    This\Y = Y
    
    This\Width = 9
    This\Height = 9
    
    This\Sprite = GetSprite("Fly.bmp")
    This\YSpeed = -1
    This\XSpeed = -1
EndProcedure

Procedure Fly\Kill()
    RenderSound(Goomba) ; TODO: Get a sound for killed flies
    
    This\KillTime = 100
    This\Solid = #False
EndProcedure

Procedure Fly\Update()
    ; I shall be punished for massive code duplication.
    If Not This\DoWalk
        Define *Player.Entity = This\Game\GetPlayer()
        
        If Not *Player
            This\DoWalk = #True
        Else
            If Abs(This\X - *Player\GetX()) <= #Screen_Width + This\Width + *Player\GetWidth() And Abs(This\Y - *Player\GetY()) <= #Screen_Height + This\Height + *Player\GetHeight()
                This\DoWalk = #True
            Else
                This\DoWalk = #False
                ProcedureReturn
            EndIf
        EndIf
    EndIf
    
    If This\WaitTime
        This\WaitTime - 1
        
        If Not This\WaitTime
            This\YSpeed = -1.5
            This\Frame = 1
        EndIf
        
        If This\KillTime : This\WaitTime = 1 : EndIf
    Else
        If This\Move(This\XSpeed, 0)
            This\XSpeed * -1
        EndIf
        
        If This\Move(0, This\YSpeed)
            If This\YSpeed > 0
                This\WaitTime = 50
                This\YSpeed = 1
                This\Frame = 0
            Else
                This\YSpeed = #Gravity
            EndIf
        Else
            This\YSpeed + 0.05
        EndIf
    EndIf
    
    If This\KillTime
        This\KillTime - 1
        This\Frame = 2
        
        If This\KillTime = 0
            This\RequestRemoval()
        EndIf
    EndIf
EndProcedure

Procedure Fly\Render()
    DMSim_ClipSprite(This\Sprite, This\Frame * 13, 0, 13, 10)
    DMSim_DisplayTransparentSprite(This\Sprite, This\Camera\ConvX(This\X), This\Camera\ConvY(This\Y), 0)
EndProcedure
;}
;{ Rocket
Class Rocket Extends Entity

    Rocket(X.l, Y.l)

    Force IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
    Force Init()
    Force Kill()
    
    Update()
    Render()
    
    Direction.l
    Speed.f
    
    Sprite.l
    
    SoundPlayed.l
    
EndClass
    
Procedure Rocket\Rocket(X.l, Y.l)
    This\Entity()
    
    This\Type = #Entity_Enemy
    
    This\X = X
    This\Y = Y
    
    This\Width = 13
    This\Height = 5
    
    This\Direction = #Direction_Left
    This\Speed = 1
EndProcedure

Procedure Rocket\IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
    *Callback(UserDefined, "direction", "direction (0 = left; 1 = right)", #Long, @This\Direction)
    *Callback(UserDefined, "speed", "speed", #Float, @This\Speed)
EndProcedure

Procedure Rocket\Init()
    If This\Direction = #Direction_Left
        This\Sprite = GetSprite("LeftRocket.bmp")
    ElseIf This\Direction = #Direction_Right
        This\Sprite = GetSprite("RightRocket.bmp")
    Else
        Assert(#False)
    EndIf
EndProcedure

Procedure Rocket\Kill()
    This\RequestRemoval()
EndProcedure

Procedure Rocket\Update()
    If Not This\SoundPlayed
        RenderSound(Rocket)
        This\SoundPlayed = #True
    EndIf
    
    Define Speed.f = This\Speed
    
    If This\Direction = #Direction_Left
        Speed * -1
    EndIf
    
    If This\Move(Speed, 0)
        This\RequestRemoval()
    EndIf
EndProcedure

Procedure Rocket\Render() 
    DMSim_DisplayTransparentSprite(This\Sprite, This\Camera\ConvX(This\X), This\Camera\ConvY(This\Y), 0)
EndProcedure
;}
;{ Fireball
Class Fireball Extends Entity

    Fireball(X.l, Y.l)

    Update()
    Render()
    
    Sprite.l
    Counter.l
    
EndClass
    
Procedure Fireball\Fireball(X.l, Y.l)
    This\Entity()
    
    This\X = X
    This\Y = Y
    
    This\Width = 12
    This\Height = 6
    
    This\Sprite = GetSprite("Fireball.bmp")
EndProcedure

Procedure Fireball\Update()
    If This\Move(-0.82, 0)
        This\RequestRemoval()
    EndIf
    
    This\Counter + 1
    
    Define *Player.Entity = This\Game\GetPlayer()
    
    If This\IsEntityCollision(*Player, This\X, This\Y)
        This\Game\PlayerDead()
    EndIf
EndProcedure

Procedure Fireball\Render()
    Define Frame.l = 0
    If This\Counter % 8 > 4 : Frame = 1 : EndIf
    
    DMSim_ClipSprite(This\Sprite, Frame * 12, 0, 12, 6)
    DMSim_DisplayTransparentSprite(This\Sprite, This\Camera\ConvX(This\X), This\Camera\ConvY(This\Y), 0)
EndProcedure
;}
;{ Warp
Class Warp Extends Entity
    
    Warp(X.l, Y.l)
    Release()
        
    Force IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
        
    GetTarget()
    SetTarget(Target.l)
        
    Update()
    Render()
    
    Sprite.l
        
    ; String
    Target.l
    
EndClass
    
Procedure Warp\Warp(X.l, Y.l)
    This\Entity()
    
    This\Type = #Entity_Warp
    
    This\X = X
    This\Y = Y
    
    This\Width = 10
    This\Height = 10
    
    This\Sprite = GetSprite("Warp.bmp")
EndProcedure

Procedure Warp\Release()
    If This\Target
        FreeMemory(This\Target)
    EndIf
EndProcedure

Procedure Warp\IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
    *Callback(UserDefined, "target", "target, can either be a map or 'goal'", #String, @This\Target)
EndProcedure

Procedure Warp\GetTarget()
    ProcedureReturn This\Target
EndProcedure

Procedure Warp\SetTarget(Target.l)
    If This\Target
        FreeMemory(This\Target)
    EndIf
    
    Define Length.l = Len(PeekS(Target)) + 1
    
    This\Target = AllocateMemory(Length)
    CopyMemory(Target, This\Target, Length)
EndProcedure

Procedure Warp\Update()
    
EndProcedure

Procedure Warp\Render()
    DMSim_DisplayTransparentSprite(This\Sprite, This\Camera\ConvX(This\X), This\Camera\ConvY(This\Y), 0)
EndProcedure
;}
;{ Boss
Class Boss Extends Entity

    Boss(X.l, Y.l)

    Update()
    Render()
    
    FuckMe()
    
    Sprite.l
    WaitTime.l
    YSpeed.f
    FireballTime.l
    FireballCount.l
    Life.l
    
EndClass
    
Procedure Boss\Boss(X.l, Y.l)
    This\Entity()
    
    This\Type = #Entity_Boss
    
    This\X = X
    This\Y = Y
    
    This\Width = 32
    This\Height = 25
    
    This\Sprite = GetSprite("Boss.bmp")
    This\WaitTime = 100
    This\YSpeed = 1
    This\FireballTime = 150
    This\FireballCount = This\FireballTime
    This\Life = 10
EndProcedure

Procedure Boss\Update()
    If This\Move(0, This\YSpeed)
        If This\WaitTime = -1
            This\WaitTime = 30
        ElseIf Not This\WaitTime
            This\YSpeed = -1
            This\WaitTime = -1
        Else
            This\WaitTime - 1
        EndIf
    Else
        This\YSpeed + 0.015
    EndIf
    
    This\FireballCount - 1
    
    If Not This\FireballCount
        Define *Fireball.Entity = NewObject Fireball(This\X - 5, This\Y + 12)
        RenderSound(Ball)
        This\Game\AddEntity(*Fireball)
        This\FireballCount = This\FireballTime
    EndIf
EndProcedure

Procedure Boss\Render()
    Define Frame.l
    
    If This\WaitTime <> -1 : Frame = 1 : EndIf
    
    DMSim_ClipSprite(This\Sprite, Frame * 32, 0, 32, 25)
    DMSim_DisplayTransparentSprite(This\Sprite, This\Camera\ConvX(This\X), This\Camera\ConvY(This\Y), 0)
EndProcedure

Procedure Boss\FuckMe()
    This\Life - 1
    
    If This\Life = 0
        Define *Warp.Warp = NewObject Warp(This\X, This\Y)
        *Warp\SetTarget(@"goal")
        
        This\Game\AddEntity(*Warp)
        While Not *Warp\Move(0, 1) : Wend
        
        This\RequestRemoval()
    Else
        This\FireballTime * 0.87
        
        If This\Life = 8
            Define *Goomba.Entity = NewObject Goomba(This\X - 5, This\Y)
            This\Game\AddEntity(*Goomba)
            
            *Goomba = NewObject Goomba(This\X + 10, This\Y)
            This\Game\AddEntity(*Goomba)
            
            *Goomba = NewObject Goomba(This\X + 25, This\Y)
            This\Game\AddEntity(*Goomba)
        ElseIf This\Life = 5
            Define *Fly.Entity = NewObject Fly(This\X - 5, This\Y)
            This\Game\AddEntity(*Fly)
            
            *Fly.Entity = NewObject Fly(This\X + 10, This\Y)
            This\Game\AddEntity(*Fly)
        EndIf
    EndIf
EndProcedure
;}
;{ Shoot
Class Shoot Extends Entity

    Shoot(X.l, Y.l, SpeedX.l, SpeedY.l)
    
    Update()
    Render()
    
    SpeedX.l
    SpeedY.l
    
    Age.l
    
    Sprite.l

EndClass
    
Procedure Shoot\Shoot(X.l, Y.l, SpeedX.l, SpeedY.l)
    This\Entity()
    
    This\Type = #Entity_Shoot
    
    This\SpeedX = SpeedX
    This\SpeedY = SpeedY

    This\X = X
    This\Y = Y
    
    This\Width = 5
    This\Height = 5
    
    This\Sprite = GetSprite("Shoot.bmp")
EndProcedure

Procedure Shoot\Update()
    This\Age + 1
    If This\Age = 500 : This\RequestRemoval() : ProcedureReturn : EndIf
    
    Define *Player.Entity = This\Game\GetPlayer()
    
    If Abs(*Player\GetX() - This\X) > (#Screen_Width / 2) * 1.3 And Abs(*Player\GetY() - This\Y) > ( #Screen_Height / 2) * 1.3
        This\RequestRemoval()
        ProcedureReturn
    EndIf
    
    If This\Move(This\SpeedX, 0)
        This\SpeedX * -1
    EndIf
    
    If This\Move(0, This\SpeedY)
        This\SpeedY * -1
    EndIf
    
    Define *Entity.Entity
    Define I.l
    
    For I = 0 To This\Entities\GetCount() - 1 
        *Entity = PeekL(This\Entities\Get(I))
        
        Select *Entity\GetType()
            Case #Entity_Enemy
                If This\IsEntityCollision(*Entity, This\X, This\Y)
                    This\RequestRemoval()
                    *Entity\Kill()
                    
                    ProcedureReturn
                EndIf
                
            Case #Entity_Coin
                If This\IsEntityCollision(*Entity, This\X, This\Y)
                    RenderSound(Coin)
                    This\Game\AddCoin()
                    *Entity\RequestRemoval()
                    
                    ProcedureReturn
                EndIf
                
            Case #Entity_Boss
                If This\IsEntityCollision(*Entity, This\X, This\Y)
                    ; RenderSound(Coin)
                    RenderSound(Bumm)
                    
                    Define *Boss.Boss = *Entity
                    *Boss\FuckMe()
                    This\RequestRemoval()
                    
                    ProcedureReturn
                EndIf
        EndSelect
    Next
EndProcedure

Procedure Shoot\Render()
    Define X.l = This\Camera\ConvX(This\X), Y.l = This\Camera\ConvY(This\Y)
    
    ; DMSim_Ellipse(X, Y, X + This\Width, Y + This\Height, 4)
    DMSim_DisplayTransparentSprite(This\Sprite, X, Y, 0)
EndProcedure
;}
;{ Save point
Class SavePoint Extends Entity
    
    SavePoint(X.l, Y.l)

    Update()
    Render()
    
    IsActivated()
    Activate()
    
    Activated.l
    Sprite.l
    
EndClass
    
Procedure SavePoint\SavePoint(X.l, Y.l)
    This\Type = #Entity_SavePoint
    
    This\X = X
    This\Y = Y
    
    This\Width = 10
    This\Height = 10
    
    This\Activated = #False
    This\Sprite = GetSprite("SavePoint_Deactivated.bmp")
EndProcedure

Procedure SavePoint\Update()
    
EndProcedure

Procedure SavePoint\Render()
    DMSim_DisplayTransparentSprite(This\Sprite, This\Camera\ConvX(This\X), This\Camera\ConvY(This\Y), 0)
EndProcedure

Procedure SavePoint\IsActivated()
    ProcedureReturn This\Activated
EndProcedure

Procedure SavePoint\Activate()
    This\Activated = #True
    This\Sprite = GetSprite("SavePoint_Activated.bmp")
EndProcedure
;}
;{ Platform
Class Platform Extends Entity
    
    Platform(X.l, Y.l)

    Force IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
    Force Init()
    
    Update()
    Render()
    
    Sprite.l

    Origin.l
    
    Range.l
    Direction.l
    Wait.l
    Speed.f
    
    WaitLeft.l
    
EndClass
    
Procedure Platform\Platform(X.l, Y.l)
    This\Entity()
    
    This\Type = #Entity_Platform
    
    This\X = X
    This\Y = Y
    
    This\Width = 20
    This\Height = 3
    
    This\Sprite = GetSprite("Platform.bmp")
    
    ; Standard attributes
    This\Range = 100
    This\Direction = #Direction_Right
    This\Wait = 30
    This\Speed = 1
EndProcedure

Procedure Platform\IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
    *Callback(UserDefined, "range", "range", #Long, @This\Range)
    *Callback(UserDefined, "direction", "initial direction (0 = left; 1 = right; 2 = up; 3 = down)", #Long, @This\Direction)
    *Callback(UserDefined, "wait", "wait time", #Long, @This\Wait)
    *Callback(UserDefined, "speed", "movement speed (floats are valid)", #Float, @This\Speed)
    *Callback(UserDefined, "start-delay", "initial wait", #Long, @This\WaitLeft)
EndProcedure

Procedure Platform\Init()
    If This\Direction = #Direction_Left Or This\Direction = #Direction_Right
        This\Origin = This\X
    Else
        This\Origin = This\Y
    EndIf
    
    If This\Direction = #Direction_Left Or This\Direction = #Direction_Up
        This\Origin - This\Range
    EndIf
EndProcedure

Procedure Platform\Update()
    If This\WaitLeft : This\WaitLeft - 1 : EndIf
    
    If Not This\WaitLeft
        If This\Direction = #Direction_Right
            This\X + This\Speed
            
            If This\X >= This\Origin + This\Range
                This\Direction = #Direction_Left
                This\WaitLeft = This\Wait
            EndIf
        ElseIf This\Direction = #Direction_Left
            This\X - This\Speed
            
            If This\X <= This\Origin
                This\Direction = #Direction_Right
                This\WaitLeft = This\Wait
            EndIf
        ElseIf This\Direction = #Direction_Down
            This\Y + This\Speed
            
            If This\Y >= This\Origin + This\Range
                This\Direction = #Direction_Up
                This\WaitLeft = This\Wait
            EndIf
        ElseIf This\Direction = #Direction_Up
            This\Y - This\Speed
            
            If This\Y <= This\Origin
                This\Direction = #Direction_Down
                This\WaitLeft = This\Wait
            EndIf
        EndIf
    EndIf
EndProcedure

Procedure Platform\Render()
    DMSim_DisplaySprite(This\Sprite, This\Camera\ConvX(This\X), This\Camera\ConvY(This\Y))
EndProcedure
;}
;{ Power up
Enumeration
    #PowerUp_Mushroom
    #PowerUp_Heart
    #PowerUp_Flower
EndEnumeration

Class PowerUp Extends Entity

    PowerUp(PowerUpType.l)

    Update()
    Render()
  
    GetPowerUpType()
    
    Sprite.l
    
    PowerUpType.l
    
    XSpeed.f
    YSpeed.f
    
EndClass
    
Procedure PowerUp\PowerUp(PowerUpType.l)
    This\Entity()
    
    This\Type = #Entity_PowerUp
    
    This\PowerUpType = PowerUpType
    
    This\XSpeed = 0.2
    This\YSpeed = -0.3
EndProcedure

Procedure PowerUp\Update()
    If Not This\Move(0, This\YSpeed)
        This\YSpeed + 0.007
    EndIf
    
    If This\Move(This\XSpeed, 0)
        This\XSpeed * -1
    EndIf
EndProcedure

Procedure PowerUp\Render()
    If This\Sprite
        DMSim_ClipSprite(This\Sprite, 0, 0, This\Width, This\Height)
        DMSim_DisplayTransparentSprite(This\Sprite, This\Camera\ConvX(This\X), This\Camera\ConvY(This\Y), 0)
    EndIf
EndProcedure

Procedure PowerUp\GetPowerUpType()
    ProcedureReturn This\PowerUpType
EndProcedure

Procedure ConstructMushroom(X.l, Y.l)
    Define *Result.sPowerUp = NewObject PowerUp(#PowerUp_Mushroom)
    
    With *Result
        \X = X
        \Y = Y
        \Width = 8
        \Height = 8
        \Sprite = GetSprite("Mushroom.bmp")
    EndWith
    
    ProcedureReturn *Result
EndProcedure

Procedure ConstructHeart(X.l, Y.l)
    Define *Result.sPowerUp = NewObject PowerUp(#PowerUp_Heart)
    
    With *Result
        \X = X
        \Y = Y
        \Width = 9
        \Height = 8
        \Sprite = GetSprite("Heart.bmp")
    EndWith
    
    ProcedureReturn *Result
EndProcedure

Procedure ConstructFlower(X.l, Y.l)
    Define *Result.sPowerUp = NewObject PowerUp(#PowerUp_Flower)
    
    With *Result
        \X = X
        \Y = Y
        \Width = 8
        \Height = 10
        \Sprite = GetSprite("Flower.bmp")
    EndWith
    
    ProcedureReturn *Result
EndProcedure
;}
;{ Coin
Class Coin Extends Entity

    Coin(X.l, Y.l)

    Update()
    Render()
  
    Sprite.l
    
EndClass
    
Procedure Coin\Coin(X.l, Y.l)
    This\Entity()
    
    This\Type = #Entity_Coin
    This\X = X
    This\Y = Y
    This\Width = 10
    This\Height = 10
    
    This\Sprite = GetSprite("Coin.bmp")
EndProcedure

Procedure Coin\Update()
    
EndProcedure

Procedure Coin\Render()
    DMSim_DisplayTransparentSprite(This\Sprite, This\Camera\ConvX(This\X), This\Camera\ConvY(This\Y), 0)
EndProcedure
;}
;{ Coin blink
Class CoinBlink Extends Entity

    CoinBlink(X.l, Y.l)

    Update()
    Render()
    
    Frame.l
    NextFrame.l
    
    Lifetime.l

    Sprite.l
    
EndClass
    
Procedure CoinBlink\CoinBlink(X.l, Y.l)
    This\Entity()
    
    This\Type = #Entity_CoinBlink
    
    This\X = X
    This\Y = Y
    This\Solid = #False
    
    This\Lifetime = 17
    This\Sprite = GetSprite("CoinBlink.bmp")
EndProcedure

Procedure CoinBlink\Update()
    This\Y - 1
    
    ; TODO: Animation class?
    This\NextFrame + 1
    If This\NextFrame = 5
        This\Frame + 1
        
        If This\Frame = 2
            This\Frame = 0
        EndIf
        
        This\NextFrame = 0
    EndIf
    
    This\Lifetime - 1
    
    If This\Lifetime = 0
        This\RequestRemoval()
    EndIf
EndProcedure

Procedure CoinBlink\Render()
    DMSim_ClipSprite(This\Sprite, This\Frame * 8, 0, 8, 8)
    DMSim_DisplayTransparentSprite(This\Sprite, This\Camera\ConvX(This\X), This\Camera\ConvY(This\Y), 0)
EndProcedure
;}
;{ Spawner
Class Spawner Extends Entity
    
    Spawner(X.l, Y.l)
    Release()
    
    Force IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)

    Update()
    Render()
    
    ; The spawned entity (string)
    TypeEntity.l
    
    ; Offset for the spawned objects
    OffsetX.l
    OffsetY.l
    
    ; Interval
    Interval.l
    NextSpawn.l
    
    ; Prototype for the spawned entities
    *PrototypeEntity.Entity
    
EndClass
    
Procedure Spawner\Spawner(X.l, Y.l)
    This\Entity()
    
    This\Type = #Entity_Spawner
    
    This\X = X
    This\Y = Y
    
    This\Width = #Tile_Width / 2
    This\Height = #Tile_Height / 2
    
    This\Solid = #False
EndProcedure

Procedure Spawner\Release()
    ; DeleteObject doesn't work
    FreeMemory(This\PrototypeEntity)
    
    If This\TypeEntity
        FreeMemory(This\TypeEntity)
    EndIf
EndProcedure

Procedure Spawner\IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
    *Callback(UserDefined, "entity-type", "entity type", #String, @This\TypeEntity)
    *Callback(UserDefined, "interval", "interval", #Long, @This\Interval)
    *Callback(UserDefined, "start-delay", "intial wait", #Long, @This\NextSpawn)
    *Callback(UserDefined, "offset-x", "X offset", #Long, @This\OffsetX)
    *Callback(UserDefined, "offset-y", "Y offset", #Long, @This\OffsetY)

    Define IsNew.l = #False
    
    If Not This\PrototypeEntity
        Define Foo.s = PeekS(This\TypeEntity)
        Define *EntityType.EntityType = This\Game\GetEntityType(Foo)
        This\PrototypeEntity = *EntityType\Constructor(42, 42)
        IsNew = #True
    EndIf
    
    This\PrototypeEntity\IterateAttributes(UserDefined, *Callback)
    
    If IsNew
        This\PrototypeEntity\Init()
    EndIf
EndProcedure

Procedure Spawner\Update()
    This\NextSpawn - 1
    
    If This\NextSpawn = -1
        Define *Player.Entity = This\Game\GetPlayer()
        
        If Abs(This\X - *Player\GetX()) < #Screen_Width And Abs(This\Y - *Player\GetY()) < #Screen_Height
            ; Clone our prototype! (in a hackish way, but who cares)
            Define *EntityMemory.Entity = AllocateMemory(MemorySize(This\PrototypeEntity))
            CopyMemory(This\PrototypeEntity, *EntityMemory, MemorySize(This\PrototypeEntity))
            
            *EntityMemory\SetX(This\X + This\OffsetX)
            *EntityMemory\SetY(This\Y + This\OffsetY)
            
            This\Game\AddEntity(*EntityMemory)
        EndIf
        
        This\NextSpawn = This\Interval
    EndIf
EndProcedure

Procedure Spawner\Render()
    
EndProcedure
;}
;{ Killer
Class Killer Extends Entity

    Killer(X.l, Y.l)
    
    Update()
    Render()

EndClass
    
Procedure Killer\Killer(X.l, Y.l)
    This\Entity()
    
    This\Type = #Entity_Killer
    
    This\X = X
    This\Y = Y
    This\Width = #Tile_Width
    This\Height = #Tile_Height
EndProcedure

Procedure Killer\Update()
    
EndProcedure

Procedure Killer\Render()
    
EndProcedure
;}
;{ Player
#Player_Min_XSpeed = 1.0
#Player_Max_XSpeed = 2  .0
#Player_XSpeed_Accel = 0.043
#Player_YSpeed_Accel = 0.23
#Player_Max_YSpeed = 5.0
#Player_Jump_Speed = 1.5

Class Player Extends Entity

    _SetBig(Big.l)

    Player(X.l, Y.l)
    
    Update()
    Render()
    
    OnRespawn()
    CheckDead()
    
    SpriteRight.l
    SpriteLeft.l
    
    ; SmallSprite.l
    ; BigSprite.l
    
    IsBig.l
    
    HasShot.l
    LastShot.l
    CanShoot.l
    
    YSpeed.f
    XSpeed.f
    
    Direction.l
    
    HasJumped.l
    MayJump.l
    AddJumpSpeed.f
    JumpKey.l
    
    Invincible.l
    RenderMod.l
    
    *Attached.Entity
    AttachedOldX.l
    AttachedDistanceX.l
    AttachedOldY.l
    AttachedDistanceY.l

    ; Animation
    Frame.l
    FrameWidth.l
    NextWalkFrame.l
    NumberWalkFrames.l
    
EndClass

Procedure Player\_SetBig(Big.l)
    This\IsBig = Big
    
    If Big
        Assert(#False)
        
        This\Width = 9
        This\Height = 10
        ; This\Sprite = This\BigSprite
    Else
        This\Width = 9
        This\Height = 9
        This\SpriteRight = GetSprite("RightPlayer.bmp")
        This\SpriteLeft = GetSprite("LeftPlayer.bmp")
    EndIf
EndProcedure

Procedure Player\Player(X.l, Y.l)
    This\Entity()

    This\Type = #Entity_Player
    
    This\X = X
    This\Y = Y

    ; This\SmallSprite = GetSprite("Player.bmp")
    ; This\BigSprite = GetSprite("BigPlayer.bmp")
    
    This\_SetBig(#False)
    
    This\Direction = #Direction_Right
    
    This\Frame = 0
    This\FrameWidth = 10
    This\NumberWalkFrames = 3
    
    This\YSpeed = #Gravity
    This\XSpeed = 0
EndProcedure

Procedure Player\Update()
    ;{ Movement
    Define DidMove.l
    
    If DMSim_KeyPushed(#DMSIM_KEY_RIGHT)
        If This\HasJumped
            If This\XSpeed < 0.1
                This\XSpeed = 1
            ElseIf This\XSpeed > 0 And This\Direction = #Direction_Left
                This\XSpeed * 0.43
            EndIf
            
            This\Direction = #Direction_Right
        Else
            This\Direction = #Direction_Right
            
            If This\XSpeed < #Player_Min_XSpeed And Not This\HasJumped
                This\XSpeed = #Player_Min_XSpeed + 0.01
            EndIf
        EndIf
    EndIf
    
    If DMSim_KeyPushed(#DMSIM_KEY_LEFT)
        If This\HasJumped
            If This\XSpeed < 0.1
                This\XSpeed = 1
            ElseIf This\XSpeed > 0 And This\Direction = #Direction_Right
                This\XSpeed * 0.43
            EndIf
            
            This\Direction = #Direction_Left
        Else
            This\Direction = #Direction_Left
            
            If This\XSpeed < #Player_Min_XSpeed And Not This\HasJumped
                This\XSpeed = #Player_Min_XSpeed + 0.01
            EndIf
        EndIf
    EndIf

    If This\XSpeed > 0
        Define Speed.f = This\XSpeed
        If This\Direction = #Direction_Left : Speed * -1 : EndIf
        
        If Not This\Move(Speed, 0)
            ; Debug "move: " + StrF(This\XSpeed)
            
            DidMove = #True
        EndIf
    EndIf
    
    ;{ Animation
    If DidMove And Not This\HasJumped
        This\NextWalkFrame + 1
        
        ; Reset from jumping/standing
        If This\Frame = 3 Or This\Frame = 4 : This\Frame = 0 : EndIf
        
        If This\NextWalkFrame >= 6 / (This\XSpeed + 0.01)
            Assert(This\Frame < This\NumberWalkFrames)
            
            This\Frame + 1
            
            If This\Frame = This\NumberWalkFrames
                This\Frame = 0
            EndIf
            
            Assert(This\Frame < This\NumberWalkFrames)
            
            This\NextWalkFrame = 0
        EndIf
    ElseIf This\HasJumped
        This\Frame = 3
    ElseIf Not DidMove
        This\Frame = 4
    EndIf
    ;}
    ;{ Deaccelerate
    If ((Not DMSim_KeyPushed(#DMSIM_KEY_LEFT) And Not DMSim_KeyPushed(#DMSIM_KEY_RIGHT)) Or Not DidMove Or Not DMSim_KeyPushed(#DMSIM_KEY_B)) And Not This\HasJumped
        If This\XSpeed > 0
            This\XSpeed - #Player_XSpeed_Accel * 5
            
            If This\XSpeed <= 0 : This\XSpeed = 0 : EndIf
            
            ; Debug "deaccel: " + StrF(This\XSpeed)
        EndIf
    EndIf
    ;}
    
    If This\Invincible : This\Invincible - 1 : EndIf
    
    ; Apply down speed (gravity)
    Define *Tile.Tile
    Define *TileType.TileType
    
    Define CollisionType.l = This\IsMapCollision(This\X, This\Y + This\YSpeed, @*Tile)
    
    ;}
    ;{ Shooting
    If This\LastShot : This\LastShot - 1 : EndIf
    
    If This\CanShoot And DMSim_KeyPushed(#DMSIM_KEY_B)
        If Not This\HasShot And Not This\LastShot
            RenderSound(Fireball)
            
            Define XSpeed.l = This\XSpeed + 1
            If This\Direction = #Direction_Left : XSpeed * -1 : EndIf
            
            Define *Shoot.Shoot = NewObject Shoot(This\X, This\Y, XSpeed, 1)
            This\Game\AddEntity(*Shoot)
            This\HasShot = #True
            This\LastShot = 50
        EndIf
    Else
        This\HasShot = #False
    EndIf
    ;}
    ;{ Platform attachement
    If This\Attached ;And Not CollisionType
        Define SpeedX.f = This\Attached\GetX() - This\AttachedOldX
        Define NewX.f = This\Attached\GetX() + This\AttachedDistanceX + SpeedX
        Define SpeedY.f = This\Attached\GetY() - This\AttachedOldY
        Define NewY.f = This\Attached\GetY() + This\AttachedDistanceY + SpeedY
        
        ; Move with the platform, check for map collisions though
        If This\Attached\GetX() <> This\AttachedOldX And Not This\IsMapCollision(NewX, This\Y, *Tile)
            This\X = NewX
            This\AddJumpSpeed = 0.5
        EndIf
        
        If This\Attached\GetY() <> This\AttachedOldY And Not This\IsMapCollision(This\Y, NewY, *Tile)
            This\Y = NewY
            This\AddJumpSpeed = 0.5
        EndIf
        
        This\Attached = #Null
    EndIf
    ;}
    ;{ Entity collision
    Define *Entity.Entity
    Define I.l
    
    ; Iterate through all entities and check for collision
    For I = 0 To This\Entities\GetCount() - 1 
        *Entity = PeekL(This\Entities\Get(I))
        If *Entity = This : Continue : EndIf
 
        If This\IsEntityCollision(*Entity, This\X, This\Y)
            Select *Entity\GetType()
                Case #Entity_Enemy ;{
                    ; Check if the player hopped on the enemy
                    If Not CollisionType And This\YSpeed > 0 And This\Y + This\Height - 2 < *Entity\GetY() + *Entity\GetHeight() And *Entity\IsSolid()
                        This\YSpeed = -2
                        *Entity\Kill()
                    ElseIf Not This\Invincible
                        This\Game\PlayerDead()
                    EndIf
                ;}
                Case #Entity_SavePoint ;{
                    Define *SavePoint.SavePoint = *Entity
                    
                    If Not *SavePoint\IsActivated()
                        *SavePoint\Activate()
                        This\Game\PlayerHitSavePoint(*SavePoint\GetX(), *SavePoint\GetY())
                    EndIf
                ;}
                Case #Entity_Platform ;{
                    If This\Y + This\Height / 2 <= *Entity\GetY() And This\X + This\Width > *Entity\GetX() And This\YSpeed > 0
                        Define NewY.f = *Entity\GetY() - This\Height - 1
                        
                        If Not This\IsMapCollision(This\X, NewY)
                            This\Y = NewY
                            CollisionType = #Collision_BottomRight
                            
                            This\Attached = *Entity
                            This\AttachedOldX = *Entity\GetX()
                            This\AttachedDistanceX = This\X - *Entity\GetX()
                            This\AttachedOldY = *Entity\GetY()
                            This\AttachedDistanceY = This\Y - *Entity\GetY()
                        EndIf
                    EndIf
                ;}
                Case #Entity_Warp ;{
                    Define *Warp.Warp = *Entity
                    Define Target.s = PeekS(*Warp\GetTarget())
                    This\Game\PlayerHitWarp(@Target)
                    
                    ProcedureReturn
                ;}
                Case #Entity_Coin ;{
                    RenderSound(Coin)
                    
                    This\Game\AddCoin()
                    *Entity\RequestRemoval()
                ;}
                Case #Entity_PowerUp ;{
                    Define *PowerUp.PowerUp = *Entity
                    
                    Select *PowerUp\GetPowerUpType()
                        Case #PowerUp_Mushroom ;{
                            Define OldWidth.l = This\Width
                            Define OldHeight.l = This\Height
                            
                            ; This\_SetBig(#True)
                            ; 
                            ; If This\Move(0, -This\Height + OldHeight)
                                ; This\_SetBig(#False)
                            ; Else
                                ; 
                            ; EndIf
                        ;}
                        Case #PowerUp_Heart
                            RenderSound(Up)
                            
                            This\Game\AddLife()
                            
                        Case #PowerUp_Flower
                            RenderSound(Up)
                            
                            This\CanShoot = #True
                    EndSelect
                    
                    *PowerUp\RequestRemoval()
                ;}
                Case #Entity_Killer ;{
                    This\Game\PlayerDead()
                ;}
                Case #Entity_Boss ;{
                    This\Game\PlayerDead()
                ;}
                Case #Entity_Bomb ;{
                    Define *Bomb.Bomb = *Entity
                    
                    If *Bomb\IsExploding()
                        This\Game\PlayerDead()
                    EndIf
                ;}
            EndSelect
        EndIf
    Next
    ;}
    ;{ Tile type callbacks
    If *Tile : *TileType = *Tile\Type : EndIf
    
    If *TileType
        If *TileType\OnHit
            *TileType\OnHit(*Tile, This\Game)
        EndIf
        
        If (CollisionType = #Collision_TopLeft Or CollisionType = #Collision_TopRight) And *TileType\OnBottomHit
            *TileType\OnBottomHit(*Tile, This\Game)
        EndIf
        
        If (CollisionType = #Collision_BottomLeft Or CollisionType = #Collision_BottomRight) And *TileType\OnTopHit
            *TileType\OnTopHit(*Tile, This\Game)
        EndIf
    EndIf
    ;}
    ;{ Gravity/Jumping  
    ; No collision, if applying the down force?
    If Not CollisionType
        This\Y + This\YSpeed
        
        ; Increase the down force while falling
        If This\YSpeed < #Player_Max_YSpeed
            This\YSpeed + #Player_YSpeed_Accel
        EndIf
        
        ; Jump higher while jumping
        If This\MayJump And This\YSpeed > -4 And DMSim_KeyPushed(#DMSIM_KEY_A)
            This\YSpeed - #Player_YSpeed_Accel
            This\MayJump - 1
        EndIf
    
    ; Collided with a tile which is under the player
    ElseIf CollisionType = #Collision_BottomLeft Or CollisionType = #Collision_BottomRight
        ; Jumping
        If DMSim_KeyPushed(#DMSIM_KEY_A) And Not This\HasJumped
            If Not This\JumpKey
                RenderSound(Jump)
                
                This\YSpeed = -#Player_Jump_Speed
                
                ; Jump higher when moving fast
                If This\XSpeed > 1
                    This\YSpeed - This\XSpeed * 0.4
                EndIf
                
                ; Also apply additional jump speed (for example when moving on a platform)
                If This\AddJumpSpeed
                    This\YSpeed - This\AddJumpSpeed
                    This\AddJumpSpeed = 0
                EndIf
                
                ; Allow to accelerate the jump while jumping (hold the jump key)
                This\MayJump = 17
                
                This\HasJumped = #True
                This\JumpKey = #True
            EndIf
        Else
            This\HasJumped = #False
            This\YSpeed = #Gravity ; Reset the down force to normal after landing
            
            HaltSound(Jump)
        EndIf
        
        If Not DMSim_KeyPushed(#DMSIM_KEY_A) : This\JumpKey = #False : EndIf
        
        ; Accelerate
        If (DMSim_KeyPushed(#DMSIM_KEY_LEFT) Or DMSim_KeyPushed(#DMSIM_KEY_RIGHT)) And DMSim_KeyPushed(#DMSIM_KEY_B) And DidMove And This\XSpeed >= #Player_Min_XSpeed And This\XSpeed < #Player_Max_XSpeed
            This\XSpeed + #Player_XSpeed_Accel
            
            ; Debug "accel: " + StrF(This\XSpeed)
        EndIf
        
    ; Collided with a tile above the player
    Else
        This\YSpeed = #Gravity
        This\MayJump = #False
    EndIf
    ;}
    ;{ Camera update
    This\Camera\SetX(This\X - #Screen_Width / 2)
    This\Camera\SetY(This\Y - #Screen_Height / 2)
    ;}
EndProcedure

Procedure Player\Render()
    If This\Invincible And This\Invincible % 5 = 0
        This\RenderMod ! 1
        This\Invincible - 1
    EndIf
    
    If This\Invincible = 0 : This\RenderMod = #False : EndIf
    If This\RenderMod : ProcedureReturn : EndIf
    
    Define Sprite.l
    
    If This\Direction = #Direction_Left
        Sprite = This\SpriteLeft
    ElseIf This\Direction = #Direction_Right
        Sprite = This\SpriteRight
    EndIf
     
    DMSim_ClipSprite(Sprite, This\Frame * This\FrameWidth, 0, This\FrameWidth, 11)
    DMSim_DisplayTransparentSprite(Sprite, This\Camera\ConvX(This\X), This\Camera\ConvY(This\Y), 0)
EndProcedure

Procedure Player\OnRespawn()
    This\Invincible = 125
    This\YSpeed = #Gravity
    This\XSpeed = 1
    This\Attached = #Null
    This\AddJumpSpeed = 0
    This\MayJump = 0
    This\HasJumped = #False
    This\LastShot = 0
    This\CanShoot = #False
    This\_SetBig(#False)
EndProcedure

Procedure Player\CheckDead()
    ProcedureReturn #True
    
    If Not This\CanShoot
        ProcedureReturn #True
    EndIf
    
    ; This\_SetBig(#False)
    This\CanShoot = #False
    This\Invincible = 100
    
    ProcedureReturn #False
EndProcedure
;}
;{ Tile types
Procedure TopPrickle_OnTopHit(*Tile.Tile, *Game.GameInterface)
    Define *Map.Map = *Game\GetMap()
    Define *Player.Entity = *Game\GetPlayer()
    
    Define *Tile1.Tile
    Define *TileType.TileType
    
    If *Tile\X > 0
        *Tile1 = *Map\GetTile(*Tile\X - 1, *Tile\Y)
        *TileType = *Tile1\Type
        
        If *Tile1\IsSet And *TileType\OnTopHit <> @TopPrickle_OnTopHit()
            If *Player\GetX() <= (*Tile\X - 1) * #Tile_Width + #Tile_Width / 2 + 1
                ProcedureReturn
            EndIf
        EndIf
    EndIf
    
    If *Tile\X < *Map\GetWidth() - 1
        *Tile1 = *Map\GetTile(*Tile\X + 1, *Tile\Y)
        *TileType = *Tile1\Type
        
        If *Tile1\IsSet And *TileType\OnTopHit <> @TopPrickle_OnTopHit() 
            If *Player\GetX() + *Player\GetWidth() >= (((*Tile\X + 1) * #Tile_Width))
                ProcedureReturn
            EndIf
        EndIf
    EndIf
    
    *Game\PlayerDead()
EndProcedure

Procedure BottomPrickle_OnBottomHit(*Tile.Tile, *Game.GameInterface)
    *Game\PlayerDead()
EndProcedure

Procedure MushroomSpawner_OnBottomHit(*Tile.Tile, *Game.GameInterface)
    *Game\AddEntity(ConstructMushroom(*Tile\X * #Tile_Width, *Tile\Y * #Tile_Height - 15))
    
    Define *Map.Map = *Game\GetMap()
    *Tile\Type = *Map\GetTileType("black")
EndProcedure

Procedure KillEnemiesAboveTile(*Tile.Tile, *Game.GameInterface)
    Define *Entities.Array = *Game\GetEntities()
    Define I.l
    
    For I = 0 To *Entities\GetCount() - 1
        Define *Entity.Entity
        
        *Entity = PeekL(*Entities\Get(I))
        
        If *Entity\GetType() = #Entity_Enemy And *Entity\GetX() + *Entity\GetWidth() >= *Tile\X * #Tile_Width And *Entity\GetX() <= *Tile\X * #Tile_Width + #Tile_Width And *Entity\GetY() <= *Tile\Y * #Tile_Height And *Entity\GetY() + *Entity\GetHeight() >= *Tile\Y * #Tile_Height - 5
            *Entity\Kill()
        EndIf
    Next
EndProcedure

Procedure HeartSpawner_OnBottomHit(*Tile.Tile, *Game.GameInterface)
    RenderSound(PickUp)
    
    *Game\AddEntity(ConstructHeart(*Tile\X * #Tile_Width, *Tile\Y * #Tile_Height - 10))
    
    Define *Map.Map = *Game\GetMap()
    *Tile\Type = *Map\GetTileType("black")
    
    KillEnemiesAboveTile(*Tile, *Game)
EndProcedure

Procedure FlowerSpawner_OnBottomHit(*Tile.Tile, *Game.GameInterface)
    RenderSound(PickUp)
    
    *Game\AddEntity(ConstructFlower(*Tile\X * #Tile_Width, *Tile\Y * #Tile_Height - 11))
    
    Define *Map.Map = *Game\GetMap()
    *Tile\Type = *Map\GetTileType("black")
EndProcedure

Procedure CoinSpawner_OnBottomHit(*Tile.Tile, *Game.GameInterface)
    RenderSound(Coin)
    
    *Game\AddEntity(ConstructCoinBlink(*Tile\X * #Tile_Width + #Tile_Width - 8,  *Tile\Y * #Tile_Height - 15))
    *Game\AddCoin()
    
    Define *Map.Map = *Game\GetMap()
    *Tile\Type = *Map\GetTileType("black")
    
    KillEnemiesAboveTile(*Tile, *Game)
EndProcedure

Procedure Black_OnBottomHit(*Tile.Tile, *Game.GameInterface)
    RenderSound(Block)
EndProcedure

Procedure Blob_OnBottomHit(*Tile.Tile, *Game.GameInterface)
    RenderSound(Bumm)
    
    *Tile\IsSet = #False
EndProcedure

Procedure SetTileTypes(*Map.Map)
    *Map\AddTileType("block", GetSprite("Block.bmp"), #Null, #Null, #Null)
    *Map\AddTileType("top-prickle", GetSprite("TopPrickle.bmp"), #Null, @TopPrickle_OnTopHit(), #Null)
    *Map\AddTileType("bottom-prickle", GetSprite("BottomPrickle.bmp"), @BottomPrickle_OnBottomHit(), #Null, #Null)
    *Map\AddTileType("mushroom-spawner", GetSprite("QuestionMark.bmp"), @MushroomSpawner_OnBottomHit(), #Null, #Null)
    *Map\AddTileType("heart-spawner", GetSprite("QuestionMark.bmp"), @HeartSpawner_OnBottomHit(), #Null, #Null)
    *Map\AddTileType("flower-spawner", GetSprite("QuestionMark.bmp"), @FlowerSpawner_OnBottomHit(), #Null, #Null)
    *Map\AddTileType("coin-spawner", GetSprite("QuestionMark.bmp"), @CoinSpawner_OnBottomHit(), #Null, #Null)
    *Map\AddTileType("black", GetSprite("Black.bmp"), @Black_OnBottomHit(), #Null, #Null)
    *Map\AddTileType("box", GetSprite("Box.bmp"), #Null, #Null, #Null)
    *Map\AddTileType("blob", GetSprite("Blob.bmp"), @Blob_OnBottomHit(), #Null, #Null)
EndProcedure
;}
;{ Game
Class Game Extends GameInterface

    Game()
    Release()
    
    GetEntityTypes()
    GetCamera()
    GetMap()
    GetEntities()
    
    Free()
    
    Init(Width.l, Height.l, Reset.l = #True)
    
    Load(File.s, Reset.l = #True)
    Save(File.s)
    
    AddEntityType(Name.s, *Constructor.Entity_Constructor, SpriteFile.s)
    GetEntityType(Name.s)
    CreateEntity(*EntityType.EntityType, X.l, Y.l)
    
    PlayerDead()
    PlayerHitSavePoint(X.l, Y.l)
    PlayerHitWarp(Target.l)
    
    AddLife()
    AddCoin()
    
    GetPlayer()
    AddEntity(Dummy.l)
    
    CheckMusic()
    
    Update()
    Render(NoPlayer.l = #False)
    RenderHud()
    
    ; Entity types
    *EntityTypes.Array
    
    ; Camera
    *Camera.Camera
    
    ; Map
    *Map.Map
    
    ; Entity list
    *Entities.Array

    ; Player
    *Player.Player
    
    ; Lives
    Lives.l
    
    ; Coins
    Coins.l
    
    ; Save point
    LastSavePointX.l
    LastSavePointY.l
    
    DoRespawn.l
    
    ; Warp target
    WarpTarget.s
    
    ; Current map
    CurrentMap.s
    
    ; Background music
    Music.s
    
EndClass

Declare.l SetEntityTypes(*Game.Game)

Procedure Game\Game()
    This\EntityTypes = NewObject Array(SizeOf(EntityType))
    SetEntityTypes(This)
    
    This\Lives = 5
    This\Coins = 0
EndProcedure

Procedure Game\Release()
    ; This\Free() doesn't work here ... probably a bug in PureObject?
    *thisM\Free()
EndProcedure

Procedure Game\GetEntityTypes()
    ProcedureReturn This\EntityTypes
EndProcedure

Procedure Game\GetCamera()
    ProcedureReturn This\Camera
EndProcedure

Procedure Game\GetMap()
    ProcedureReturn This\Map
EndProcedure

Procedure Game\GetEntities()
    ProcedureReturn This\Entities
EndProcedure

Procedure Game\Free()
    If This\Camera : DeleteObject This\Camera : EndIf
    If This\Map : DeleteObject This\Map : EndIf
    
    If This\Entities
        Define I.l
        
        For I = 0 To This\Entities\GetCount() - 1
            Define *Entity.Entity = PeekL(This\Entities\Get(I))
            DeleteObject *Entity
        Next
        
        DeleteObject This\Entities
    EndIf   
    
    If IsModule(0) : StopModule(0) : EndIf
EndProcedure

Procedure Game\Init(Width.l, Height.l, Reset.l = #True)
    This\Free()
    
    This\Camera = NewObject Camera
    
    This\Map = NewObject Map(Width, Height)
    SetTileTypes(This\Map)
    
    This\Entities = NewObject Array(SizeOf(Long))
    This\Player = #Null
    
    If Reset
        This\Coins = 0
        This\Lives = 10
    EndIf
EndProcedure

Procedure Game\Load(File.s, Reset.l = #True)
    Define Handle.l = LoadXML(#PB_Any, File)
    
    This\CurrentMap = File
    
    If Not Handle
        MessageRequester("Error", "Couldn't open file for reading: " + File)
        ProcedureReturn
    EndIf
    
    Define TilesNode.l = XMLNodeFromPath(RootXMLNode(Handle), "/map/tiles")
    
    If Not TilesNode
        MessageRequester("Error", "Invalid map: missing /map/tiles node")
        ProcedureReturn
    EndIf
    
    This\Init(Val(GetXMLAttribute(TilesNode, "width")), Val(GetXMLAttribute(TilesNode, "height")), Reset)
    
    If IsModule(0) : StopModule(0) : FreeModule(0) : EndIf
    Define MusicNode.l = XMLNodeFromPath(RootXMLNode(Handle), "/map/music")
    
    If MusicNode
        This\Music = GetXMLAttribute(MusicNode, "path")
        
        ; If GameMode = #Mode_Game
        LoadModule(0, "Data/" + This\Music)
            ModuleVolume(0, 40)
            PlayModule(0)
        ; EndIf
    EndIf
    
    Define TileNode.l = ChildXMLNode(TilesNode)
    
    While TileNode
        Define TileType.s = GetXMLAttribute(TileNode, "type")
        This\Map\SetTile(Val(GetXMLAttribute(TileNode, "x")), Val(GetXMLAttribute(TileNode, "y")), TileType)
        
        TileNode = NextXMLNode(TileNode)
    Wend
    
    Define EntitiesNode.l = XMLNodeFromPath(RootXMLNode(Handle), "/map/entities")
    
    If Not EntitiesNode
        MessageRequester("Error", "Invalid map: missing /map/entities node")
        ProcedureReturn
    EndIf
    
    Define EntityNode.l = ChildXMLNode(EntitiesNode)
    
    While EntityNode
        Define X.l = Val(GetXMLAttribute(EntityNode, "x"))
        Define Y.l = Val(GetXMLAttribute(EntityNode, "y"))
        Define EntityType.s = GetXMLAttribute(EntityNode, "type")

        Define *Entity.Entity = This\CreateEntity(This\GetEntityType(EntityType), X, Y)
        
        *Entity\IterateAttributes(EntityNode, @Entity_Attributes_Load())
        *Entity\Init()
        
        If *Entity\GetType() = #Entity_Player
            If This\Player
                MessageRequester("Error", "Invalid map: more than one player entity")
                ProcedureReturn
            EndIf
            
            This\Player = *Entity
            
            If Reset
                This\LastSavePointX = X
                This\LastSavePointY = Y
            EndIf
        EndIf
        
        EntityNode = NextXMLNode(EntityNode)
    Wend
EndProcedure
    
Procedure Game\Save(File.s)
    Define Handle.l = CreateXML(#PB_Any)

    Define MainNode.l = CreateXMLNode(RootXMLNode(Handle))
    SetXMLNodeName(MainNode, "map")
    
    If This\Music
        Define MusicNode.l = CreateXMLNode(MainNode, -1)
        SetXMLNodeName(MusicNode, "music")
        SetXMLAttribute(MusicNode, "path", This\Music)
    EndIf
    
    Define TilesNode.l = CreateXMLNode(MainNode, -1)
    SetXMLNodeName(TilesNode, "tiles")
    SetXMLAttribute(TilesNode, "width", Str(This\Map\GetWidth()))
    SetXMLAttribute(TilesNode, "height", Str(This\Map\GetHeight()))
    
    Define X.l, Y.l
    
    For X = 0 To This\Map\GetWidth() - 1
        For Y = 0 To This\Map\GetHeight() - 1
            Define *Tile.Tile = This\Map\GetTile(X, Y)
            
            If *Tile\IsSet
                Define *TileType.TileType = *Tile\Type
                
                Define TileNode.l = CreateXMLNode(TilesNode, -1)
                SetXMLNodeName(TileNode, "tile")
                SetXMLAttribute(TileNode, "x", Str(X))
                SetXMLAttribute(TileNode, "y", Str(Y))
                SetXMLAttribute(TileNode, "type", PeekS(@*TileType\Name))
            EndIf
        Next
    Next
    
    Define EntitiesNode.l = CreateXMLNode(MainNode, -1)
    SetXMLNodeName(EntitiesNode, "entities")
    
    Define I.l
    
    For I = 0 To This\Entities\GetCount() - 1
        Define *Entity.Entity = PeekL(This\Entities\Get(I))
        
        Define EntityNode.l = CreateXMLNode(EntitiesNode, -1)
        SetXMLNodeName(EntityNode, "entity")
        SetXMLAttribute(EntityNode, "x", Str(*Entity\GetX()))
        SetXMLAttribute(EntityNode, "y", Str(*Entity\GetY()))
        
        Define *EntityType.EntityType = *Entity\GetEntityType()
        SetXMLAttribute(EntityNode, "type", PeekS(@*EntityType\Name))
        
        *Entity\IterateAttributes(EntityNode, @Entity_Attributes_Save())
    Next
    
    FormatXML(Handle, #PB_XML_LinuxNewline | #PB_XML_ReFormat | #PB_XML_ReIndent, 4)
    
    If Not SaveXML(Handle, File)
        MessageRequester("Error", "Couldn't open file for writing: " + File)
        ProcedureReturn
    EndIf
EndProcedure

Procedure Game\AddEntityType(Name.s, *Constructor.Entity_Constructor, SpriteFile.s)
    Define EntityType.EntityType
    CopyMemory(@Name, @EntityType\Name, Len(Name) + 1)
    EntityType\Constructor = *Constructor
    
    If SpriteFile ; Should probably only be loaded in editor mode
        EntityType\Sprite = GetSprite(SpriteFile)
    EndIf
    
    This\EntityTypes\Append(@EntityType)
EndProcedure

Procedure Game\GetEntityType(Name.s)
    Define I.l
    
    For I = 0 To This\EntityTypes\GetCount() - 1
        Define *EntityType.EntityType = This\EntityTypes\Get(I)
        
        If PeekS(@*EntityType\Name) = Name
            ProcedureReturn *EntityType
        EndIf
    Next
    
    Assert(#False, "entity type '" + Name + "' not found")
EndProcedure

Procedure Game\CreateEntity(*EntityType.EntityType, X.l, Y.l)
    Define *Entity.Entity = *EntityType\Constructor(X, Y)
    Define *Object.sEntity = *Entity
    
    Assert(*Entity)
    
    *Object\EntityType = *EntityType
    
    This\AddEntity(*Entity)
    
    ProcedureReturn *Entity
EndProcedure

Procedure Game\PlayerDead()
    If This\Player\CheckDead()
        This\Lives - 1
        
        ; If This\Lives > 0
            This\DoRespawn = #True
        ; EndIf
    EndIf
EndProcedure

Procedure Game\PlayerHitSavePoint(X.l, Y.l)
    This\LastSavePointX = X
    This\LastSavePointY = Y
EndProcedure

Procedure Game\PlayerHitWarp(Target.l)
    This\WarpTarget = PeekS(Target)
EndProcedure

Procedure Game\AddLife()
    This\Lives + 1
EndProcedure

Procedure Game\AddCoin()
    This\Coins + 1
    
    If This\Coins = 50
        RenderSound(Up)
        
        This\Coins = 0
        This\Lives + 1
    EndIf
EndProcedure

Procedure Game\GetPlayer()
    ProcedureReturn This\Player
EndProcedure

Procedure Game\AddEntity(Dummy.l)
    Define *Entity.Entity = Dummy
    Define *Object.sEntity = *Entity
    
    Assert(*Entity)
    
    *Object\Game = This
    *Object\Camera = This\Camera
    *Object\Map = This\Map
    *Object\Entities = This\Entities
    
    Define Entry.l
    Entry = *Entity
    
    This\Entities\Append(@Entry)
EndProcedure

Procedure Game\CheckMusic()
    If IsModule(0) 
        If GetModulePosition(0) = 255
            SetModulePosition(0, 0)
        EndIf
    EndIf  
EndProcedure

Procedure Game\Update()
    ;{ Warp
    If This\WarpTarget
        If IsModule(0)
            StopModule(0)
        EndIf
        
        RenderSound(WinStage)
        SmartDelay(5500)
        
        If This\WarpTarget = "goal"
            MessageRequester("Win", "You won the game! O_O!")
            SetGameMode(PreviousMode)
            
            This\WarpTarget = ""
            
            ProcedureReturn
        EndIf
            
        This\Load(This\WarpTarget, #False)
        
        Assert(This\Player)
        
        ; Hack
        This\LastSavePointX = This\Player\GetX()
        This\LastSavePointY = This\Player\GetY()
    
        This\WarpTarget = ""
    EndIf
    ;}
    ;{ Respawn
    If This\DoRespawn
        This\DoRespawn = #False

        If IsModule(0)
            StopModule(0)
        EndIf
        
        RenderSound(Die)
        
        ;{ Die sequence
        Define Sprite.l = GetSprite("DeadMario.bmp")
        
        Define X.l = This\Camera\ConvX(This\Player\GetX())
        Define Y.l = This\Camera\ConvY(This\Player\GetY())
        
        Define YSpeed.f = -1.5
        Define BeginTime.l = ElapsedMilliseconds()
        
        Repeat
            DMSim_FlushBuffer(0)
            
            This\Render(#True)
            This\RenderHud()
            
            Y + YSpeed
            YSpeed + 0.1
            
            DMSim_DisplayTransparentSprite(Sprite, X, Y, 0)
            
            DMSim_SwapBuffers()
            
            While WindowEvent() : Wend
            
            Delay(20)
        Until Y > #Screen_Height And ElapsedMilliseconds() - BeginTime > 2200
        ;} 
        ;{ Game over
        If This\Lives = 0
            RenderSound(GameOver)
            
            Define BeginTime.l = ElapsedMilliseconds()
            
            Repeat
                Define ElapsedTime.l = ElapsedMilliseconds() - BeginTime
                
                DMSim_FlushBuffer(0)
                
                This\Render(#True)
                This\RenderHud()
                
                Define Y.l = #Screen_Height - (ElapsedTime / 3000.0) * (#Screen_Height / 2.0)
                
                DMSim_Quad(0, Y, #Screen_Width, Y + 15, 1)
                DMSim_DisplayText(55, Y + 3, 4, "GAME OVER")
                
                DMSim_SwapBuffers()
                
                While WindowEvent() : Wend
                
                Delay(1)
            Until ElapsedTime > 3000
            
            SmartDelay(3000)
            
            SetGameMode(PreviousMode)
            ; This\Free()
            
            ProcedureReturn
        EndIf
        ;}
        
        This\Load(This\CurrentMap, #False)
        
        This\Player\SetX(This\LastSavePointX)
        This\Player\SetY(This\LastSavePointY)
        This\Player\OnRespawn()
    EndIf
    ;}
    ;{ Pause
    If DMSim_KeyPushed(#DMSIM_KEY_START) And Not DMSim_KeyPushed(#DMSIM_KEY_SELECT)
        While DMSim_KeyPushed(#DMSIM_KEY_START) : DMSim_KeyUpdate() : Wend

        While #True
            DMSim_KeyUpdate()
            
            If GetForegroundWindow_() = WindowID(0)
                If DMSim_KeyPushed(#DMSIM_KEY_START)
                    Break
                EndIf
            EndIf
            
            DMSim_FlushBuffer(0)
            
            This\Render()
            This\RenderHud()
            This\CheckMusic()
            
            DMSim_Quad(#Screen_Width - 60, #Screen_Height - 13, #Screen_Width, #Screen_Height, 1)
            DMSim_DisplayText(#Screen_Width - 50, #Screen_Height - 10, 4, "PAUSE")
            DMSim_SwapBuffers()
            
            While WindowEvent() : Wend
            
            Delay(10)
        Wend
        
        While DMSim_KeyPushed(#DMSIM_KEY_START) : DMSim_KeyUpdate() : Wend
    EndIf
    ;}
    
    This\CheckMusic()
    
    Define I.l
    Define *Entity.Entity

    For I = 0 To This\Entities\GetCount() - 1 
        *Entity = PeekL(This\Entities\Get(I))
        *Entity\Update()
    Next
    
    RemoveLoop: ; So what?
    For I = 0 To This\Entities\GetCount() - 1 
        *Entity = PeekL(This\Entities\Get(I))
        
        If *Entity\ShallBeRemoved()
            This\Entities\Remove(I)
            DeleteObject *Entity
            
            Goto RemoveLoop
        EndIf
    Next
    
    This\Map\Render(This\Camera)
    
    For I = 0 To This\Entities\GetCount() - 1
        *Entity = PeekL(This\Entities\Get(I))
        *Entity\Render()
    Next
EndProcedure

Procedure Game\Render(NoPlayer.l = #False)
    Define I.l
    Define *Entity.Entity
    
    This\Map\Render(This\Camera)
    
    For I = 0 To This\Entities\GetCount() - 1
        *Entity = PeekL(This\Entities\Get(I))
        
        If Not NoPlayer Or *Entity\GetType() <> #Entity_Player
            *Entity\Render()
        EndIf
    Next
EndProcedure

Procedure Game\RenderHud()
    DMSim_DisplayText(10, 10, 4, "Lives: " + Str(This\Lives))
    DMSim_DisplayText(100, 10, 4, "Coins: " + Str(This\Coins))
EndProcedure
;}
;{ Entity types
Procedure SetEntityTypes(*Game.Game)
    *Game\AddEntityType("player", @ConstructPlayer(), "Player.bmp")
    *Game\AddEntityType("save point", @ConstructSavePoint(), "SavePoint_Deactivated.bmp")
    *Game\AddEntityType("platform", @ConstructPlatform(), "Platform.bmp")
    *Game\AddEntityType("goomba", @ConstructGoomba(), "Goomba.bmp")
    *Game\AddEntityType("warp", @ConstructWarp(), "Warp.bmp")
    *Game\AddEntityType("mushroom", @ConstructMushroom(), "Mushroom.bmp")
    *Game\AddEntityType("coin", @ConstructCoin(), "Coin.bmp")
    *Game\AddEntityType("killer", @ConstructKiller(), "Killer.bmp")
    *Game\AddEntityType("spawner", @ConstructSpawner(), "Killer.bmp")
    *Game\AddEntityType("rocket", @ConstructRocket(), "LeftRocket.bmp")
    *Game\AddEntityType("fly", @ConstructFly(), "Fly.bmp")
    *Game\AddEntityType("boss", @ConstructBoss(), "Boss.bmp")
    *Game\AddEntityType("tortoise",@ConstructTortoise(), "LeftTortoise.bmp")
EndProcedure
;}
;}
;{- Main
Define *Game.Game = NewObject Game()

Define FrameTime.l = ElapsedMilliseconds()
Define fps.l = 0
Define LastFrame.l = ElapsedMilliseconds()

DMSim_SetKey(#DMSIM_KEY_A, #VK_CONTROL)
DMSim_SetKey(#DMSIM_KEY_B, #VK_SPACE)

#Frames_Per_Second = 50
#Frame_Time = 1000 / #Frames_Per_Second

#Release = #True

Repeat

    Repeat
        Define Event.l = WindowEvent()
        
        If Event = #PB_Event_CloseWindow
            End
        EndIf
    Until Not Event
    
    Define Diff.l = ElapsedMilliseconds() - LastFrame
    If Diff < #Frame_Time
        Delay(#Frame_Time - Diff)
    EndIf
    
    LastFrame = ElapsedMilliseconds()
    
    If GetForegroundWindow_() <> WindowID(0)
        Delay(10)
        Continue
    EndIf
    
    DMSim_FlushBuffer(0)
    DMSim_KeyUpdate()
    
    ;{ Run the game
    Select GameMode
        Case #Mode_Menu ;{
            DMSim_DisplayText(47, 10, 4, "Jump'n'run!")
            DMSim_DisplayText(30, 50, 4, "Enter: Start game")
            
CompilerIf #Release = #False
                DMSim_DisplayText(45, 70, 4, "Strg: Editor")
CompilerEndIf
            
            DMSim_DisplayText(48, 90, 4, "Space: Quit")
            
            If DMSim_KeyPushed(#DMSIM_KEY_START)
                While DMSim_KeyPushed(#DMSIM_KEY_START) : DMSim_KeyUpdate() : Wend
                
                *Game\Load("map0.map")
                SetGameMode(#Mode_Game)
                
CompilerIf #Release = #False
            ElseIf DMSim_KeyPushed(#DMSIM_KEY_A)
                *Game\Init(200, 30)
                SetGameMode(#Mode_Editor)
CompilerEndIf
                
            ElseIf DMSim_KeyPushed(#DMSIM_KEY_B)
                SetGameMode(#Mode_Nothing)
            EndIf
        ;}
        Case #Mode_Game ;{ 
            *Game\Update()
            *Game\Render()
            *Game\RenderHud()

            If DMSim_KeyPushed(#DMSIM_KEY_SELECT) And DMSim_KeyPushed(#DMSIM_KEY_START)
                *Game\Free()
                SetGameMode(PreviousMode)
                
                While DMSim_KeyPushed(#DMSIM_KEY_SELECT) Or DMSim_KeyPushed(#DMSIM_KEY_START)
                    While WindowEvent() : Wend
                    DMSim_KeyUpdate()
                Wend
            EndIf
        ;}
        Case #Mode_Editor ;{
            ;{ Variables
            Define TargetX.l
            Define TargetY.l
            
            Define TileX.l
            Define TileY.l
            
            Define TileType.l
            Define *TileType.TileType
            
            Define EntityType.l
            Define *EntityType.EntityType
            
            Define EditorTempMap.s
            Define MapLoaded.l

            If PreviousMode = #Mode_Game And EditorTempMap And Not MapLoaded
                *Game\Load(EditorTempMap)
                MapLoaded = #True
                
                DeleteFile(EditorTempMap)
                EditorTempMap = ""
            EndIf
            
            Define *EntityTypes.Array = *Game\GetEntityTypes()
            Define *Camera.Camera = *Game\GetCamera()
            Define *Map.Map = *Game\GetMap()
            Define *Entities.Array = *Game\GetEntities()
            Define *TileTypes.Array = *Map\GetTileTypes()
            
            If Not *EntityType : *EntityType = *EntityTypes\Get(0) : EndIf
            If Not *TileType : *TileType = *TileTypes\Get(0) : EndIf
            ;}
            ;{ Render
            *Game\Render()
            
            Define I.l
            
            For I = 0 To *Entities\GetCount() - 1
                Define *Entity.Entity = PeekL(*Entities\Get(I))
                
                Rect(*Camera\ConvX(*Entity\GetX()), *Camera\ConvY(*Entity\GetY()), *Entity\GetWidth(), *Entity\GetHeight(), 4)
            Next
            
            Rect(*Camera\ConvX(0), *Camera\ConvY(0), #Tile_Width * *Map\GetWidth(), #Tile_Height * *Map\GetHeight(), 4)
            
            If Not DMSim_KeyPushed(#DMSIM_KEY_SELECT)
                Rect(*Camera\ConvX(TileX * #Tile_Width), *Camera\ConvY(TileY * #Tile_Height), #Tile_Width, #Tile_Height, 4)
            EndIf
            
            DMSim_Quad(#Screen_Width / 2, #Screen_Height / 2, #Screen_Width / 2 + 2, #Screen_Height / 2 + 2, 4)
            
            #Editor_Info_Height = 50
            DMSim_Quad(0, #Screen_Width - #Editor_Info_Height, #Screen_Width, #Screen_Height, 1)
            
            DMSim_DisplayText(5, #Screen_Height - #Editor_Info_Height + 20, 4, Mid(PeekS(@*TileType\Name), 0, 8))
            DMSim_DisplayTransparentSprite(*TileType\Sprite, 5, #Screen_Height - #Editor_Info_Height + 30, 0)
            
            DMSim_DisplayText(60, #Screen_Height - #Editor_Info_Height + 20, 4, Mid(PeekS(@*EntityType\Name), 0, 8))
            DMSim_DisplayTransparentSprite(*EntityType\Sprite, 60, #Screen_Height - #Editor_Info_Height + 30, 0)
            
            DMSim_DisplayText(113, #Screen_Height - #Editor_Info_Height + 20, 4, Str(TargetX) + "|" + Str(TargetY))
            ;}
            ;{ Calculate target and tile pos
            TargetX = *Camera\GetX() + #Screen_Width / 2
            TargetY = *Camera\GetY() + #Screen_Height / 2
            
            TileX = TargetX / #Tile_Width
            TileY = TargetY / #Tile_Height
            
            If TileX < 0 : TileX = 0 : EndIf
            If TileX >= *Map\GetWidth() : TileX = *Map\GetWidth() - 1 : EndIf
            If TileY < 0 : TileY = 0 : EndIf
            If TileY >= *Map\GetHeight() : TileY = *Map\GetHeight() - 1 : EndIf
            ;}
            
            If Not DMSim_KeyPushed(#DMSIM_KEY_SELECT)
                ;{ Normal mode
                ;{ Scroll
                Define ScrollSpeed.l = 1
                
                If DMSim_KeyPushed(#DMSIM_KEY_START)
                    ScrollSpeed = #Tile_Width
                EndIf
                
                If DMSim_KeyPushed(#DMSIM_KEY_LEFT)
                    *Camera\SetX(*Camera\GetX() - ScrollSpeed)
                ElseIf DMSim_KeyPushed(#DMSIM_KEY_RIGHT)
                    *Camera\SetX(*Camera\GetX() + ScrollSpeed)
                EndIf
                
                If DMSim_KeyPushed(#DMSIM_KEY_UP)
                    *Camera\SetY(*Camera\GetY() - ScrollSpeed)
                ElseIf DMSim_KeyPushed(#DMSIM_KEY_DOWN)
                    *Camera\SetY(*Camera\GetY() + ScrollSpeed)
                EndIf
                ;}
                ;{ Set tile
                If DMSim_KeyPushed(#DMSIM_KEY_A)
                    *Map\SetTile(TileX, TileY, PeekS(@*TileType\Name))
                EndIf
                ;}
                ;{ Remove tile
                If DMSim_KeyPushed(#DMSIM_KEY_B)
                    Define *Tile.Tile = *Map\GetTile(TileX, TileY)
                    *Tile\IsSet = #False
                EndIf
                ;}
                ;}
            Else
                ;{ Shift mode
                ;{ Change tile type
                Define LastKeyUp.l
                
                If LastKeyUp > 0 : LastKeyUp - 1 : EndIf
                
                If DMSim_KeyPushed(#DMSIM_KEY_UP)
                    If LastKeyUp = 0
                        TileType + 1
                        If TileType = *TileTypes\GetCount() : TileType = 0 : EndIf
                        
                        *TileType = *TileTypes\Get(TileType)
                        
                        LastKeyUp = 25
                    EndIf
                Else
                    LastKeyUp = 0
                EndIf
                ;}
                ;{ Change entity type
                Define LastKeyLeft.l
                
                If LastKeyLeft > 0 : LastKeyLeft - 1 : EndIf
                
                If DMSim_KeyPushed(#DMSIM_KEY_LEFT)
                    If LastKeyLeft = 0
                        EntityType + 1
                        If EntityType = *EntityTypes\GetCount() : EntityType = 0 : EndIf
                        
                        *EntityType = *EntityTypes\Get(EntityType)
                        
                        LastKeyLeft = 25
                    EndIf
                Else
                    LastKeyLeft = 0
                EndIf
                ;}
                ;{ Set attributes
                If DMSim_KeyPushed(#DMSIM_KEY_RIGHT)
                    Define I.l
                    
                    For I = 0 To *Entities\GetCount() - 1
                        Define *Entity.Entity
                        
                        *Entity = PeekL(*Entities\Get(I))
                        
                        If TargetX >= *Entity\GetX() And TargetX <= *Entity\GetX() + *Entity\GetWidth() And TargetY >= *Entity\GetY() And TargetY <= *Entity\GetY() + *Entity\GetWidth()
                            *Entity\IterateAttributes(0, @Entity_Attributes_Input())
                            
                            Break
                        EndIf
                    Next
                EndIf
                ;}
                ;{ Spawn entity
                Define PushedKeyA.l
                
                If DMSim_KeyPushed(#DMSIM_KEY_A)
                    If Not PushedKeyA
                        *Game\CreateEntity(*EntityType, TargetX, TargetY)
                        
                        PushedKeyA = #True
                    EndIf
                Else
                    PushedKeyA = #False
                EndIf
                ;}
                ;{ Remove entity
                If DMSim_KeyPushed(#DMSIM_KEY_B)
                    Define I.l
                    
                    For I = 0 To *Entities\GetCount() - 1
                        Define *Entity.Entity
                        
                        *Entity = PeekL(*Entities\Get(I))
                        
                        If TargetX >= *Entity\GetX() And TargetX <= *Entity\GetX() + *Entity\GetWidth() And TargetY >= *Entity\GetY() And TargetY <= *Entity\GetY() + *Entity\GetWidth()
                            *Entities\Remove(I)
                            DeleteObject *Entity
                            
                            Break
                        EndIf
                    Next
                EndIf
                ;}
                ;{ Menu
                If DMSim_KeyPushed(#DMSIM_KEY_START) 
                    While DMSim_KeyPushed(#DMSIM_KEY_START)
                        While WindowEvent() : Wend
                        DMSim_KeyUpdate()
                    Wend
                    
                    Repeat ; Why create a second loop? This could be simply put into the main loop...
                        
                        DMSim_StartTiming()
                        
                        While WindowEvent() : Wend
                        
                        DMSim_KeyUpdate()
                        
                        DMSim_DisplayText(40, 20, 4, "A: Test map")
                        DMSim_DisplayText(40, 30, 4, "B: Quit")
                        DMSim_DisplayText(40, 40, 4, "Left: New map")
                        DMSim_DisplayText(40, 50, 4, "Up: Save map")
                        DMSim_DisplayText(40, 60, 4, "Down: Load map")
                        DMSim_DisplayText(40, 70, 4, "Start: Leave menu")
                        DMSim_SwapBuffers()
                        
                        If DMSim_KeyPushed(#DMSIM_KEY_A)
                            SetGameMode(#Mode_Game)
                            
                            EditorTempMap = "editor_temp.map"
                            MapLoaded = #False
                            
                            *Game\Save(EditorTempMap)
                            *Game\Load(EditorTempMap)
                            
                            FrameTime = 0
                            
                            Break
                        EndIf
                        
                        If DMSim_KeyPushed(#DMSIM_KEY_B)
                            *Game\Free()
                            SetGameMode(#Mode_Menu)
                            
                            While DMSim_KeyPushed(#DMSIM_KEY_B) : DMSim_KeyUpdate() : Wend
                            Break
                        EndIf
                        
                        If DMSim_KeyPushed(#DMSIM_KEY_LEFT)
                            Define Width.l = Val(InputRequester("New map", "Width?", "200"))
                            
                            If Width = 0
                                Break
                            EndIf
                            
                            Define Height.l = Val(InputRequester("New map", "Height?", "20"))
                            
                            If Height = 0
                                Break
                            EndIf
                            
                            *Game\Init(Width, Height)
                        EndIf
                        
                        If DMSim_KeyPushed(#DMSIM_KEY_UP)
                            Define File.s = SaveFileRequester("Save map", "", "Map (*.map)|*.map", 0)
                            
                            If File
                                If GetExtensionPart(File) <> "map"
                                    File + ".map"
                                EndIf
                                
                                *Game\Save(File)
                            EndIf
                            
                            Break
                        EndIf
                        
                        If DMSim_KeyPushed(#DMSIM_KEY_DOWN)
                            Define File.s = OpenFileRequester("Load map", "", "Map (*.map)|*.map", 0)
                            
                            If File And FileSize(File) > 0
                                *Game\Load(File)
                            EndIf
                            
                            Break
                        EndIf
                        
                        If DMSim_KeyPushed(#DMSIM_KEY_START)
                            Break
                        EndIf
                        
                        DMSim_StopTiming()
                        
                    ForEver
                EndIf
                ;}
                ;}
            EndIf
        ;}
    EndSelect
    ;}
    ;{ Measure FPS
    If ElapsedMilliseconds() - FrameTime < 1000
        fps + 1
    Else
        SetWindowTitle(0, "GBC - FPS: " + Str(fps))
        
        FrameTime = ElapsedMilliseconds()
        fps = 0
    EndIf
    ;}
    
    DMSim_SwapBuffers()

Until GameMode = #Mode_Nothing

DeleteObject *Game

DMSim_CloseScreen()
;} 
; jaPBe Version=3.8.2.693
; FoldLines=00000029002A0052005300B900BB010E010F013801390154015501E801E90311
; FoldLines=031203A503F30475047604DB04DC0527052805560557059A059B060206030665
; FoldLines=0666069306670000069406FB06FC075E075F077E077F07B707B80819081A0836
; FoldLines=08370A11089B000008CD000008FC0000090F0000093800000940000009500000
; FoldLines=09570000095D0000097A0000097D000009800000098B0000099C000009DC0000
; FoldLines=0A120A830AD20AD80ADA0ADD0ADF0AE10AE30AE50AE70AE90AEB0AED0AEF0AFF
; FoldLines=0B010B100B600B9C0B9E0BA80BAA0BB60BB80BC30BC50BCD0BCF0BD20BD40BD6
; FoldLines=0BD80BDA0BDC0BE50BE70BE90BEB0BFA0BFC0C020C050C210C220C700CAF0CBC
; FoldLines=0CBE0CC10CC30CD30D290D490D770D890D8A0D8E0D8F0D940D980DA90DAA0DBB
; FoldLines=0DBC0DCC0DCD0DD90DDA0DEB0DEC0E490E4F0E58
; Build=15
; FirstLine=35
; CursorPosition=1002
; ExecutableFormat=Windows
; Executable=E:\PureBasic\gbc\gbc.exe
; DontSaveDeclare
; EOF