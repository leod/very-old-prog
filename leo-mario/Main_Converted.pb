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
If Not __Expr : PrintN("ASSERTION FAILED (" + Str(#PB_Compiler_Line) + "): " + DoubleQuote#__Expr#DoubleQuote + " (" + __Msg + ")") : Input() : End : EndIf
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
Interface Array
  
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
  
  EndInterface : Structure sArray : *vt.l : *Entries.l
  ElementSize.l
  Count.l
  
EndStructure : Declare.l ConstructArray(ElementSize.l,Count.l=0) : Declare.l Array_Release(*this): Global _VT_Array

Procedure Array_Array(*this.sArray, ElementSize.l, Count.l = 0 ) : Protected *thisM.Array = *this
  *this\ElementSize = ElementSize
  
  If Count <> 0
    *thisM\Allocate(Count)
  EndIf
EndProcedure

Procedure Array_Release(*this.sArray ) : Protected *thisM.Array = *this
  If *this\Entries
    FreeMemory(*this\Entries)
  EndIf
EndProcedure

Procedure Array_GetCount(*this.sArray ) : Protected *thisM.Array = *this
  ProcedureReturn *this\Count
EndProcedure

Procedure Array_Set(*this.sArray, Index.l, Value.l ) : Protected *thisM.Array = *this
  Assert(Index >= 0)
  Assert(Index < *this\Count)
  
  CopyMemory(Value, *this\Entries + Index * *this\ElementSize, *this\ElementSize)
EndProcedure

Procedure Array_Get(*this.sArray, Index.l ) : Protected *thisM.Array = *this
  Assert(Index >= 0)
  Assert(Index < *this\Count)
  
  ProcedureReturn *this\Entries + Index * *this\ElementSize
EndProcedure

Procedure Array_Allocate(*this.sArray, Count.l ) : Protected *thisM.Array = *this
  *this\Count = Count
  *this\Entries = ReAllocateMemory(*this\Entries, *this\Count * *this\ElementSize)
EndProcedure

Procedure Array_Append(*this.sArray, Value.l ) : Protected *thisM.Array = *this
  *thisM\Allocate(*this\Count + 1)
  *thisM\Set(*this\Count - 1, Value)
EndProcedure

Procedure Array_Remove(*this.sArray, Index.l ) : Protected *thisM.Array = *this
  Assert(*this\Count)
  *this\Count - 1
  
  If *this\Count = 0 Or Index = *this\Count
    ProcedureReturn
  EndIf
  
  CopyMemory(*this\Entries + *this\Count * *this\ElementSize, *this\Entries + Index * *this\ElementSize, *this\ElementSize)
EndProcedure

Procedure Array_Clear(*this.sArray ) : Protected *thisM.Array = *this
  *this\Count = 0
  FreeMemory(*this\Entries)
  *this\Entries = #Null
EndProcedure
;}
;{ Camera
Interface Camera
  
  GetX()
  GetY()
  
  SetX(X.l)
  SetY(Y.l)
  
  ; Convert absolute into relative coordinates
  ConvX(X.l)
  ConvY(Y.l)
  
  Release() : EndInterface : Structure sCamera : *vt.l : X.l
  Y.l
  
EndStructure : Declare.l ConstructCamera() : Declare.l Camera_Release(*this): Global _VT_Camera

Procedure Camera_GetX(*this.sCamera ) : Protected *thisM.Camera = *this
  ProcedureReturn *this\X
EndProcedure

Procedure Camera_GetY(*this.sCamera ) : Protected *thisM.Camera = *this
  ProcedureReturn *this\Y
EndProcedure

Procedure Camera_SetX(*this.sCamera, X.l ) : Protected *thisM.Camera = *this
  *this\X = X
EndProcedure

Procedure Camera_SetY(*this.sCamera, Y.l ) : Protected *thisM.Camera = *this
  *this\Y = Y
EndProcedure

Procedure Camera_ConvX(*this.sCamera, X.l ) : Protected *thisM.Camera = *this
  ProcedureReturn X - *this\X
EndProcedure

Procedure Camera_ConvY(*this.sCamera, Y.l ) : Protected *thisM.Camera = *this
  ProcedureReturn Y - *this\Y
EndProcedure
;}
;{ Game interface
Prototype.l Entity_Constructor(X.l, Y.l)

Structure EntityType
  Name.c[64]
  
  *Constructor.Entity_Constructor
  Sprite.l ; Preview for the editor
EndStructure

Interface GameInterface
  PlayerDead()
  PlayerHitSavePoint(X.l, Y.l)
  PlayerHitWarp(Target.l)
  
  AddLife()
  AddCoin()
  
  GetPlayer()
  GetEntities()
  GetMap()
  
  AddEntity(Entity.l)
  GetEntityType(Name.s)
  CreateEntity(*EntityType.EntityType, X.l, Y.l)
Release() : EndInterface : Structure sGameInterface : *vt.l : EndStructure : Declare.l ConstructGameInterface() : Declare.l GameInterface_Release(*this): Global _VT_GameInterface

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

Interface Map
  
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
  
  EndInterface : Structure sMap : *vt.l : *TileTypes.Array
  
  Width.l
  Height.l
  
  *Tiles.Array
  
EndStructure : Declare.l ConstructMap(Width.l,Height.l) : Declare.l Map_Release(*this): Global _VT_Map

Procedure Map_Map(*this.sMap, Width.l, Height.l ) : Protected *thisM.Map = *this
  *this\TileTypes = constructArray(SizeOf (TileType))
  *this\Width = Width
  *this\Height = Height
  *this\Tiles = constructArray(SizeOf (Tile), *this\Width * *this\Height)
EndProcedure

Procedure Map_Release(*this.sMap ) : Protected *thisM.Map = *this
  *this\Tiles\Release() : FreeMemory(*this\Tiles) : *this\Tiles = 0 
EndProcedure

Procedure Map_AddTileType(*this.sMap, Name.s, Sprite.l, *OnBottomHit.TileType_OnBottomHit, *OnTopHit.TileType_OnTopHit, *OnHit.TileType_OnHit ) : Protected *thisM.Map = *this
  Define TileType.TileType
  
  CopyMemory(@Name, @TileType\Name, Len(Name) + 1)
  TileType\Sprite = Sprite
  TileType\OnBottomHit = *OnBottomHit
  TileType\OnTopHit = *OnTopHit
  TileType\OnHit = *OnHit
  
  *this\TileTypes\Append(@TileType)
EndProcedure

Procedure Map_GetTileType(*this.sMap, Name.s ) : Protected *thisM.Map = *this
  Define I.l
  
  For I = 0 To *this\TileTypes\GetCount() - 1
    Define *TileType.TileType = *this\TileTypes\Get(I)
    
    If PeekS(@*TileType\Name) = Name
      ProcedureReturn *TileType
    EndIf
  Next
  
  Assert(#False, "tile type '" + Name + "' not found")
EndProcedure

Procedure Map_GetTileTypes(*this.sMap ) : Protected *thisM.Map = *this
  ProcedureReturn *this\TileTypes
EndProcedure

Procedure Map_GetTile(*this.sMap, X.l, Y.l ) : Protected *thisM.Map = *this
  Assert(X >= 0)
  Assert(X < *this\Width)
  Assert(Y >= 0)
  Assert(Y < *this\Height)
  
  ProcedureReturn *this\Tiles\Get(Y * *this\Width + X)
EndProcedure

Procedure Map_SetTile(*this.sMap, X.l, Y.l, Type.s ) : Protected *thisM.Map = *this
  Define *Tile.Tile = *thisM\GetTile(X, Y)
  
  *Tile\IsSet = #True
  *Tile\X = X
  *Tile\Y = Y
  *Tile\Type = *thisM\GetTileType(Type)
EndProcedure

Procedure Map_GetWidth(*this.sMap ) : Protected *thisM.Map = *this
  ProcedureReturn *this\Width
EndProcedure

Procedure Map_GetHeight(*this.sMap ) : Protected *thisM.Map = *this
  ProcedureReturn *this\Height
EndProcedure

Procedure Map_Render(*this.sMap, *Camera.Camera ) : Protected *thisM.Map = *this
  Define StartX.l = *Camera\GetX() / #Tile_Width
  Define EndX.l = StartX + #Screen_Width / #Tile_Width
  Define StartY.l = *Camera\GetY() / #Tile_Height
  Define EndY.l = StartY + #Screen_Width / #Tile_Width
  
If StartX < 0 : StartX = 0 : EndIf
If StartX >= *this\Width : StartX = *this\Width - 1 : EndIf
If StartY < 0 : StartY = 0 : EndIf
If StartY >= *this\Height : StartY = *this\Height - 1 : EndIf
If EndX < 0 : EndX = 0 : EndIf
If EndX >= *this\Width : EndX = *this\Width - 1 : EndIf
If EndY < 0 : EndY = 0 : EndIf
If EndY >= *this\Height : EndY = *this\Height - 1 : EndIf
  
  Define X.l, Y.l
  
  For Y = StartY To EndY
    For X = StartX To EndX
      
      Define *Tile.Tile = *thisM\GetTile(X, Y)
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

Interface Entity
  
  Entity()
  
  IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
  Init() ; Called after all attributes have been loaded
  
  Kill()
  
  Update()
  Render()
  
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
  
  Release() : EndInterface : Structure sEntity : *vt.l : DoRemove.l
  
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
  
EndStructure : Declare.l ConstructEntity() : Declare.l Entity_Release(*this): Global _VT_Entity

Procedure Entity_Entity(*this.sEntity ) : Protected *thisM.Entity = *this
  *this\Active = #True
  *this\Solid = #True
EndProcedure

Procedure Entity_IterateAttributes(*this.sEntity, UserDefined.l, *Callback.Entity_Attributes_Callback ) : Protected *thisM.Entity = *this
  
EndProcedure

Procedure Entity_Init(*this.sEntity ) : Protected *thisM.Entity = *this
  
EndProcedure

Procedure Entity_Kill(*this.sEntity ) : Protected *thisM.Entity = *this
  
EndProcedure

Procedure Entity_GetX(*this.sEntity ) : Protected *thisM.Entity = *this
  ProcedureReturn *this\X
EndProcedure

Procedure Entity_GetY(*this.sEntity ) : Protected *thisM.Entity = *this
  ProcedureReturn *this\Y
EndProcedure

Procedure Entity_SetX(*this.sEntity, X.l ) : Protected *thisM.Entity = *this
  *this\X = X
EndProcedure

Procedure Entity_SetY(*this.sEntity, Y.l ) : Protected *thisM.Entity = *this
  *this\Y = Y
EndProcedure

Procedure Entity_GetWidth(*this.sEntity ) : Protected *thisM.Entity = *this
  ProcedureReturn *this\Width
EndProcedure

Procedure Entity_GetHeight(*this.sEntity ) : Protected *thisM.Entity = *this
  ProcedureReturn *this\Height
EndProcedure

Procedure Entity_GetType(*this.sEntity ) : Protected *thisM.Entity = *this
  ProcedureReturn *this\Type
EndProcedure

Procedure Entity_GetEntityType(*this.sEntity ) : Protected *thisM.Entity = *this
  ProcedureReturn *this\EntityType
EndProcedure

Procedure Entity_IsActive(*this.sEntity ) : Protected *thisM.Entity = *this
  ProcedureReturn *this\Active
EndProcedure

Procedure Entity_IsSolid(*this.sEntity ) : Protected *thisM.Entity = *this
  ProcedureReturn *this\Solid
EndProcedure

Procedure Entity_CheckTileCollision(*this.sEntity, X.l, Y.l, *OutTile.Long = #Null ) : Protected *thisM.Entity = *this
  Define TileX.l = X / #Tile_Width, TileY.l = Y / #Tile_Height
  
  If TileY < 0
    ProcedureReturn #False
  EndIf
  
  ; If *thisM = This\Game\GetPlayer()
  ; Debug TileX
  ; EndIf
  
  If TileX >= 0 And TileX < *this\Map\GetWidth() And TileY < *this\Map\GetHeight() ;And TileY >= 0
    Define *Tile.Tile = *this\Map\GetTile(TileX, TileY)
    
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

Procedure Entity_IsMapCollision(*this.sEntity, X.l, Y.l, *OutTile.Long = #Null ) : Protected *thisM.Entity = *this
  Define RestX.l = X % #Tile_Width
  Define Type.l
  
  If *thisM\CheckTileCollision(X - RestX, Y + *this\Height, *OutTile)
    Type = #Collision_BottomLeft
  EndIf
  
  If *thisM\CheckTileCollision(X - RestX, Y, *OutTile)
    Type = #Collision_TopLeft
  EndIf
  
  If X + *this\Width > X + #Tile_Width - RestX
    If *thisM\CheckTileCollision(X + #Tile_Width - RestX, Y + *this\Height, *OutTile)
      Type = #Collision_BottomRight
    EndIf
    
    If *thisM\CheckTileCollision(X + #Tile_Width - RestX, Y, *OutTile)
      Type = #Collision_TopRight
    EndIf
  EndIf
  
  ProcedureReturn Type
EndProcedure

Procedure Entity_IsEntityCollision(*this.sEntity, Object.l, X.l, Y.l ) : Protected *thisM.Entity = *this
  Define *Entity.sEntity = Object
  
  If Not *Entity\Active Or Not *Entity\Solid
    ProcedureReturn #False
  EndIf
  
  If X + *this\Width >= *Entity\X And X <= *Entity\X + *Entity\Width And Y + *this\Height >= *Entity\Y And Y <= *Entity\Y + *Entity\Height
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

Procedure Entity_Move(*this.sEntity, X.f, Y.f, *OutTile.Long = #Null ) : Protected *thisM.Entity = *this
  Define.l Result = *thisM\IsMapCollision(*this\X + X, *this\Y + Y, *OutTile)
  
  If Not Result
    *this\X + X
    *this\Y + Y
  EndIf
  
  ProcedureReturn Result
EndProcedure

Procedure Entity_RequestRemoval(*this.sEntity ) : Protected *thisM.Entity = *this
  *this\DoRemove = #True
EndProcedure

Procedure Entity_ShallBeRemoved(*this.sEntity ) : Protected *thisM.Entity = *this
  ProcedureReturn *this\DoRemove
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

Interface Goomba Extends Entity
  
  Goomba(X.l, Y.l)
  
  overloaded_IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
  
  overloaded_Kill()
  
  overloaded_Update()
  overloaded_Render()
  
  overloaded_Release() : EndInterface : Structure sGoomba Extends sEntity : Sprite.l
  
  MoveSpeed.f
  
  FallFromBorders.l
  
  DoWalk.l
  Direction.l
  
  KillTime.l
  
  Frame.l
  NextFrame.l
  
EndStructure : Declare.l ConstructGoomba(X.l,Y.l) : Declare.l Goomba_Release(*this): Global _VT_Goomba

Procedure Goomba_Goomba(*this.sGoomba, X.l, Y.l ) : Protected *thisM.Goomba = *this
  *thisM\Entity()
  
  *this\Type = #Entity_Enemy
  
  *this\DoWalk = #False
  *this\Direction = #Direction_Left
  *this\FallFromBorders = #True
  
  *this\X = X
  *this\Y = Y
  *this\Width = 10
  *this\Height = 8
  *this\Sprite = GetSprite("Goomba.bmp")
  *this\MoveSpeed = 0.3
EndProcedure

Procedure Goomba_IterateAttributes(*this.sGoomba, UserDefined.l, *Callback.Entity_Attributes_Callback ) : Protected *thisM.Goomba = *this
  *Callback(UserDefined, "fall-from-borders", "fall down (1) from borders, or change direction (0)?", #Long, @*this\FallFromBorders)
EndProcedure

Procedure Goomba_Kill(*this.sGoomba ) : Protected *thisM.Goomba = *this
  RenderSound(Goomba)
  
  *this\Solid = #False
  *this\KillTime = 100
  *this\Frame = 2
EndProcedure

Procedure Goomba_Update(*this.sGoomba ) : Protected *thisM.Goomba = *this
  ;{ Getting killed
  If *this\KillTime
    *this\KillTime - 1
    
    If *this\KillTime = 0
      *thisM\RequestRemoval()
    EndIf
    
    ProcedureReturn
  EndIf
  ;}
  ;{ Walk animation
  *this\NextFrame + 1
  
  If *this\NextFrame = 25
    *this\Frame ! 1
    *this\NextFrame = 0
  EndIf
  ;}
  ;{ Check visibility
  If Not *this\DoWalk
    Define *Player.Entity = *this\Game\GetPlayer()
    
    If Not *Player
      *this\DoWalk = #True
    Else
      If Abs(*this\X - *Player\GetX()) <= #Screen_Width + *this\Width + *Player\GetWidth() And Abs(*this\Y - *Player\GetY()) <= #Screen_Height + *this\Height + *Player\GetHeight()
        *this\DoWalk = #True
      Else
        *this\DoWalk = #False
        ProcedureReturn
      EndIf
    EndIf
  EndIf
  
  Define MoveSpeed.f = *this\MoveSpeed
If *this\Direction = #Direction_Left : MoveSpeed * - 1 : EndIf
  ;}
  ;{ Collision with other enemies
  Define *Entity.Entity
  Define I.l
  
  For I = 0 To *this\Entities\GetCount() - 1
    *Entity = PeekL(*this\Entities\Get(I))
  If *Entity = *this Or *Entity\GetType() <> #Entity_Enemy : Continue : EndIf
    
    If *thisM\IsEntityCollision(*Entity, *this\X + MoveSpeed, *this\Y + #Gravity)
      *this\Direction ! 1
      
      ProcedureReturn
    EndIf
  Next
  ;}
  ;{ Move
  Define *Tile.Tile
  
  If *thisM\Move(0, #Gravity, @*Tile)
    If *thisM\Move(MoveSpeed, 0)
      *this\Direction ! 1
    Else
      ;{ Prevent falling from borders
      If Not *this\FallFromBorders And *Tile
        If *this\Direction = #Direction_Left And *Tile\X - 1 >= 0 And *this\X - *Tile\X * #Tile_Width < *this\MoveSpeed + 1
          Define *LeftTile.Tile = *this\Map\GetTile(*Tile\X - 1, *Tile\Y)
          
          If Not *LeftTile\IsSet
            *this\Direction ! 1
          EndIf
        ElseIf *this\Direction = #Direction_Right And *Tile\X + 1 < *this\Map\GetWidth() - 1 And *Tile\X * #Tile_Width - *this\X < *this\MoveSpeed + 1
          Define *RightTile.Tile = *this\Map\GetTile(*Tile\X + 1, *Tile\Y)
          
          If Not *RightTile\IsSet
            *this\Direction ! 1
          EndIf
        EndIf
      EndIf
      ;}
    EndIf
  EndIf
  ;}
EndProcedure

Procedure Goomba_Render(*this.sGoomba ) : Protected *thisM.Goomba = *this
  DMSim_ClipSprite(*this\Sprite, *this\Frame * 9, 0, 9, 8)
  DMSim_DisplayTransparentSprite(*this\Sprite, *this\Camera\ConvX(*this\X), *this\Camera\ConvY(*this\Y), 0)
EndProcedure
;}
;{ Bomb
Interface Bomb Extends Entity
  
  Bomb(X.l, Y.l)
  
  overloaded_Update()
  overloaded_Render()
  
  IsExploding()
  
  overloaded_Release() : EndInterface : Structure sBomb Extends sEntity : BombSprite.l
  ExplosionSprite.l
  
  T.l
  Exploding.l
  
EndStructure : Declare.l ConstructBomb(X.l,Y.l) : Declare.l Bomb_Release(*this): Global _VT_Bomb

Procedure Bomb_Bomb(*this.sBomb, X.l, Y.l ) : Protected *thisM.Bomb = *this
  *thisM\Entity()
  
  *this\Type = #Entity_Bomb
  
  *this\X = X
  *this\Y = Y
  
  *this\Width = 5
  *this\Height = 5
  
  *this\BombSprite = GetSprite("Bomb.bmp")
  *this\ExplosionSprite = GetSprite("Explosion.bmp")
  
  *this\T = 140
EndProcedure

Procedure Bomb_Update(*this.sBomb ) : Protected *thisM.Bomb = *this
  If *this\T
    *this\T - 1
    
    If Not *this\T
      *this\Exploding = 30
      
      *this\Width = 16
      *this\Height = 8
      *this\X - 4
      *this\Y - 3
    EndIf
  ElseIf *this\Exploding
    *this\Exploding - 1
    
    If Not *this\Exploding
      *thisM\RequestRemoval()
    EndIf
  EndIf
EndProcedure

Procedure Bomb_Render(*this.sBomb ) : Protected *thisM.Bomb = *this
  If *this\T
    Define Frame.l
    
    If *this\T % 10 < 5
      Frame = 1
    EndIf
    
    DMSim_ClipSprite(*this\BombSprite, Frame * *this\Width, 0, *this\Width, *this\Height)
    DMSim_DisplayTransparentSprite(*this\BombSprite, *this\Camera\ConvX(*this\X), *this\Camera\ConvY(*this\Y), 0)
  ElseIf *this\Exploding
    If *this\Exploding % 5 <= 2
      DMSim_DisplayTransparentSprite(*this\ExplosionSprite, *this\Camera\ConvX(*this\X), *this\Camera\ConvY(*this\Y), 0)
    EndIf
  EndIf
EndProcedure

Procedure Bomb_IsExploding(*this.sBomb ) : Protected *thisM.Bomb = *this
  ProcedureReturn *this\Exploding
EndProcedure
;}
;{ Tortoise
Interface Tortoise Extends Entity
  
  Tortoise(X.l, Y.l)
  
  overloaded_Kill()
  
  overloaded_Update()
  overloaded_Render()
  
  overloaded_Release() : EndInterface : Structure sTortoise Extends sEntity : LeftSprite.l
  RightSprite.l
  
  MoveSpeed.f
  
  DoWalk.l
  Direction.l
  
  Frame.l
  NextFrame.l
  
EndStructure : Declare.l ConstructTortoise(X.l,Y.l) : Declare.l Tortoise_Release(*this): Global _VT_Tortoise

Procedure Tortoise_Tortoise(*this.sTortoise, X.l, Y.l ) : Protected *thisM.Tortoise = *this
  *thisM\Entity()
  
  *this\Type = #Entity_Enemy
  
  *this\DoWalk = #False
  *this\Direction = #Direction_Left
  
  *this\X = X
  *this\Y = Y
  *this\Width = 8
  *this\Height = 12
  *this\LeftSprite = GetSprite("LeftTortoise.bmp")
  *this\RightSprite = GetSprite("RightTortoise.bmp")
  *this\MoveSpeed = 0.3
EndProcedure

Procedure Tortoise_Kill(*this.sTortoise ) : Protected *thisM.Tortoise = *this
  RenderSound(Goomba)
  
  *this\Solid = #False
  
  Define *Bomb.Entity = constructBomb(*this\X, *this\Y + 8)
  *this\Game\AddEntity(*Bomb)
  
  *thisM\RequestRemoval()
EndProcedure

Procedure Tortoise_Update(*this.sTortoise ) : Protected *thisM.Tortoise = *this
  ;{ Walk animation
  *this\NextFrame + 1
  
  If *this\NextFrame = 25
    *this\Frame ! 1
    *this\NextFrame = 0
  EndIf
  ;}
  ;{ Check visibility
  If Not *this\DoWalk
    Define *Player.Entity = *this\Game\GetPlayer()
    
    If Not *Player
      *this\DoWalk = #True
    Else
      If Abs(*this\X - *Player\GetX()) <= #Screen_Width + *this\Width + *Player\GetWidth() And Abs(*this\Y - *Player\GetY()) <= #Screen_Height + *this\Height + *Player\GetHeight()
        *this\DoWalk = #True
      Else
        *this\DoWalk = #False
        ProcedureReturn
      EndIf
    EndIf
  EndIf
  
  Define MoveSpeed.f = *this\MoveSpeed
If *this\Direction = #Direction_Left : MoveSpeed * - 1 : EndIf
  ;}
  ;{ Collision with other enemies
  Define *Entity.Entity
  Define I.l
  
  For I = 0 To *this\Entities\GetCount() - 1
    *Entity = PeekL(*this\Entities\Get(I))
  If *Entity = *this Or *Entity\GetType() <> #Entity_Enemy : Continue : EndIf
    
    If *thisM\IsEntityCollision(*Entity, *this\X + MoveSpeed, *this\Y + #Gravity)
      *this\Direction ! 1
      
      ProcedureReturn
    EndIf
  Next
  ;}
  ;{ Move
  Define *Tile.Tile
  
  If *thisM\Move(0, #Gravity, @*Tile)
    If *thisM\Move(MoveSpeed, 0)
      *this\Direction ! 1
    Else
      ;{ Prevent falling from borders
      If *Tile
        If *this\Direction = #Direction_Left And *Tile\X - 1 >= 0 And *this\X - *Tile\X * #Tile_Width < *this\MoveSpeed + 1
          Define *LeftTile.Tile = *this\Map\GetTile(*Tile\X - 1, *Tile\Y)
          
          If Not *LeftTile\IsSet
            *this\Direction ! 1
          EndIf
        ElseIf *this\Direction = #Direction_Right And *Tile\X + 1 < *this\Map\GetWidth() - 1 And *Tile\X * #Tile_Width - *this\X < *this\MoveSpeed + 1
          Define *RightTile.Tile = *this\Map\GetTile(*Tile\X + 1, *Tile\Y)
          
          If Not *RightTile\IsSet
            *this\Direction ! 1
          EndIf
        EndIf
      EndIf
      ;}
    EndIf
  EndIf
  ;}
EndProcedure

Procedure Tortoise_Render(*this.sTortoise ) : Protected *thisM.Tortoise = *this
  Define Sprite.l = *this\LeftSprite
If *this\Direction = #Direction_Right : Sprite = *this\RightSprite : EndIf
  
  DMSim_ClipSprite(Sprite, *this\Frame * *this\Width, 0, *this\Width, *this\Height)
  DMSim_DisplayTransparentSprite(Sprite, *this\Camera\ConvX(*this\X), *this\Camera\ConvY(*this\Y), 0)
EndProcedure
;}
;{ Fly
Interface Fly Extends Entity
  
  Fly(X.l, Y.l)
  
  overloaded_Kill()
  
  overloaded_Update()
  overloaded_Render()
  
  overloaded_Release() : EndInterface : Structure sFly Extends sEntity : Sprite.l
  XSpeed.f
  YSpeed.f
  WaitTime.l
  KillTime.l
  Frame.l
  DoWalk.l
  
EndStructure : Declare.l ConstructFly(X.l,Y.l) : Declare.l Fly_Release(*this): Global _VT_Fly

Procedure Fly_Fly(*this.sFly, X.l, Y.l ) : Protected *thisM.Fly = *this
  *thisM\Entity()
  
  *this\Type = #Entity_Enemy
  
  *this\X = X
  *this\Y = Y
  
  *this\Width = 9
  *this\Height = 9
  
  *this\Sprite = GetSprite("Fly.bmp")
  *this\YSpeed = - 1
  *this\XSpeed = - 1
EndProcedure

Procedure Fly_Kill(*this.sFly ) : Protected *thisM.Fly = *this
  RenderSound(Goomba) ; TODO: Get a sound for killed flies
  
  *this\KillTime = 100
  *this\Solid = #False
EndProcedure

Procedure Fly_Update(*this.sFly ) : Protected *thisM.Fly = *this
  ; I shall be punished for massive code duplication.
  If Not *this\DoWalk
    Define *Player.Entity = *this\Game\GetPlayer()
    
    If Not *Player
      *this\DoWalk = #True
    Else
      If Abs(*this\X - *Player\GetX()) <= #Screen_Width + *this\Width + *Player\GetWidth() And Abs(*this\Y - *Player\GetY()) <= #Screen_Height + *this\Height + *Player\GetHeight()
        *this\DoWalk = #True
      Else
        *this\DoWalk = #False
        ProcedureReturn
      EndIf
    EndIf
  EndIf
  
  If *this\WaitTime
    *this\WaitTime - 1
    
    If Not *this\WaitTime
      *this\YSpeed = - 1.5
      *this\Frame = 1
    EndIf
    
  If *this\KillTime : *this\WaitTime = 1 : EndIf
  Else
    If *thisM\Move(*this\XSpeed, 0)
      *this\XSpeed * - 1
    EndIf
    
    If *thisM\Move(0, *this\YSpeed)
      If *this\YSpeed > 0
        *this\WaitTime = 50
        *this\YSpeed = 1
        *this\Frame = 0
      Else
        *this\YSpeed = #Gravity
      EndIf
    Else
      *this\YSpeed + 0.05
    EndIf
  EndIf
  
  If *this\KillTime
    *this\KillTime - 1
    *this\Frame = 2
    
    If *this\KillTime = 0
      *thisM\RequestRemoval()
    EndIf
  EndIf
EndProcedure

Procedure Fly_Render(*this.sFly ) : Protected *thisM.Fly = *this
  DMSim_ClipSprite(*this\Sprite, *this\Frame * 13, 0, 13, 10)
  DMSim_DisplayTransparentSprite(*this\Sprite, *this\Camera\ConvX(*this\X), *this\Camera\ConvY(*this\Y), 0)
EndProcedure
;}
;{ Rocket
Interface Rocket Extends Entity
  
  Rocket(X.l, Y.l)
  
  overloaded_IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
  overloaded_Init()
  overloaded_Kill()
  
  overloaded_Update()
  overloaded_Render()
  
  overloaded_Release() : EndInterface : Structure sRocket Extends sEntity : Direction.l
  Speed.f
  
  Sprite.l
  
  SoundPlayed.l
  
EndStructure : Declare.l ConstructRocket(X.l,Y.l) : Declare.l Rocket_Release(*this): Global _VT_Rocket

Procedure Rocket_Rocket(*this.sRocket, X.l, Y.l ) : Protected *thisM.Rocket = *this
  *thisM\Entity()
  
  *this\Type = #Entity_Enemy
  
  *this\X = X
  *this\Y = Y
  
  *this\Width = 13
  *this\Height = 5
  
  *this\Direction = #Direction_Left
  *this\Speed = 1
EndProcedure

Procedure Rocket_IterateAttributes(*this.sRocket, UserDefined.l, *Callback.Entity_Attributes_Callback ) : Protected *thisM.Rocket = *this
  *Callback(UserDefined, "direction", "direction (0 = left; 1 = right)", #Long, @*this\Direction)
  *Callback(UserDefined, "speed", "speed", #Float, @*this\Speed)
EndProcedure

Procedure Rocket_Init(*this.sRocket ) : Protected *thisM.Rocket = *this
  If *this\Direction = #Direction_Left
    *this\Sprite = GetSprite("LeftRocket.bmp")
  ElseIf *this\Direction = #Direction_Right
    *this\Sprite = GetSprite("RightRocket.bmp")
  Else
    Assert(#False)
  EndIf
EndProcedure

Procedure Rocket_Kill(*this.sRocket ) : Protected *thisM.Rocket = *this
  *thisM\RequestRemoval()
EndProcedure

Procedure Rocket_Update(*this.sRocket ) : Protected *thisM.Rocket = *this
  If Not *this\SoundPlayed
    RenderSound(Rocket)
    *this\SoundPlayed = #True
  EndIf
  
  Define Speed.f = *this\Speed
  
  If *this\Direction = #Direction_Left
    Speed * - 1
  EndIf
  
  If *thisM\Move(Speed, 0)
    *thisM\RequestRemoval()
  EndIf
EndProcedure

Procedure Rocket_Render(*this.sRocket ) : Protected *thisM.Rocket = *this
  DMSim_DisplayTransparentSprite(*this\Sprite, *this\Camera\ConvX(*this\X), *this\Camera\ConvY(*this\Y), 0)
EndProcedure
;}
;{ Fireball
Interface Fireball Extends Entity
  
  Fireball(X.l, Y.l)
  
  overloaded_Update()
  overloaded_Render()
  
  overloaded_Release() : EndInterface : Structure sFireball Extends sEntity : Sprite.l
  Counter.l
  
EndStructure : Declare.l ConstructFireball(X.l,Y.l) : Declare.l Fireball_Release(*this): Global _VT_Fireball

Procedure Fireball_Fireball(*this.sFireball, X.l, Y.l ) : Protected *thisM.Fireball = *this
  *thisM\Entity()
  
  *this\X = X
  *this\Y = Y
  
  *this\Width = 12
  *this\Height = 6
  
  *this\Sprite = GetSprite("Fireball.bmp")
EndProcedure

Procedure Fireball_Update(*this.sFireball ) : Protected *thisM.Fireball = *this
  If *thisM\Move(- 0.82, 0)
    *thisM\RequestRemoval()
  EndIf
  
  *this\Counter + 1
  
  Define *Player.Entity = *this\Game\GetPlayer()
  
  If *thisM\IsEntityCollision(*Player, *this\X, *this\Y)
    *this\Game\PlayerDead()
  EndIf
EndProcedure

Procedure Fireball_Render(*this.sFireball ) : Protected *thisM.Fireball = *this
  Define Frame.l = 0
If *this\Counter % 8 > 4 : Frame = 1 : EndIf
  
  DMSim_ClipSprite(*this\Sprite, Frame * 12, 0, 12, 6)
  DMSim_DisplayTransparentSprite(*this\Sprite, *this\Camera\ConvX(*this\X), *this\Camera\ConvY(*this\Y), 0)
EndProcedure
;}
;{ Warp
Interface Warp Extends Entity
  
  Warp(X.l, Y.l)
  overloaded_Release()
  
  overloaded_IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
  
  GetTarget()
  SetTarget(Target.l)
  
  overloaded_Update()
  overloaded_Render()
  
  EndInterface : Structure sWarp Extends sEntity : Sprite.l
  
  ; String
  Target.l
  
EndStructure : Declare.l ConstructWarp(X.l,Y.l) : Declare.l Warp_Release(*this): Global _VT_Warp

Procedure Warp_Warp(*this.sWarp, X.l, Y.l ) : Protected *thisM.Warp = *this
  *thisM\Entity()
  
  *this\Type = #Entity_Warp
  
  *this\X = X
  *this\Y = Y
  
  *this\Width = 10
  *this\Height = 10
  
  *this\Sprite = GetSprite("Warp.bmp")
EndProcedure

Procedure Warp_Release(*this.sWarp ) : Protected *thisM.Warp = *this
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf : If *this\Target
  FreeMemory(*this\Target)
EndIf
EndProcedure

Procedure Warp_IterateAttributes(*this.sWarp, UserDefined.l, *Callback.Entity_Attributes_Callback ) : Protected *thisM.Warp = *this
*Callback(UserDefined, "target", "target, can either be a map or 'goal'", #String, @*this\Target)
EndProcedure

Procedure Warp_GetTarget(*this.sWarp ) : Protected *thisM.Warp = *this
ProcedureReturn *this\Target
EndProcedure

Procedure Warp_SetTarget(*this.sWarp, Target.l ) : Protected *thisM.Warp = *this
If *this\Target
  FreeMemory(*this\Target)
EndIf

Define Length.l = Len(PeekS(Target)) + 1

*this\Target = AllocateMemory(Length)
CopyMemory(Target, *this\Target, Length)
EndProcedure

Procedure Warp_Update(*this.sWarp ) : Protected *thisM.Warp = *this

EndProcedure

Procedure Warp_Render(*this.sWarp ) : Protected *thisM.Warp = *this
DMSim_DisplayTransparentSprite(*this\Sprite, *this\Camera\ConvX(*this\X), *this\Camera\ConvY(*this\Y), 0)
EndProcedure
;}
;{ Boss
Interface Boss Extends Entity

Boss(X.l, Y.l)

overloaded_Update()
overloaded_Render()

FuckMe()

overloaded_Release() : EndInterface : Structure sBoss Extends sEntity : Sprite.l
WaitTime.l
YSpeed.f
FireballTime.l
FireballCount.l
Life.l

EndStructure : Declare.l ConstructBoss(X.l,Y.l) : Declare.l Boss_Release(*this): Global _VT_Boss

Procedure Boss_Boss(*this.sBoss, X.l, Y.l ) : Protected *thisM.Boss = *this
*thisM\Entity()

*this\Type = #Entity_Boss

*this\X = X
*this\Y = Y

*this\Width = 32
*this\Height = 25

*this\Sprite = GetSprite("Boss.bmp")
*this\WaitTime = 100
*this\YSpeed = 1
*this\FireballTime = 150
*this\FireballCount = *this\FireballTime
*this\Life = 10
EndProcedure

Procedure Boss_Update(*this.sBoss ) : Protected *thisM.Boss = *this
If *thisM\Move(0, *this\YSpeed)
  If *this\WaitTime = - 1
    *this\WaitTime = 30
  ElseIf Not *this\WaitTime
    *this\YSpeed = - 1
    *this\WaitTime = - 1
  Else
    *this\WaitTime - 1
  EndIf
Else
  *this\YSpeed + 0.015
EndIf

*this\FireballCount - 1

If Not *this\FireballCount
  Define *Fireball.Entity = constructFireball(*this\X - 5, *this\Y + 12)
  RenderSound(Ball)
  *this\Game\AddEntity(*Fireball)
  *this\FireballCount = *this\FireballTime
EndIf
EndProcedure

Procedure Boss_Render(*this.sBoss ) : Protected *thisM.Boss = *this
Define Frame.l

If *this\WaitTime <> - 1 : Frame = 1 : EndIf

DMSim_ClipSprite(*this\Sprite, Frame * 32, 0, 32, 25)
DMSim_DisplayTransparentSprite(*this\Sprite, *this\Camera\ConvX(*this\X), *this\Camera\ConvY(*this\Y), 0)
EndProcedure

Procedure Boss_FuckMe(*this.sBoss ) : Protected *thisM.Boss = *this
*this\Life - 1

If *this\Life = 0
  Define *Warp.Warp = constructWarp(*this\X, *this\Y)
  *Warp\SetTarget(@"goal")
  
  *this\Game\AddEntity(*Warp)
While Not *Warp\Move(0, 1) : Wend
  
  *thisM\RequestRemoval()
Else
  *this\FireballTime * 0.87
  
  If *this\Life = 8
    Define *Goomba.Entity = constructGoomba(*this\X - 5, *this\Y)
    *this\Game\AddEntity(*Goomba)
    
    *Goomba = constructGoomba(*this\X + 10, *this\Y)
    *this\Game\AddEntity(*Goomba)
    
    *Goomba = constructGoomba(*this\X + 25, *this\Y)
    *this\Game\AddEntity(*Goomba)
  ElseIf *this\Life = 5
    Define *Fly.Entity = constructFly(*this\X - 5, *this\Y)
    *this\Game\AddEntity(*Fly)
    
    *Fly.Entity = constructFly(*this\X + 10, *this\Y)
    *this\Game\AddEntity(*Fly)
  EndIf
EndIf
EndProcedure
;}
;{ Shoot
Interface Shoot Extends Entity

Shoot(X.l, Y.l, SpeedX.l, SpeedY.l)

overloaded_Update()
overloaded_Render()

overloaded_Release() : EndInterface : Structure sShoot Extends sEntity : SpeedX.l
SpeedY.l

Age.l

Sprite.l

EndStructure : Declare.l ConstructShoot(X.l,Y.l,SpeedX.l,SpeedY.l) : Declare.l Shoot_Release(*this): Global _VT_Shoot

Procedure Shoot_Shoot(*this.sShoot, X.l, Y.l, SpeedX.l, SpeedY.l ) : Protected *thisM.Shoot = *this
*thisM\Entity()

*this\Type = #Entity_Shoot

*this\SpeedX = SpeedX
*this\SpeedY = SpeedY

*this\X = X
*this\Y = Y

*this\Width = 5
*this\Height = 5

*this\Sprite = GetSprite("Shoot.bmp")
EndProcedure

Procedure Shoot_Update(*this.sShoot ) : Protected *thisM.Shoot = *this
*this\Age + 1
If *this\Age = 500 : *thisM\RequestRemoval() : ProcedureReturn : EndIf

Define *Player.Entity = *this\Game\GetPlayer()

If Abs(*Player\GetX() - *this\X) >(#Screen_Width / 2) * 1.3 And Abs(*Player\GetY() - *this\Y) >(#Screen_Height / 2) * 1.3
  *thisM\RequestRemoval()
  ProcedureReturn
EndIf

If *thisM\Move(*this\SpeedX, 0)
  *this\SpeedX * - 1
EndIf

If *thisM\Move(0, *this\SpeedY)
  *this\SpeedY * - 1
EndIf

Define *Entity.Entity
Define I.l

For I = 0 To *this\Entities\GetCount() - 1
  *Entity = PeekL(*this\Entities\Get(I))
  
  Select *Entity\GetType()
    Case #Entity_Enemy
      If *thisM\IsEntityCollision(*Entity, *this\X, *this\Y)
        *thisM\RequestRemoval()
        *Entity\Kill()
        
        ProcedureReturn
      EndIf
      
    Case #Entity_Coin
      If *thisM\IsEntityCollision(*Entity, *this\X, *this\Y)
        RenderSound(Coin)
        *this\Game\AddCoin()
        *Entity\RequestRemoval()
        
        ProcedureReturn
      EndIf
      
    Case #Entity_Boss
      If *thisM\IsEntityCollision(*Entity, *this\X, *this\Y)
        ; RenderSound(Coin)
        RenderSound(Bumm)
        
        Define *Boss.Boss = *Entity
        *Boss\FuckMe()
        *thisM\RequestRemoval()
        
        ProcedureReturn
      EndIf
  EndSelect
Next
EndProcedure

Procedure Shoot_Render(*this.sShoot ) : Protected *thisM.Shoot = *this
Define X.l = *this\Camera\ConvX(*this\X), Y.l = *this\Camera\ConvY(*this\Y)

; DMSim_Ellipse(X, Y, X + This\Width, Y + This\Height, 4)
DMSim_DisplayTransparentSprite(*this\Sprite, X, Y, 0)
EndProcedure
;}
;{ Save point
Interface SavePoint Extends Entity

SavePoint(X.l, Y.l)

overloaded_Update()
overloaded_Render()

IsActivated()
Activate()

overloaded_Release() : EndInterface : Structure sSavePoint Extends sEntity : Activated.l
Sprite.l

EndStructure : Declare.l ConstructSavePoint(X.l,Y.l) : Declare.l SavePoint_Release(*this): Global _VT_SavePoint

Procedure SavePoint_SavePoint(*this.sSavePoint, X.l, Y.l ) : Protected *thisM.SavePoint = *this : *thisM\Entity()
*this\Type = #Entity_SavePoint

*this\X = X
*this\Y = Y

*this\Width = 10
*this\Height = 10

*this\Activated = #False
*this\Sprite = GetSprite("SavePoint_Deactivated.bmp")
EndProcedure

Procedure SavePoint_Update(*this.sSavePoint ) : Protected *thisM.SavePoint = *this

EndProcedure

Procedure SavePoint_Render(*this.sSavePoint ) : Protected *thisM.SavePoint = *this
DMSim_DisplayTransparentSprite(*this\Sprite, *this\Camera\ConvX(*this\X), *this\Camera\ConvY(*this\Y), 0)
EndProcedure

Procedure SavePoint_IsActivated(*this.sSavePoint ) : Protected *thisM.SavePoint = *this
ProcedureReturn *this\Activated
EndProcedure

Procedure SavePoint_Activate(*this.sSavePoint ) : Protected *thisM.SavePoint = *this
*this\Activated = #True
*this\Sprite = GetSprite("SavePoint_Activated.bmp")
EndProcedure
;}
;{ Platform
Interface Platform Extends Entity

Platform(X.l, Y.l)

overloaded_IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)
overloaded_Init()

overloaded_Update()
overloaded_Render()

overloaded_Release() : EndInterface : Structure sPlatform Extends sEntity : Sprite.l

Origin.l

Range.l
Direction.l
Wait.l
Speed.f

WaitLeft.l

EndStructure : Declare.l ConstructPlatform(X.l,Y.l) : Declare.l Platform_Release(*this): Global _VT_Platform

Procedure Platform_Platform(*this.sPlatform, X.l, Y.l ) : Protected *thisM.Platform = *this
*thisM\Entity()

*this\Type = #Entity_Platform

*this\X = X
*this\Y = Y

*this\Width = 20
*this\Height = 3

*this\Sprite = GetSprite("Platform.bmp")

; Standard attributes
*this\Range = 100
*this\Direction = #Direction_Right
*this\Wait = 30
*this\Speed = 1
EndProcedure

Procedure Platform_IterateAttributes(*this.sPlatform, UserDefined.l, *Callback.Entity_Attributes_Callback ) : Protected *thisM.Platform = *this
*Callback(UserDefined, "range", "range", #Long, @*this\Range)
*Callback(UserDefined, "direction", "initial direction (0 = left; 1 = right; 2 = up; 3 = down)", #Long, @*this\Direction)
*Callback(UserDefined, "wait", "wait time", #Long, @*this\Wait)
*Callback(UserDefined, "speed", "movement speed (floats are valid)", #Float, @*this\Speed)
*Callback(UserDefined, "start-delay", "initial wait", #Long, @*this\WaitLeft)
EndProcedure

Procedure Platform_Init(*this.sPlatform ) : Protected *thisM.Platform = *this
If *this\Direction = #Direction_Left Or *this\Direction = #Direction_Right
  *this\Origin = *this\X
Else
  *this\Origin = *this\Y
EndIf

If *this\Direction = #Direction_Left Or *this\Direction = #Direction_Up
  *this\Origin - *this\Range
EndIf
EndProcedure

Procedure Platform_Update(*this.sPlatform ) : Protected *thisM.Platform = *this
If *this\WaitLeft : *this\WaitLeft - 1 : EndIf

If Not *this\WaitLeft
  If *this\Direction = #Direction_Right
    *this\X + *this\Speed
    
    If *this\X >= *this\Origin + *this\Range
      *this\Direction = #Direction_Left
      *this\WaitLeft = *this\Wait
    EndIf
  ElseIf *this\Direction = #Direction_Left
    *this\X - *this\Speed
    
    If *this\X <= *this\Origin
      *this\Direction = #Direction_Right
      *this\WaitLeft = *this\Wait
    EndIf
  ElseIf *this\Direction = #Direction_Down
    *this\Y + *this\Speed
    
    If *this\Y >= *this\Origin + *this\Range
      *this\Direction = #Direction_Up
      *this\WaitLeft = *this\Wait
    EndIf
  ElseIf *this\Direction = #Direction_Up
    *this\Y - *this\Speed
    
    If *this\Y <= *this\Origin
      *this\Direction = #Direction_Down
      *this\WaitLeft = *this\Wait
    EndIf
  EndIf
EndIf
EndProcedure

Procedure Platform_Render(*this.sPlatform ) : Protected *thisM.Platform = *this
DMSim_DisplaySprite(*this\Sprite, *this\Camera\ConvX(*this\X), *this\Camera\ConvY(*this\Y))
EndProcedure
;}
;{ Power up
Enumeration
#PowerUp_Mushroom
#PowerUp_Heart
#PowerUp_Flower
EndEnumeration

Interface PowerUp Extends Entity

PowerUp(PowerUpType.l)

overloaded_Update()
overloaded_Render()

GetPowerUpType()

overloaded_Release() : EndInterface : Structure sPowerUp Extends sEntity : Sprite.l

PowerUpType.l

XSpeed.f
YSpeed.f

EndStructure : Declare.l ConstructPowerUp(PowerUpType.l) : Declare.l PowerUp_Release(*this): Global _VT_PowerUp

Procedure PowerUp_PowerUp(*this.sPowerUp, PowerUpType.l ) : Protected *thisM.PowerUp = *this
*thisM\Entity()

*this\Type = #Entity_PowerUp

*this\PowerUpType = PowerUpType

*this\XSpeed = 0.2
*this\YSpeed = - 0.3
EndProcedure

Procedure PowerUp_Update(*this.sPowerUp ) : Protected *thisM.PowerUp = *this
If Not *thisM\Move(0, *this\YSpeed)
  *this\YSpeed + 0.007
EndIf

If *thisM\Move(*this\XSpeed, 0)
  *this\XSpeed * - 1
EndIf
EndProcedure

Procedure PowerUp_Render(*this.sPowerUp ) : Protected *thisM.PowerUp = *this
If *this\Sprite
  DMSim_ClipSprite(*this\Sprite, 0, 0, *this\Width, *this\Height)
  DMSim_DisplayTransparentSprite(*this\Sprite, *this\Camera\ConvX(*this\X), *this\Camera\ConvY(*this\Y), 0)
EndIf
EndProcedure

Procedure PowerUp_GetPowerUpType(*this.sPowerUp ) : Protected *thisM.PowerUp = *this
ProcedureReturn *this\PowerUpType
EndProcedure

Procedure ConstructMushroom(X.l, Y.l)
Define *Result.sPowerUp = constructPowerUp(#PowerUp_Mushroom)

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
Define *Result.sPowerUp = constructPowerUp(#PowerUp_Heart)

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
Define *Result.sPowerUp = constructPowerUp(#PowerUp_Flower)

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
Interface Coin Extends Entity

Coin(X.l, Y.l)

overloaded_Update()
overloaded_Render()

overloaded_Release() : EndInterface : Structure sCoin Extends sEntity : Sprite.l

EndStructure : Declare.l ConstructCoin(X.l,Y.l) : Declare.l Coin_Release(*this): Global _VT_Coin

Procedure Coin_Coin(*this.sCoin, X.l, Y.l ) : Protected *thisM.Coin = *this
*thisM\Entity()

*this\Type = #Entity_Coin
*this\X = X
*this\Y = Y
*this\Width = 10
*this\Height = 10

*this\Sprite = GetSprite("Coin.bmp")
EndProcedure

Procedure Coin_Update(*this.sCoin ) : Protected *thisM.Coin = *this

EndProcedure

Procedure Coin_Render(*this.sCoin ) : Protected *thisM.Coin = *this
DMSim_DisplayTransparentSprite(*this\Sprite, *this\Camera\ConvX(*this\X), *this\Camera\ConvY(*this\Y), 0)
EndProcedure
;}
;{ Coin blink
Interface CoinBlink Extends Entity

CoinBlink(X.l, Y.l)

overloaded_Update()
overloaded_Render()

overloaded_Release() : EndInterface : Structure sCoinBlink Extends sEntity : Frame.l
NextFrame.l

Lifetime.l

Sprite.l

EndStructure : Declare.l ConstructCoinBlink(X.l,Y.l) : Declare.l CoinBlink_Release(*this): Global _VT_CoinBlink

Procedure CoinBlink_CoinBlink(*this.sCoinBlink, X.l, Y.l ) : Protected *thisM.CoinBlink = *this
*thisM\Entity()

*this\Type = #Entity_CoinBlink

*this\X = X
*this\Y = Y
*this\Solid = #False

*this\Lifetime = 17
*this\Sprite = GetSprite("CoinBlink.bmp")
EndProcedure

Procedure CoinBlink_Update(*this.sCoinBlink ) : Protected *thisM.CoinBlink = *this
*this\Y - 1

; TODO: Animation class?
*this\NextFrame + 1
If *this\NextFrame = 5
  *this\Frame + 1
  
  If *this\Frame = 2
    *this\Frame = 0
  EndIf
  
  *this\NextFrame = 0
EndIf

*this\Lifetime - 1

If *this\Lifetime = 0
  *thisM\RequestRemoval()
EndIf
EndProcedure

Procedure CoinBlink_Render(*this.sCoinBlink ) : Protected *thisM.CoinBlink = *this
DMSim_ClipSprite(*this\Sprite, *this\Frame * 8, 0, 8, 8)
DMSim_DisplayTransparentSprite(*this\Sprite, *this\Camera\ConvX(*this\X), *this\Camera\ConvY(*this\Y), 0)
EndProcedure
;}
;{ Spawner
Interface Spawner Extends Entity

Spawner(X.l, Y.l)
overloaded_Release()

overloaded_IterateAttributes(UserDefined.l, *Callback.Entity_Attributes_Callback)

overloaded_Update()
overloaded_Render()

; The spawned entity (string)
EndInterface : Structure sSpawner Extends sEntity : TypeEntity.l

; Offset for the spawned objects
OffsetX.l
OffsetY.l

; Interval
Interval.l
NextSpawn.l

; Prototype for the spawned entities
*PrototypeEntity.Entity

EndStructure : Declare.l ConstructSpawner(X.l,Y.l) : Declare.l Spawner_Release(*this): Global _VT_Spawner

Procedure Spawner_Spawner(*this.sSpawner, X.l, Y.l ) : Protected *thisM.Spawner = *this
*thisM\Entity()

*this\Type = #Entity_Spawner

*this\X = X
*this\Y = Y

*this\Width = #Tile_Width / 2
*this\Height = #Tile_Height / 2

*this\Solid = #False
EndProcedure

Procedure Spawner_Release(*this.sSpawner ) : Protected *thisM.Spawner = *this
CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf : ; DeleteObject doesn't work
FreeMemory(*this\PrototypeEntity)

If *this\TypeEntity
  FreeMemory(*this\TypeEntity)
EndIf
EndProcedure

Procedure Spawner_IterateAttributes(*this.sSpawner, UserDefined.l, *Callback.Entity_Attributes_Callback ) : Protected *thisM.Spawner = *this
*Callback(UserDefined, "entity-type", "entity type", #String, @*this\TypeEntity)
*Callback(UserDefined, "interval", "interval", #Long, @*this\Interval)
*Callback(UserDefined, "start-delay", "intial wait", #Long, @*this\NextSpawn)
*Callback(UserDefined, "offset-x", "X offset", #Long, @*this\OffsetX)
*Callback(UserDefined, "offset-y", "Y offset", #Long, @*this\OffsetY)

Define IsNew.l = #False

If Not *this\PrototypeEntity
  Define Foo.s = PeekS(*this\TypeEntity)
  Define *EntityType.EntityType = *this\Game\GetEntityType(Foo)
  *this\PrototypeEntity = *EntityType\Constructor(42, 42)
  IsNew = #True
EndIf

*this\PrototypeEntity\IterateAttributes(UserDefined, *Callback)

If IsNew
  *this\PrototypeEntity\Init()
EndIf
EndProcedure

Procedure Spawner_Update(*this.sSpawner ) : Protected *thisM.Spawner = *this
*this\NextSpawn - 1

If *this\NextSpawn = - 1
  Define *Player.Entity = *this\Game\GetPlayer()
  
  If Abs(*this\X - *Player\GetX()) < #Screen_Width And Abs(*this\Y - *Player\GetY()) < #Screen_Height
    ; Clone our prototype! (in a hackish way, but who cares)
    Define *EntityMemory.Entity = AllocateMemory(MemorySize(*this\PrototypeEntity))
    CopyMemory(*this\PrototypeEntity, *EntityMemory, MemorySize(*this\PrototypeEntity))
    
    *EntityMemory\SetX(*this\X + *this\OffsetX)
    *EntityMemory\SetY(*this\Y + *this\OffsetY)
    
    *this\Game\AddEntity(*EntityMemory)
  EndIf
  
  *this\NextSpawn = *this\Interval
EndIf
EndProcedure

Procedure Spawner_Render(*this.sSpawner ) : Protected *thisM.Spawner = *this

EndProcedure
;}
;{ Killer
Interface Killer Extends Entity

Killer(X.l, Y.l)

overloaded_Update()
overloaded_Render()

overloaded_Release() : EndInterface : Structure sKiller Extends sEntity : EndStructure : Declare.l ConstructKiller(X.l,Y.l) : Declare.l Killer_Release(*this): Global _VT_Killer

Procedure Killer_Killer(*this.sKiller, X.l, Y.l ) : Protected *thisM.Killer = *this
*thisM\Entity()

*this\Type = #Entity_Killer

*this\X = X
*this\Y = Y
*this\Width = #Tile_Width
*this\Height = #Tile_Height
EndProcedure

Procedure Killer_Update(*this.sKiller ) : Protected *thisM.Killer = *this

EndProcedure

Procedure Killer_Render(*this.sKiller ) : Protected *thisM.Killer = *this

EndProcedure
;}
;{ Player
#Player_Min_XSpeed = 1.0
#Player_Max_XSpeed = 2  .0
#Player_XSpeed_Accel = 0.043
#Player_YSpeed_Accel = 0.23
#Player_Max_YSpeed = 5.0
#Player_Jump_Speed = 1.5

Interface Player Extends Entity

_SetBig(Big.l)

Player(X.l, Y.l)

overloaded_Update()
overloaded_Render()

OnRespawn()
CheckDead()

overloaded_Release() : EndInterface : Structure sPlayer Extends sEntity : SpriteRight.l
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

EndStructure : Declare.l ConstructPlayer(X.l,Y.l) : Declare.l Player_Release(*this): Global _VT_Player

Procedure Player__SetBig(*this.sPlayer, Big.l ) : Protected *thisM.Player = *this
*this\IsBig = Big

If Big
  Assert(#False)
  
  *this\Width = 9
  *this\Height = 10
  ; This\Sprite = This\BigSprite
Else
  *this\Width = 9
  *this\Height = 9
  *this\SpriteRight = GetSprite("RightPlayer.bmp")
  *this\SpriteLeft = GetSprite("LeftPlayer.bmp")
EndIf
EndProcedure

Procedure Player_Player(*this.sPlayer, X.l, Y.l ) : Protected *thisM.Player = *this
*thisM\Entity()

*this\Type = #Entity_Player

*this\X = X
*this\Y = Y

; This\SmallSprite = GetSprite("Player.bmp")
; This\BigSprite = GetSprite("BigPlayer.bmp")

*thisM\_SetBig(#False)

*this\Direction = #Direction_Right

*this\Frame = 0
*this\FrameWidth = 10
*this\NumberWalkFrames = 3

*this\YSpeed = #Gravity
*this\XSpeed = 0
EndProcedure

Procedure Player_Update(*this.sPlayer ) : Protected *thisM.Player = *this
;{ Movement
Define DidMove.l

If DMSim_KeyPushed(#DMSIM_KEY_RIGHT)
  If *this\HasJumped
    If *this\XSpeed < 0.1
      *this\XSpeed = 1
    ElseIf *this\XSpeed > 0 And *this\Direction = #Direction_Left
      *this\XSpeed * 0.43
    EndIf
    
    *this\Direction = #Direction_Right
  Else
    *this\Direction = #Direction_Right
    
    If *this\XSpeed < #Player_Min_XSpeed And Not *this\HasJumped
      *this\XSpeed = #Player_Min_XSpeed + 0.01
    EndIf
  EndIf
EndIf

If DMSim_KeyPushed(#DMSIM_KEY_LEFT)
  If *this\HasJumped
    If *this\XSpeed < 0.1
      *this\XSpeed = 1
    ElseIf *this\XSpeed > 0 And *this\Direction = #Direction_Right
      *this\XSpeed * 0.43
    EndIf
    
    *this\Direction = #Direction_Left
  Else
    *this\Direction = #Direction_Left
    
    If *this\XSpeed < #Player_Min_XSpeed And Not *this\HasJumped
      *this\XSpeed = #Player_Min_XSpeed + 0.01
    EndIf
  EndIf
EndIf

If *this\XSpeed > 0
  Define Speed.f = *this\XSpeed
If *this\Direction = #Direction_Left : Speed * - 1 : EndIf
  
  If Not *thisM\Move(Speed, 0)
    ; Debug "move: " + StrF(This\XSpeed)
    
    DidMove = #True
  EndIf
EndIf

;{ Animation
If DidMove And Not *this\HasJumped
  *this\NextWalkFrame + 1
  
  ; Reset from jumping/standing
If *this\Frame = 3 Or *this\Frame = 4 : *this\Frame = 0 : EndIf
  
  If *this\NextWalkFrame >= 6 /(*this\XSpeed + 0.01)
    Assert(*this\Frame < *this\NumberWalkFrames)
    
    *this\Frame + 1
    
    If *this\Frame = *this\NumberWalkFrames
      *this\Frame = 0
    EndIf
    
    Assert(*this\Frame < *this\NumberWalkFrames)
    
    *this\NextWalkFrame = 0
  EndIf
ElseIf *this\HasJumped
  *this\Frame = 3
ElseIf Not DidMove
  *this\Frame = 4
EndIf
;}
;{ Deaccelerate
If ((Not DMSim_KeyPushed(#DMSIM_KEY_LEFT) And Not DMSim_KeyPushed(#DMSIM_KEY_RIGHT)) Or Not DidMove Or Not DMSim_KeyPushed(#DMSIM_KEY_B)) And Not *this\HasJumped
  If *this\XSpeed > 0
    *this\XSpeed - #Player_XSpeed_Accel * 5
    
  If *this\XSpeed <= 0 : *this\XSpeed = 0 : EndIf
    
    ; Debug "deaccel: " + StrF(This\XSpeed)
  EndIf
EndIf
;}

If *this\Invincible : *this\Invincible - 1 : EndIf

; Apply down speed (gravity)
Define *Tile.Tile
Define *TileType.TileType

Define CollisionType.l = *thisM\IsMapCollision(*this\X, *this\Y + *this\YSpeed, @*Tile)

;}
;{ Shooting
If *this\LastShot : *this\LastShot - 1 : EndIf

If *this\CanShoot And DMSim_KeyPushed(#DMSIM_KEY_B)
  If Not *this\HasShot And Not *this\LastShot
    RenderSound(Fireball)
    
    Define XSpeed.l = *this\XSpeed + 1
  If *this\Direction = #Direction_Left : XSpeed * - 1 : EndIf
    
    Define *Shoot.Shoot = constructShoot(*this\X, *this\Y, XSpeed, 1)
    *this\Game\AddEntity(*Shoot)
    *this\HasShot = #True
    *this\LastShot = 50
  EndIf
Else
  *this\HasShot = #False
EndIf
;}
;{ Platform attachement
If *this\Attached ;And Not CollisionType
  Define SpeedX.f = *this\Attached\GetX() - *this\AttachedOldX
  Define NewX.f = *this\Attached\GetX() + *this\AttachedDistanceX + SpeedX
  Define SpeedY.f = *this\Attached\GetY() - *this\AttachedOldY
  Define NewY.f = *this\Attached\GetY() + *this\AttachedDistanceY + SpeedY
  
  ; Move with the platform, check for map collisions though
  If *this\Attached\GetX() <> *this\AttachedOldX And Not *thisM\IsMapCollision(NewX, *this\Y, *Tile)
    *this\X = NewX
    *this\AddJumpSpeed = 0.5
  EndIf
  
  If *this\Attached\GetY() <> *this\AttachedOldY And Not *thisM\IsMapCollision(*this\Y, NewY, *Tile)
    *this\Y = NewY
    *this\AddJumpSpeed = 0.5
  EndIf
  
  *this\Attached = #Null
EndIf
;}
;{ Entity collision
Define *Entity.Entity
Define I.l

; Iterate through all entities and check for collision
For I = 0 To *this\Entities\GetCount() - 1
  *Entity = PeekL(*this\Entities\Get(I))
If *Entity = *this : Continue : EndIf
  
  If *thisM\IsEntityCollision(*Entity, *this\X, *this\Y)
    Select *Entity\GetType()
      Case #Entity_Enemy ;{
        ; Check if the player hopped on the enemy
        If Not CollisionType And *this\YSpeed > 0 And *this\Y + *this\Height - 2 < *Entity\GetY() + *Entity\GetHeight() And *Entity\IsSolid()
          *this\YSpeed = - 2
          *Entity\Kill()
        ElseIf Not *this\Invincible
          *this\Game\PlayerDead()
        EndIf
        ;}
      Case #Entity_SavePoint ;{
        Define *SavePoint.SavePoint = *Entity
        
        If Not *SavePoint\IsActivated()
          *SavePoint\Activate()
          *this\Game\PlayerHitSavePoint(*SavePoint\GetX(), *SavePoint\GetY())
        EndIf
        ;}
      Case #Entity_Platform ;{
        If *this\Y + *this\Height / 2 <= *Entity\GetY() And *this\X + *this\Width > *Entity\GetX() And *this\YSpeed > 0
          Define NewY.f = *Entity\GetY() - *this\Height - 1
          
          If Not *thisM\IsMapCollision(*this\X, NewY)
            *this\Y = NewY
            CollisionType = #Collision_BottomRight
            
            *this\Attached = *Entity
            *this\AttachedOldX = *Entity\GetX()
            *this\AttachedDistanceX = *this\X - *Entity\GetX()
            *this\AttachedOldY = *Entity\GetY()
            *this\AttachedDistanceY = *this\Y - *Entity\GetY()
          EndIf
        EndIf
        ;}
      Case #Entity_Warp ;{
        Define *Warp.Warp = *Entity
        Define Target.s = PeekS(*Warp\GetTarget())
        *this\Game\PlayerHitWarp(@Target)
        
        ProcedureReturn
        ;}
      Case #Entity_Coin ;{
        RenderSound(Coin)
        
        *this\Game\AddCoin()
        *Entity\RequestRemoval()
        ;}
      Case #Entity_PowerUp ;{
        Define *PowerUp.PowerUp = *Entity
        
        Select *PowerUp\GetPowerUpType()
          Case #PowerUp_Mushroom ;{
            Define OldWidth.l = *this\Width
            Define OldHeight.l = *this\Height
            
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
            
            *this\Game\AddLife()
            
          Case #PowerUp_Flower
            RenderSound(Up)
            
            *this\CanShoot = #True
        EndSelect
        
        *PowerUp\RequestRemoval()
        ;}
      Case #Entity_Killer ;{
        *this\Game\PlayerDead()
        ;}
      Case #Entity_Boss ;{
        *this\Game\PlayerDead()
        ;}
      Case #Entity_Bomb ;{
        Define *Bomb.Bomb = *Entity
        
        If *Bomb\IsExploding()
          *this\Game\PlayerDead()
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
    *TileType\OnHit(*Tile, *this\Game)
  EndIf
  
  If (CollisionType = #Collision_TopLeft Or CollisionType = #Collision_TopRight) And *TileType\OnBottomHit
    *TileType\OnBottomHit(*Tile, *this\Game)
  EndIf
  
  If (CollisionType = #Collision_BottomLeft Or CollisionType = #Collision_BottomRight) And *TileType\OnTopHit
    *TileType\OnTopHit(*Tile, *this\Game)
  EndIf
EndIf
;}
;{ Gravity/Jumping
; No collision, if applying the down force?
If Not CollisionType
  *this\Y + *this\YSpeed
  
  ; Increase the down force while falling
  If *this\YSpeed < #Player_Max_YSpeed
    *this\YSpeed + #Player_YSpeed_Accel
  EndIf
  
  ; Jump higher while jumping
  If *this\MayJump And *this\YSpeed > - 4 And DMSim_KeyPushed(#DMSIM_KEY_A)
    *this\YSpeed - #Player_YSpeed_Accel
    *this\MayJump - 1
  EndIf
  
  ; Collided with a tile which is under the player
ElseIf CollisionType = #Collision_BottomLeft Or CollisionType = #Collision_BottomRight
  ; Jumping
  If DMSim_KeyPushed(#DMSIM_KEY_A) And Not *this\HasJumped
    If Not *this\JumpKey
      RenderSound(Jump)
      
      *this\YSpeed = - #Player_Jump_Speed
      
      ; Jump higher when moving fast
      If *this\XSpeed > 1
        *this\YSpeed - *this\XSpeed * 0.4
      EndIf
      
      ; Also apply additional jump speed (for example when moving on a platform)
      If *this\AddJumpSpeed
        *this\YSpeed - *this\AddJumpSpeed
        *this\AddJumpSpeed = 0
      EndIf
      
      ; Allow to accelerate the jump while jumping (hold the jump key)
      *this\MayJump = 17
      
      *this\HasJumped = #True
      *this\JumpKey = #True
    EndIf
  Else
    *this\HasJumped = #False
    *this\YSpeed = #Gravity ; Reset the down force to normal after landing
    
    HaltSound(Jump)
  EndIf
  
If Not DMSim_KeyPushed(#DMSIM_KEY_A) : *this\JumpKey = #False : EndIf
  
  ; Accelerate
  If (DMSim_KeyPushed(#DMSIM_KEY_LEFT) Or DMSim_KeyPushed(#DMSIM_KEY_RIGHT)) And DMSim_KeyPushed(#DMSIM_KEY_B) And DidMove And *this\XSpeed >= #Player_Min_XSpeed And *this\XSpeed < #Player_Max_XSpeed
    *this\XSpeed + #Player_XSpeed_Accel
    
    ; Debug "accel: " + StrF(This\XSpeed)
  EndIf
  
  ; Collided with a tile above the player
Else
  *this\YSpeed = #Gravity
  *this\MayJump = #False
EndIf
;}
;{ Camera update
*this\Camera\SetX(*this\X - #Screen_Width / 2)
*this\Camera\SetY(*this\Y - #Screen_Height / 2)
;}
EndProcedure

Procedure Player_Render(*this.sPlayer ) : Protected *thisM.Player = *this
If *this\Invincible And *this\Invincible % 5 = 0
  *this\RenderMod ! 1
  *this\Invincible - 1
EndIf

If *this\Invincible = 0 : *this\RenderMod = #False : EndIf
If *this\RenderMod : ProcedureReturn : EndIf

Define Sprite.l

If *this\Direction = #Direction_Left
  Sprite = *this\SpriteLeft
ElseIf *this\Direction = #Direction_Right
  Sprite = *this\SpriteRight
EndIf

DMSim_ClipSprite(Sprite, *this\Frame * *this\FrameWidth, 0, *this\FrameWidth, 11)
DMSim_DisplayTransparentSprite(Sprite, *this\Camera\ConvX(*this\X), *this\Camera\ConvY(*this\Y), 0)
EndProcedure

Procedure Player_OnRespawn(*this.sPlayer ) : Protected *thisM.Player = *this
*this\Invincible = 125
*this\YSpeed = #Gravity
*this\XSpeed = 1
*this\Attached = #Null
*this\AddJumpSpeed = 0
*this\MayJump = 0
*this\HasJumped = #False
*this\LastShot = 0
*this\CanShoot = #False
*thisM\_SetBig(#False)
EndProcedure

Procedure Player_CheckDead(*this.sPlayer ) : Protected *thisM.Player = *this
ProcedureReturn #True

If Not *this\CanShoot
  ProcedureReturn #True
EndIf

; This\_SetBig(#False)
*this\CanShoot = #False
*this\Invincible = 100

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
    If *Player\GetX() <=(*Tile\X - 1) * #Tile_Width + #Tile_Width / 2 + 1
      ProcedureReturn
    EndIf
  EndIf
EndIf

If *Tile\X < *Map\GetWidth() - 1
  *Tile1 = *Map\GetTile(*Tile\X + 1, *Tile\Y)
  *TileType = *Tile1\Type
  
  If *Tile1\IsSet And *TileType\OnTopHit <> @TopPrickle_OnTopHit()
    If *Player\GetX() + *Player\GetWidth() >=(((*Tile\X + 1) * #Tile_Width))
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

*Game\AddEntity(ConstructCoinBlink(*Tile\X * #Tile_Width + #Tile_Width - 8, *Tile\Y * #Tile_Height - 15))
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
Interface Game Extends GameInterface

Game()
overloaded_Release()

GetEntityTypes()
GetCamera()
overloaded_GetMap()
overloaded_GetEntities()

Free()

Init(Width.l, Height.l, Reset.l = #True)

Load(File.s, Reset.l = #True)
Save(File.s)

AddEntityType(Name.s, *Constructor.Entity_Constructor, SpriteFile.s)
overloaded_GetEntityType(Name.s)
overloaded_CreateEntity(*EntityType.EntityType, X.l, Y.l)

overloaded_PlayerDead()
overloaded_PlayerHitSavePoint(X.l, Y.l)
overloaded_PlayerHitWarp(Target.l)

overloaded_AddLife()
overloaded_AddCoin()

overloaded_GetPlayer()
overloaded_AddEntity(Dummy.l)

CheckMusic()

Update()
Render(NoPlayer.l = #False)
RenderHud()

; Entity types
EndInterface : Structure sGame Extends sGameInterface : *EntityTypes.Array

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

EndStructure : Declare.l ConstructGame() : Declare.l Game_Release(*this): Global _VT_Game

Declare.l SetEntityTypes(*Game.Game)

Procedure Game_Game(*this.sGame ) : Protected *thisM.Game = *this
*this\EntityTypes = constructArray(SizeOf (EntityType))
SetEntityTypes(*this)

*this\Lives = 5
*this\Coins = 0
EndProcedure

Procedure Game_Release(*this.sGame ) : Protected *thisM.Game = *this
CompilerIf Defined(GameInterface_Release, #PB_Procedure) : GameInterface_Release(*this) : CompilerEndIf : ; This\Free() doesn't work here ... probably a bug in PureObject?
*thisM\Free()
EndProcedure

Procedure Game_GetEntityTypes(*this.sGame ) : Protected *thisM.Game = *this
ProcedureReturn *this\EntityTypes
EndProcedure

Procedure Game_GetCamera(*this.sGame ) : Protected *thisM.Game = *this
ProcedureReturn *this\Camera
EndProcedure

Procedure Game_GetMap(*this.sGame ) : Protected *thisM.Game = *this
ProcedureReturn *this\Map
EndProcedure

Procedure Game_GetEntities(*this.sGame ) : Protected *thisM.Game = *this
ProcedureReturn *this\Entities
EndProcedure

Procedure Game_Free(*this.sGame ) : Protected *thisM.Game = *this
If *this\Camera : *this\Camera\Release() : FreeMemory(*this\Camera) : *this\Camera = 0 : EndIf
If *this\Map : *this\Map\Release() : FreeMemory(*this\Map) : *this\Map = 0 : EndIf

If *this\Entities
  Define I.l
  
  For I = 0 To *this\Entities\GetCount() - 1
    Define *Entity.Entity = PeekL(*this\Entities\Get(I))
    *Entity\Release() : FreeMemory(*Entity) : *Entity = 0 
  Next
  
  *this\Entities\Release() : FreeMemory(*this\Entities) : *this\Entities = 0 
EndIf

If IsModule(0) : StopModule(0) : EndIf
EndProcedure

Procedure Game_Init(*this.sGame, Width.l, Height.l, Reset.l = #True ) : Protected *thisM.Game = *this
*thisM\Free()

*this\Camera = constructCamera()

*this\Map = constructMap(Width, Height)
SetTileTypes(*this\Map)

*this\Entities = constructArray(SizeOf (Long))
*this\Player = #Null

If Reset
  *this\Coins = 0
  *this\Lives = 10
EndIf
EndProcedure

Procedure Game_Load(*this.sGame, File.s, Reset.l = #True ) : Protected *thisM.Game = *this
Define Handle.l = LoadXML(#PB_Any, File)

*this\CurrentMap = File

If Not Handle
  MessageRequester("Error", "Couldn't open file for reading: " + File)
  ProcedureReturn
EndIf

Define TilesNode.l = XMLNodeFromPath(RootXMLNode(Handle), "/map/tiles")

If Not TilesNode
  MessageRequester("Error", "Invalid map: missing /map/tiles node")
  ProcedureReturn
EndIf

*thisM\Init(Val(GetXMLAttribute(TilesNode, "width")), Val(GetXMLAttribute(TilesNode, "height")), Reset)

If IsModule(0) : StopModule(0) : FreeModule(0) : EndIf
Define MusicNode.l = XMLNodeFromPath(RootXMLNode(Handle), "/map/music")

If MusicNode
  *this\Music = GetXMLAttribute(MusicNode, "path")
  
  ; If GameMode = #Mode_Game
  LoadModule(0, "Data/" + *this\Music)
  ModuleVolume(0, 40)
  PlayModule(0)
  ; EndIf
EndIf

Define TileNode.l = ChildXMLNode(TilesNode)

While TileNode
  Define TileType.s = GetXMLAttribute(TileNode, "type")
  *this\Map\SetTile(Val(GetXMLAttribute(TileNode, "x")), Val(GetXMLAttribute(TileNode, "y")), TileType)
  
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
  
  Define *Entity.Entity = *thisM\CreateEntity(*thisM\GetEntityType(EntityType), X, Y)
  
  *Entity\IterateAttributes(EntityNode, @Entity_Attributes_Load())
  *Entity\Init()
  
  If *Entity\GetType() = #Entity_Player
    If *this\Player
      MessageRequester("Error", "Invalid map: more than one player entity")
      ProcedureReturn
    EndIf
    
    *this\Player = *Entity
    
    If Reset
      *this\LastSavePointX = X
      *this\LastSavePointY = Y
    EndIf
  EndIf
  
  EntityNode = NextXMLNode(EntityNode)
Wend
EndProcedure

Procedure Game_Save(*this.sGame, File.s ) : Protected *thisM.Game = *this
Define Handle.l = CreateXML(#PB_Any)

Define MainNode.l = CreateXMLNode(RootXMLNode(Handle))
SetXMLNodeName(MainNode, "map")

If *this\Music
  Define MusicNode.l = CreateXMLNode(MainNode, - 1)
  SetXMLNodeName(MusicNode, "music")
  SetXMLAttribute(MusicNode, "path", *this\Music)
EndIf

Define TilesNode.l = CreateXMLNode(MainNode, - 1)
SetXMLNodeName(TilesNode, "tiles")
SetXMLAttribute(TilesNode, "width", Str(*this\Map\GetWidth()))
SetXMLAttribute(TilesNode, "height", Str(*this\Map\GetHeight()))

Define X.l, Y.l

For X = 0 To *this\Map\GetWidth() - 1
  For Y = 0 To *this\Map\GetHeight() - 1
    Define *Tile.Tile = *this\Map\GetTile(X, Y)
    
    If *Tile\IsSet
      Define *TileType.TileType = *Tile\Type
      
      Define TileNode.l = CreateXMLNode(TilesNode, - 1)
      SetXMLNodeName(TileNode, "tile")
      SetXMLAttribute(TileNode, "x", Str(X))
      SetXMLAttribute(TileNode, "y", Str(Y))
      SetXMLAttribute(TileNode, "type", PeekS(@*TileType\Name))
    EndIf
  Next
Next

Define EntitiesNode.l = CreateXMLNode(MainNode, - 1)
SetXMLNodeName(EntitiesNode, "entities")

Define I.l

For I = 0 To *this\Entities\GetCount() - 1
  Define *Entity.Entity = PeekL(*this\Entities\Get(I))
  
  Define EntityNode.l = CreateXMLNode(EntitiesNode, - 1)
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

Procedure Game_AddEntityType(*this.sGame, Name.s, *Constructor.Entity_Constructor, SpriteFile.s ) : Protected *thisM.Game = *this
Define EntityType.EntityType
CopyMemory(@Name, @EntityType\Name, Len(Name) + 1)
EntityType\Constructor = *Constructor

If SpriteFile ; Should probably only be loaded in editor mode
  EntityType\Sprite = GetSprite(SpriteFile)
EndIf

*this\EntityTypes\Append(@EntityType)
EndProcedure

Procedure Game_GetEntityType(*this.sGame, Name.s ) : Protected *thisM.Game = *this
Define I.l

For I = 0 To *this\EntityTypes\GetCount() - 1
  Define *EntityType.EntityType = *this\EntityTypes\Get(I)
  
  If PeekS(@*EntityType\Name) = Name
    ProcedureReturn *EntityType
  EndIf
Next

Assert(#False, "entity type '" + Name + "' not found")
EndProcedure

Procedure Game_CreateEntity(*this.sGame, *EntityType.EntityType, X.l, Y.l ) : Protected *thisM.Game = *this
Define *Entity.Entity = *EntityType\Constructor(X, Y)
Define *Object.sEntity = *Entity

Assert(*Entity)

*Object\EntityType = *EntityType

*thisM\AddEntity(*Entity)

ProcedureReturn *Entity
EndProcedure

Procedure Game_PlayerDead(*this.sGame ) : Protected *thisM.Game = *this
If *this\Player\CheckDead()
  *this\Lives - 1
  
  ; If This\Lives > 0
  *this\DoRespawn = #True
  ; EndIf
EndIf
EndProcedure

Procedure Game_PlayerHitSavePoint(*this.sGame, X.l, Y.l ) : Protected *thisM.Game = *this
*this\LastSavePointX = X
*this\LastSavePointY = Y
EndProcedure

Procedure Game_PlayerHitWarp(*this.sGame, Target.l ) : Protected *thisM.Game = *this
*this\WarpTarget = PeekS(Target)
EndProcedure

Procedure Game_AddLife(*this.sGame ) : Protected *thisM.Game = *this
*this\Lives + 1
EndProcedure

Procedure Game_AddCoin(*this.sGame ) : Protected *thisM.Game = *this
*this\Coins + 1

If *this\Coins = 50
  RenderSound(Up)
  
  *this\Coins = 0
  *this\Lives + 1
EndIf
EndProcedure

Procedure Game_GetPlayer(*this.sGame ) : Protected *thisM.Game = *this
ProcedureReturn *this\Player
EndProcedure

Procedure Game_AddEntity(*this.sGame, Dummy.l ) : Protected *thisM.Game = *this
Define *Entity.Entity = Dummy
Define *Object.sEntity = *Entity

Assert(*Entity)

*Object\Game = *this
*Object\Camera = *this\Camera
*Object\Map = *this\Map
*Object\Entities = *this\Entities

Define Entry.l
Entry = *Entity

*this\Entities\Append(@Entry)
EndProcedure

Procedure Game_CheckMusic(*this.sGame ) : Protected *thisM.Game = *this
If IsModule(0)
  If GetModulePosition(0) = 255
    SetModulePosition(0, 0)
  EndIf
EndIf
EndProcedure

Procedure Game_Update(*this.sGame ) : Protected *thisM.Game = *this
;{ Warp
If *this\WarpTarget
  If IsModule(0)
    StopModule(0)
  EndIf
  
  RenderSound(WinStage)
  SmartDelay(5500)
  
  If *this\WarpTarget = "goal"
    MessageRequester("Win", "You won the game! O_O!")
    SetGameMode(PreviousMode)
    
    *this\WarpTarget = ""
    
    ProcedureReturn
  EndIf
  
  *thisM\Load(*this\WarpTarget, #False)
  
  Assert(*this\Player)
  
  ; Hack
  *this\LastSavePointX = *this\Player\GetX()
  *this\LastSavePointY = *this\Player\GetY()
  
  *this\WarpTarget = ""
EndIf
;}
;{ Respawn
If *this\DoRespawn
  *this\DoRespawn = #False
  
  If IsModule(0)
    StopModule(0)
  EndIf
  
  RenderSound(Die)
  
  ;{ Die sequence
  Define Sprite.l = GetSprite("DeadMario.bmp")
  
  Define X.l = *this\Camera\ConvX(*this\Player\GetX())
  Define Y.l = *this\Camera\ConvY(*this\Player\GetY())
  
  Define YSpeed.f = - 1.5
  Define BeginTime.l = ElapsedMilliseconds()
  
  Repeat
    DMSim_FlushBuffer(0)
    
    *thisM\Render(#True)
    *thisM\RenderHud()
    
    Y + YSpeed
    YSpeed + 0.1
    
    DMSim_DisplayTransparentSprite(Sprite, X, Y, 0)
    
    DMSim_SwapBuffers()
    
  While WindowEvent() : Wend
    
    Delay(20)
  Until Y > #Screen_Height And ElapsedMilliseconds() - BeginTime > 2200
  ;}
  ;{ Game over
  If *this\Lives = 0
    RenderSound(GameOver)
    
    Define BeginTime.l = ElapsedMilliseconds()
    
    Repeat
      Define ElapsedTime.l = ElapsedMilliseconds() - BeginTime
      
      DMSim_FlushBuffer(0)
      
      *thisM\Render(#True)
      *thisM\RenderHud()
      
      Define Y.l = #Screen_Height -(ElapsedTime / 3000.0) *(#Screen_Height / 2.0)
      
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
  
  *thisM\Load(*this\CurrentMap, #False)
  
  *this\Player\SetX(*this\LastSavePointX)
  *this\Player\SetY(*this\LastSavePointY)
  *this\Player\OnRespawn()
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
    
    *thisM\Render()
    *thisM\RenderHud()
    *thisM\CheckMusic()
    
    DMSim_Quad(#Screen_Width - 60, #Screen_Height - 13, #Screen_Width, #Screen_Height, 1)
    DMSim_DisplayText(#Screen_Width - 50, #Screen_Height - 10, 4, "PAUSE")
    DMSim_SwapBuffers()
    
  While WindowEvent() : Wend
    
    Delay(10)
  Wend
  
While DMSim_KeyPushed(#DMSIM_KEY_START) : DMSim_KeyUpdate() : Wend
EndIf
;}

*thisM\CheckMusic()

Define I.l
Define *Entity.Entity

For I = 0 To *this\Entities\GetCount() - 1
  *Entity = PeekL(*this\Entities\Get(I))
  *Entity\Update()
Next

RemoveLoop : ; So what?
For I = 0 To *this\Entities\GetCount() - 1
  *Entity = PeekL(*this\Entities\Get(I))
  
  If *Entity\ShallBeRemoved()
    *this\Entities\Remove(I)
    *Entity\Release() : FreeMemory(*Entity) : *Entity = 0 
    
    Goto RemoveLoop
  EndIf
Next

*this\Map\Render(*this\Camera)

For I = 0 To *this\Entities\GetCount() - 1
  *Entity = PeekL(*this\Entities\Get(I))
  *Entity\Render()
Next
EndProcedure

Procedure Game_Render(*this.sGame, NoPlayer.l = #False ) : Protected *thisM.Game = *this
Define I.l
Define *Entity.Entity

*this\Map\Render(*this\Camera)

For I = 0 To *this\Entities\GetCount() - 1
  *Entity = PeekL(*this\Entities\Get(I))
  
  If Not NoPlayer Or *Entity\GetType() <> #Entity_Player
    *Entity\Render()
  EndIf
Next
EndProcedure

Procedure Game_RenderHud(*this.sGame ) : Protected *thisM.Game = *this
DMSim_DisplayText(10, 10, 4, "Lives: " + Str(*this\Lives))
DMSim_DisplayText(100, 10, 4, "Coins: " + Str(*this\Coins))
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
*Game\AddEntityType("tortoise", @ConstructTortoise(), "LeftTortoise.bmp")
EndProcedure
;}
;}
;{- Main
Define *Game.Game = constructGame()

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
            *Entity\Release() : FreeMemory(*Entity) : *Entity = 0 
            
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

*Game\Release() : FreeMemory(*Game) : *Game = 0 

DMSim_CloseScreen()
;}

; ------------------------------- OOP Constructors, etc. -------------------------------

Procedure ConstructArray(ElementSize.l,Count.l=0)
  Protected *this.sArray = AllocateMemory(SizeOf(sArray))
  Protected *thisM.Array = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Array And SizeOf(Array)
    _VT_Array = AllocateMemory(SizeOf(Array)) ; Global virtual table
    CompilerIf Defined(Array_Array, #PB_Procedure)
      PokeL(_VT_Array + OffsetOf(Array\Array()), @Array_Array())
    CompilerEndIf
    CompilerIf Defined(Array_Release, #PB_Procedure)
      PokeL(_VT_Array + OffsetOf(Array\Release()), @Array_Release())
    CompilerEndIf
    CompilerIf Defined(Array_GetCount, #PB_Procedure)
      PokeL(_VT_Array + OffsetOf(Array\GetCount()), @Array_GetCount())
    CompilerEndIf
    CompilerIf Defined(Array_Set, #PB_Procedure)
      PokeL(_VT_Array + OffsetOf(Array\Set()), @Array_Set())
    CompilerEndIf
    CompilerIf Defined(Array_Get, #PB_Procedure)
      PokeL(_VT_Array + OffsetOf(Array\Get()), @Array_Get())
    CompilerEndIf
    CompilerIf Defined(Array_Allocate, #PB_Procedure)
      PokeL(_VT_Array + OffsetOf(Array\Allocate()), @Array_Allocate())
    CompilerEndIf
    CompilerIf Defined(Array_Append, #PB_Procedure)
      PokeL(_VT_Array + OffsetOf(Array\Append()), @Array_Append())
    CompilerEndIf
    CompilerIf Defined(Array_Remove, #PB_Procedure)
      PokeL(_VT_Array + OffsetOf(Array\Remove()), @Array_Remove())
    CompilerEndIf
    CompilerIf Defined(Array_Clear, #PB_Procedure)
      PokeL(_VT_Array + OffsetOf(Array\Clear()), @Array_Clear())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Array
  CompilerIf Defined(Array_Array, #PB_Procedure) = #True
    Array_Array(*this, ElementSize, Count)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructCamera()
  Protected *this.sCamera = AllocateMemory(SizeOf(sCamera))
  Protected *thisM.Camera = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Camera And SizeOf(Camera)
    _VT_Camera = AllocateMemory(SizeOf(Camera)) ; Global virtual table
    CompilerIf Defined(Camera_GetX, #PB_Procedure)
      PokeL(_VT_Camera + OffsetOf(Camera\GetX()), @Camera_GetX())
    CompilerEndIf
    CompilerIf Defined(Camera_GetY, #PB_Procedure)
      PokeL(_VT_Camera + OffsetOf(Camera\GetY()), @Camera_GetY())
    CompilerEndIf
    CompilerIf Defined(Camera_SetX, #PB_Procedure)
      PokeL(_VT_Camera + OffsetOf(Camera\SetX()), @Camera_SetX())
    CompilerEndIf
    CompilerIf Defined(Camera_SetY, #PB_Procedure)
      PokeL(_VT_Camera + OffsetOf(Camera\SetY()), @Camera_SetY())
    CompilerEndIf
    CompilerIf Defined(Camera_ConvX, #PB_Procedure)
      PokeL(_VT_Camera + OffsetOf(Camera\ConvX()), @Camera_ConvX())
    CompilerEndIf
    CompilerIf Defined(Camera_ConvY, #PB_Procedure)
      PokeL(_VT_Camera + OffsetOf(Camera\ConvY()), @Camera_ConvY())
    CompilerEndIf
    CompilerIf Defined(Camera_Release, #PB_Procedure)
      PokeL(_VT_Camera + OffsetOf(Camera\Release()), @Camera_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Camera
  CompilerIf Defined(Camera_Camera, #PB_Procedure) = #True
    Camera_Camera(*this)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructGameInterface()
  Protected *this.sGameInterface = AllocateMemory(SizeOf(sGameInterface))
  Protected *thisM.GameInterface = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_GameInterface And SizeOf(GameInterface)
    _VT_GameInterface = AllocateMemory(SizeOf(GameInterface)) ; Global virtual table
    CompilerIf Defined(GameInterface_PlayerDead, #PB_Procedure)
      PokeL(_VT_GameInterface + OffsetOf(GameInterface\PlayerDead()), @GameInterface_PlayerDead())
    CompilerEndIf
    CompilerIf Defined(GameInterface_PlayerHitSavePoint, #PB_Procedure)
      PokeL(_VT_GameInterface + OffsetOf(GameInterface\PlayerHitSavePoint()), @GameInterface_PlayerHitSavePoint())
    CompilerEndIf
    CompilerIf Defined(GameInterface_PlayerHitWarp, #PB_Procedure)
      PokeL(_VT_GameInterface + OffsetOf(GameInterface\PlayerHitWarp()), @GameInterface_PlayerHitWarp())
    CompilerEndIf
    CompilerIf Defined(GameInterface_AddLife, #PB_Procedure)
      PokeL(_VT_GameInterface + OffsetOf(GameInterface\AddLife()), @GameInterface_AddLife())
    CompilerEndIf
    CompilerIf Defined(GameInterface_AddCoin, #PB_Procedure)
      PokeL(_VT_GameInterface + OffsetOf(GameInterface\AddCoin()), @GameInterface_AddCoin())
    CompilerEndIf
    CompilerIf Defined(GameInterface_GetPlayer, #PB_Procedure)
      PokeL(_VT_GameInterface + OffsetOf(GameInterface\GetPlayer()), @GameInterface_GetPlayer())
    CompilerEndIf
    CompilerIf Defined(GameInterface_GetEntities, #PB_Procedure)
      PokeL(_VT_GameInterface + OffsetOf(GameInterface\GetEntities()), @GameInterface_GetEntities())
    CompilerEndIf
    CompilerIf Defined(GameInterface_GetMap, #PB_Procedure)
      PokeL(_VT_GameInterface + OffsetOf(GameInterface\GetMap()), @GameInterface_GetMap())
    CompilerEndIf
    CompilerIf Defined(GameInterface_AddEntity, #PB_Procedure)
      PokeL(_VT_GameInterface + OffsetOf(GameInterface\AddEntity()), @GameInterface_AddEntity())
    CompilerEndIf
    CompilerIf Defined(GameInterface_GetEntityType, #PB_Procedure)
      PokeL(_VT_GameInterface + OffsetOf(GameInterface\GetEntityType()), @GameInterface_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(GameInterface_CreateEntity, #PB_Procedure)
      PokeL(_VT_GameInterface + OffsetOf(GameInterface\CreateEntity()), @GameInterface_CreateEntity())
    CompilerEndIf
    CompilerIf Defined(GameInterface_Release, #PB_Procedure)
      PokeL(_VT_GameInterface + OffsetOf(GameInterface\Release()), @GameInterface_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_GameInterface
  CompilerIf Defined(GameInterface_GameInterface, #PB_Procedure) = #True
    GameInterface_GameInterface(*this)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructMap(Width.l,Height.l)
  Protected *this.sMap = AllocateMemory(SizeOf(sMap))
  Protected *thisM.Map = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Map And SizeOf(Map)
    _VT_Map = AllocateMemory(SizeOf(Map)) ; Global virtual table
    CompilerIf Defined(Map_Map, #PB_Procedure)
      PokeL(_VT_Map + OffsetOf(Map\Map()), @Map_Map())
    CompilerEndIf
    CompilerIf Defined(Map_Release, #PB_Procedure)
      PokeL(_VT_Map + OffsetOf(Map\Release()), @Map_Release())
    CompilerEndIf
    CompilerIf Defined(Map_AddTileType, #PB_Procedure)
      PokeL(_VT_Map + OffsetOf(Map\AddTileType()), @Map_AddTileType())
    CompilerEndIf
    CompilerIf Defined(Map_GetTileType, #PB_Procedure)
      PokeL(_VT_Map + OffsetOf(Map\GetTileType()), @Map_GetTileType())
    CompilerEndIf
    CompilerIf Defined(Map_GetTileTypes, #PB_Procedure)
      PokeL(_VT_Map + OffsetOf(Map\GetTileTypes()), @Map_GetTileTypes())
    CompilerEndIf
    CompilerIf Defined(Map_GetTile, #PB_Procedure)
      PokeL(_VT_Map + OffsetOf(Map\GetTile()), @Map_GetTile())
    CompilerEndIf
    CompilerIf Defined(Map_SetTile, #PB_Procedure)
      PokeL(_VT_Map + OffsetOf(Map\SetTile()), @Map_SetTile())
    CompilerEndIf
    CompilerIf Defined(Map_GetWidth, #PB_Procedure)
      PokeL(_VT_Map + OffsetOf(Map\GetWidth()), @Map_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Map_GetHeight, #PB_Procedure)
      PokeL(_VT_Map + OffsetOf(Map\GetHeight()), @Map_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Map_Render, #PB_Procedure)
      PokeL(_VT_Map + OffsetOf(Map\Render()), @Map_Render())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Map
  CompilerIf Defined(Map_Map, #PB_Procedure) = #True
    Map_Map(*this, Width, Height)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructEntity()
  Protected *this.sEntity = AllocateMemory(SizeOf(sEntity))
  Protected *thisM.Entity = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Entity And SizeOf(Entity)
    _VT_Entity = AllocateMemory(SizeOf(Entity)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_IterateAttributes, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\IterateAttributes()), @Entity_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_Kill, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\Kill()), @Entity_Kill())
    CompilerEndIf
    CompilerIf Defined(Entity_Update, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\Update()), @Entity_Update())
    CompilerEndIf
    CompilerIf Defined(Entity_Render, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\Render()), @Entity_Render())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_Entity + OffsetOf(Entity\Release()), @Entity_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Entity
  CompilerIf Defined(Entity_Entity, #PB_Procedure) = #True
    Entity_Entity(*this)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructGoomba(X.l,Y.l)
  Protected *this.sGoomba = AllocateMemory(SizeOf(sGoomba))
  Protected *thisM.Goomba = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Goomba And SizeOf(Goomba)
    _VT_Goomba = AllocateMemory(SizeOf(Goomba)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(Goomba_Goomba, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\Goomba()), @Goomba_Goomba())
    CompilerEndIf
    CompilerIf Defined(Goomba_IterateAttributes, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\IterateAttributes()), @Goomba_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Goomba_Kill, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\Kill()), @Goomba_Kill())
    CompilerEndIf
    CompilerIf Defined(Goomba_Update, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\Update()), @Goomba_Update())
    CompilerEndIf
    CompilerIf Defined(Goomba_Render, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\Render()), @Goomba_Render())
    CompilerEndIf
    CompilerIf Defined(Goomba_Release, #PB_Procedure)
      PokeL(_VT_Goomba + OffsetOf(Goomba\Release()), @Goomba_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Goomba
  CompilerIf Defined(Goomba_Goomba, #PB_Procedure) = #True
    Goomba_Goomba(*this, X, Y)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructBomb(X.l,Y.l)
  Protected *this.sBomb = AllocateMemory(SizeOf(sBomb))
  Protected *thisM.Bomb = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Bomb And SizeOf(Bomb)
    _VT_Bomb = AllocateMemory(SizeOf(Bomb)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_IterateAttributes, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\IterateAttributes()), @Entity_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_Kill, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\Kill()), @Entity_Kill())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(Bomb_Bomb, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\Bomb()), @Bomb_Bomb())
    CompilerEndIf
    CompilerIf Defined(Bomb_Update, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\Update()), @Bomb_Update())
    CompilerEndIf
    CompilerIf Defined(Bomb_Render, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\Render()), @Bomb_Render())
    CompilerEndIf
    CompilerIf Defined(Bomb_IsExploding, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\IsExploding()), @Bomb_IsExploding())
    CompilerEndIf
    CompilerIf Defined(Bomb_Release, #PB_Procedure)
      PokeL(_VT_Bomb + OffsetOf(Bomb\Release()), @Bomb_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Bomb
  CompilerIf Defined(Bomb_Bomb, #PB_Procedure) = #True
    Bomb_Bomb(*this, X, Y)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructTortoise(X.l,Y.l)
  Protected *this.sTortoise = AllocateMemory(SizeOf(sTortoise))
  Protected *thisM.Tortoise = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Tortoise And SizeOf(Tortoise)
    _VT_Tortoise = AllocateMemory(SizeOf(Tortoise)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_IterateAttributes, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\IterateAttributes()), @Entity_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(Tortoise_Tortoise, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\Tortoise()), @Tortoise_Tortoise())
    CompilerEndIf
    CompilerIf Defined(Tortoise_Kill, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\Kill()), @Tortoise_Kill())
    CompilerEndIf
    CompilerIf Defined(Tortoise_Update, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\Update()), @Tortoise_Update())
    CompilerEndIf
    CompilerIf Defined(Tortoise_Render, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\Render()), @Tortoise_Render())
    CompilerEndIf
    CompilerIf Defined(Tortoise_Release, #PB_Procedure)
      PokeL(_VT_Tortoise + OffsetOf(Tortoise\Release()), @Tortoise_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Tortoise
  CompilerIf Defined(Tortoise_Tortoise, #PB_Procedure) = #True
    Tortoise_Tortoise(*this, X, Y)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructFly(X.l,Y.l)
  Protected *this.sFly = AllocateMemory(SizeOf(sFly))
  Protected *thisM.Fly = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Fly And SizeOf(Fly)
    _VT_Fly = AllocateMemory(SizeOf(Fly)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_IterateAttributes, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\IterateAttributes()), @Entity_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(Fly_Fly, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\Fly()), @Fly_Fly())
    CompilerEndIf
    CompilerIf Defined(Fly_Kill, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\Kill()), @Fly_Kill())
    CompilerEndIf
    CompilerIf Defined(Fly_Update, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\Update()), @Fly_Update())
    CompilerEndIf
    CompilerIf Defined(Fly_Render, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\Render()), @Fly_Render())
    CompilerEndIf
    CompilerIf Defined(Fly_Release, #PB_Procedure)
      PokeL(_VT_Fly + OffsetOf(Fly\Release()), @Fly_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Fly
  CompilerIf Defined(Fly_Fly, #PB_Procedure) = #True
    Fly_Fly(*this, X, Y)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructRocket(X.l,Y.l)
  Protected *this.sRocket = AllocateMemory(SizeOf(sRocket))
  Protected *thisM.Rocket = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Rocket And SizeOf(Rocket)
    _VT_Rocket = AllocateMemory(SizeOf(Rocket)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(Rocket_Rocket, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\Rocket()), @Rocket_Rocket())
    CompilerEndIf
    CompilerIf Defined(Rocket_IterateAttributes, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\IterateAttributes()), @Rocket_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Rocket_Init, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\Init()), @Rocket_Init())
    CompilerEndIf
    CompilerIf Defined(Rocket_Kill, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\Kill()), @Rocket_Kill())
    CompilerEndIf
    CompilerIf Defined(Rocket_Update, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\Update()), @Rocket_Update())
    CompilerEndIf
    CompilerIf Defined(Rocket_Render, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\Render()), @Rocket_Render())
    CompilerEndIf
    CompilerIf Defined(Rocket_Release, #PB_Procedure)
      PokeL(_VT_Rocket + OffsetOf(Rocket\Release()), @Rocket_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Rocket
  CompilerIf Defined(Rocket_Rocket, #PB_Procedure) = #True
    Rocket_Rocket(*this, X, Y)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructFireball(X.l,Y.l)
  Protected *this.sFireball = AllocateMemory(SizeOf(sFireball))
  Protected *thisM.Fireball = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Fireball And SizeOf(Fireball)
    _VT_Fireball = AllocateMemory(SizeOf(Fireball)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_IterateAttributes, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\IterateAttributes()), @Entity_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_Kill, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\Kill()), @Entity_Kill())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(Fireball_Fireball, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\Fireball()), @Fireball_Fireball())
    CompilerEndIf
    CompilerIf Defined(Fireball_Update, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\Update()), @Fireball_Update())
    CompilerEndIf
    CompilerIf Defined(Fireball_Render, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\Render()), @Fireball_Render())
    CompilerEndIf
    CompilerIf Defined(Fireball_Release, #PB_Procedure)
      PokeL(_VT_Fireball + OffsetOf(Fireball\Release()), @Fireball_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Fireball
  CompilerIf Defined(Fireball_Fireball, #PB_Procedure) = #True
    Fireball_Fireball(*this, X, Y)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructWarp(X.l,Y.l)
  Protected *this.sWarp = AllocateMemory(SizeOf(sWarp))
  Protected *thisM.Warp = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Warp And SizeOf(Warp)
    _VT_Warp = AllocateMemory(SizeOf(Warp)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_Kill, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\Kill()), @Entity_Kill())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(Warp_Warp, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\Warp()), @Warp_Warp())
    CompilerEndIf
    CompilerIf Defined(Warp_Release, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\Release()), @Warp_Release())
    CompilerEndIf
    CompilerIf Defined(Warp_IterateAttributes, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\IterateAttributes()), @Warp_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Warp_GetTarget, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\GetTarget()), @Warp_GetTarget())
    CompilerEndIf
    CompilerIf Defined(Warp_SetTarget, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\SetTarget()), @Warp_SetTarget())
    CompilerEndIf
    CompilerIf Defined(Warp_Update, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\Update()), @Warp_Update())
    CompilerEndIf
    CompilerIf Defined(Warp_Render, #PB_Procedure)
      PokeL(_VT_Warp + OffsetOf(Warp\Render()), @Warp_Render())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Warp
  CompilerIf Defined(Warp_Warp, #PB_Procedure) = #True
    Warp_Warp(*this, X, Y)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructBoss(X.l,Y.l)
  Protected *this.sBoss = AllocateMemory(SizeOf(sBoss))
  Protected *thisM.Boss = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Boss And SizeOf(Boss)
    _VT_Boss = AllocateMemory(SizeOf(Boss)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_IterateAttributes, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\IterateAttributes()), @Entity_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_Kill, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\Kill()), @Entity_Kill())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(Boss_Boss, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\Boss()), @Boss_Boss())
    CompilerEndIf
    CompilerIf Defined(Boss_Update, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\Update()), @Boss_Update())
    CompilerEndIf
    CompilerIf Defined(Boss_Render, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\Render()), @Boss_Render())
    CompilerEndIf
    CompilerIf Defined(Boss_FuckMe, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\FuckMe()), @Boss_FuckMe())
    CompilerEndIf
    CompilerIf Defined(Boss_Release, #PB_Procedure)
      PokeL(_VT_Boss + OffsetOf(Boss\Release()), @Boss_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Boss
  CompilerIf Defined(Boss_Boss, #PB_Procedure) = #True
    Boss_Boss(*this, X, Y)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructShoot(X.l,Y.l,SpeedX.l,SpeedY.l)
  Protected *this.sShoot = AllocateMemory(SizeOf(sShoot))
  Protected *thisM.Shoot = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Shoot And SizeOf(Shoot)
    _VT_Shoot = AllocateMemory(SizeOf(Shoot)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_IterateAttributes, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\IterateAttributes()), @Entity_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_Kill, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\Kill()), @Entity_Kill())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(Shoot_Shoot, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\Shoot()), @Shoot_Shoot())
    CompilerEndIf
    CompilerIf Defined(Shoot_Update, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\Update()), @Shoot_Update())
    CompilerEndIf
    CompilerIf Defined(Shoot_Render, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\Render()), @Shoot_Render())
    CompilerEndIf
    CompilerIf Defined(Shoot_Release, #PB_Procedure)
      PokeL(_VT_Shoot + OffsetOf(Shoot\Release()), @Shoot_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Shoot
  CompilerIf Defined(Shoot_Shoot, #PB_Procedure) = #True
    Shoot_Shoot(*this, X, Y, SpeedX, SpeedY)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructSavePoint(X.l,Y.l)
  Protected *this.sSavePoint = AllocateMemory(SizeOf(sSavePoint))
  Protected *thisM.SavePoint = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_SavePoint And SizeOf(SavePoint)
    _VT_SavePoint = AllocateMemory(SizeOf(SavePoint)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_IterateAttributes, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\IterateAttributes()), @Entity_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_Kill, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\Kill()), @Entity_Kill())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(SavePoint_SavePoint, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\SavePoint()), @SavePoint_SavePoint())
    CompilerEndIf
    CompilerIf Defined(SavePoint_Update, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\Update()), @SavePoint_Update())
    CompilerEndIf
    CompilerIf Defined(SavePoint_Render, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\Render()), @SavePoint_Render())
    CompilerEndIf
    CompilerIf Defined(SavePoint_IsActivated, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\IsActivated()), @SavePoint_IsActivated())
    CompilerEndIf
    CompilerIf Defined(SavePoint_Activate, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\Activate()), @SavePoint_Activate())
    CompilerEndIf
    CompilerIf Defined(SavePoint_Release, #PB_Procedure)
      PokeL(_VT_SavePoint + OffsetOf(SavePoint\Release()), @SavePoint_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_SavePoint
  CompilerIf Defined(SavePoint_SavePoint, #PB_Procedure) = #True
    SavePoint_SavePoint(*this, X, Y)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructPlatform(X.l,Y.l)
  Protected *this.sPlatform = AllocateMemory(SizeOf(sPlatform))
  Protected *thisM.Platform = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Platform And SizeOf(Platform)
    _VT_Platform = AllocateMemory(SizeOf(Platform)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_Kill, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\Kill()), @Entity_Kill())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(Platform_Platform, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\Platform()), @Platform_Platform())
    CompilerEndIf
    CompilerIf Defined(Platform_IterateAttributes, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\IterateAttributes()), @Platform_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Platform_Init, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\Init()), @Platform_Init())
    CompilerEndIf
    CompilerIf Defined(Platform_Update, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\Update()), @Platform_Update())
    CompilerEndIf
    CompilerIf Defined(Platform_Render, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\Render()), @Platform_Render())
    CompilerEndIf
    CompilerIf Defined(Platform_Release, #PB_Procedure)
      PokeL(_VT_Platform + OffsetOf(Platform\Release()), @Platform_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Platform
  CompilerIf Defined(Platform_Platform, #PB_Procedure) = #True
    Platform_Platform(*this, X, Y)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructPowerUp(PowerUpType.l)
  Protected *this.sPowerUp = AllocateMemory(SizeOf(sPowerUp))
  Protected *thisM.PowerUp = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_PowerUp And SizeOf(PowerUp)
    _VT_PowerUp = AllocateMemory(SizeOf(PowerUp)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_IterateAttributes, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\IterateAttributes()), @Entity_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_Kill, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\Kill()), @Entity_Kill())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(PowerUp_PowerUp, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\PowerUp()), @PowerUp_PowerUp())
    CompilerEndIf
    CompilerIf Defined(PowerUp_Update, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\Update()), @PowerUp_Update())
    CompilerEndIf
    CompilerIf Defined(PowerUp_Render, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\Render()), @PowerUp_Render())
    CompilerEndIf
    CompilerIf Defined(PowerUp_GetPowerUpType, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\GetPowerUpType()), @PowerUp_GetPowerUpType())
    CompilerEndIf
    CompilerIf Defined(PowerUp_Release, #PB_Procedure)
      PokeL(_VT_PowerUp + OffsetOf(PowerUp\Release()), @PowerUp_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_PowerUp
  CompilerIf Defined(PowerUp_PowerUp, #PB_Procedure) = #True
    PowerUp_PowerUp(*this, PowerUpType)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructCoin(X.l,Y.l)
  Protected *this.sCoin = AllocateMemory(SizeOf(sCoin))
  Protected *thisM.Coin = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Coin And SizeOf(Coin)
    _VT_Coin = AllocateMemory(SizeOf(Coin)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_IterateAttributes, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\IterateAttributes()), @Entity_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_Kill, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\Kill()), @Entity_Kill())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(Coin_Coin, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\Coin()), @Coin_Coin())
    CompilerEndIf
    CompilerIf Defined(Coin_Update, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\Update()), @Coin_Update())
    CompilerEndIf
    CompilerIf Defined(Coin_Render, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\Render()), @Coin_Render())
    CompilerEndIf
    CompilerIf Defined(Coin_Release, #PB_Procedure)
      PokeL(_VT_Coin + OffsetOf(Coin\Release()), @Coin_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Coin
  CompilerIf Defined(Coin_Coin, #PB_Procedure) = #True
    Coin_Coin(*this, X, Y)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructCoinBlink(X.l,Y.l)
  Protected *this.sCoinBlink = AllocateMemory(SizeOf(sCoinBlink))
  Protected *thisM.CoinBlink = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_CoinBlink And SizeOf(CoinBlink)
    _VT_CoinBlink = AllocateMemory(SizeOf(CoinBlink)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_IterateAttributes, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\IterateAttributes()), @Entity_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_Kill, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\Kill()), @Entity_Kill())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(CoinBlink_CoinBlink, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\CoinBlink()), @CoinBlink_CoinBlink())
    CompilerEndIf
    CompilerIf Defined(CoinBlink_Update, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\Update()), @CoinBlink_Update())
    CompilerEndIf
    CompilerIf Defined(CoinBlink_Render, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\Render()), @CoinBlink_Render())
    CompilerEndIf
    CompilerIf Defined(CoinBlink_Release, #PB_Procedure)
      PokeL(_VT_CoinBlink + OffsetOf(CoinBlink\Release()), @CoinBlink_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_CoinBlink
  CompilerIf Defined(CoinBlink_CoinBlink, #PB_Procedure) = #True
    CoinBlink_CoinBlink(*this, X, Y)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructSpawner(X.l,Y.l)
  Protected *this.sSpawner = AllocateMemory(SizeOf(sSpawner))
  Protected *thisM.Spawner = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Spawner And SizeOf(Spawner)
    _VT_Spawner = AllocateMemory(SizeOf(Spawner)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_Kill, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\Kill()), @Entity_Kill())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(Spawner_Spawner, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\Spawner()), @Spawner_Spawner())
    CompilerEndIf
    CompilerIf Defined(Spawner_Release, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\Release()), @Spawner_Release())
    CompilerEndIf
    CompilerIf Defined(Spawner_IterateAttributes, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\IterateAttributes()), @Spawner_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Spawner_Update, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\Update()), @Spawner_Update())
    CompilerEndIf
    CompilerIf Defined(Spawner_Render, #PB_Procedure)
      PokeL(_VT_Spawner + OffsetOf(Spawner\Render()), @Spawner_Render())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Spawner
  CompilerIf Defined(Spawner_Spawner, #PB_Procedure) = #True
    Spawner_Spawner(*this, X, Y)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructKiller(X.l,Y.l)
  Protected *this.sKiller = AllocateMemory(SizeOf(sKiller))
  Protected *thisM.Killer = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Killer And SizeOf(Killer)
    _VT_Killer = AllocateMemory(SizeOf(Killer)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_IterateAttributes, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\IterateAttributes()), @Entity_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_Kill, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\Kill()), @Entity_Kill())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(Killer_Killer, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\Killer()), @Killer_Killer())
    CompilerEndIf
    CompilerIf Defined(Killer_Update, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\Update()), @Killer_Update())
    CompilerEndIf
    CompilerIf Defined(Killer_Render, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\Render()), @Killer_Render())
    CompilerEndIf
    CompilerIf Defined(Killer_Release, #PB_Procedure)
      PokeL(_VT_Killer + OffsetOf(Killer\Release()), @Killer_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Killer
  CompilerIf Defined(Killer_Killer, #PB_Procedure) = #True
    Killer_Killer(*this, X, Y)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructPlayer(X.l,Y.l)
  Protected *this.sPlayer = AllocateMemory(SizeOf(sPlayer))
  Protected *thisM.Player = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Player And SizeOf(Player)
    _VT_Player = AllocateMemory(SizeOf(Player)) ; Global virtual table
    CompilerIf Defined(Entity_Entity, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\Entity()), @Entity_Entity())
    CompilerEndIf
    CompilerIf Defined(Entity_IterateAttributes, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\IterateAttributes()), @Entity_IterateAttributes())
    CompilerEndIf
    CompilerIf Defined(Entity_Init, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\Init()), @Entity_Init())
    CompilerEndIf
    CompilerIf Defined(Entity_Kill, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\Kill()), @Entity_Kill())
    CompilerEndIf
    CompilerIf Defined(Entity_GetX, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\GetX()), @Entity_GetX())
    CompilerEndIf
    CompilerIf Defined(Entity_GetY, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\GetY()), @Entity_GetY())
    CompilerEndIf
    CompilerIf Defined(Entity_SetX, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\SetX()), @Entity_SetX())
    CompilerEndIf
    CompilerIf Defined(Entity_SetY, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\SetY()), @Entity_SetY())
    CompilerEndIf
    CompilerIf Defined(Entity_GetWidth, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\GetWidth()), @Entity_GetWidth())
    CompilerEndIf
    CompilerIf Defined(Entity_GetHeight, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\GetHeight()), @Entity_GetHeight())
    CompilerEndIf
    CompilerIf Defined(Entity_GetType, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\GetType()), @Entity_GetType())
    CompilerEndIf
    CompilerIf Defined(Entity_GetEntityType, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\GetEntityType()), @Entity_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Entity_IsActive, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\IsActive()), @Entity_IsActive())
    CompilerEndIf
    CompilerIf Defined(Entity_IsSolid, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\IsSolid()), @Entity_IsSolid())
    CompilerEndIf
    CompilerIf Defined(Entity_CheckTileCollision, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\CheckTileCollision()), @Entity_CheckTileCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsMapCollision, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\IsMapCollision()), @Entity_IsMapCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_IsEntityCollision, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\IsEntityCollision()), @Entity_IsEntityCollision())
    CompilerEndIf
    CompilerIf Defined(Entity_Move, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\Move()), @Entity_Move())
    CompilerEndIf
    CompilerIf Defined(Entity_RequestRemoval, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\RequestRemoval()), @Entity_RequestRemoval())
    CompilerEndIf
    CompilerIf Defined(Entity_ShallBeRemoved, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\ShallBeRemoved()), @Entity_ShallBeRemoved())
    CompilerEndIf
    CompilerIf Defined(Entity_Release, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\Release()), @Entity_Release())
    CompilerEndIf
    CompilerIf Defined(Player__SetBig, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\_SetBig()), @Player__SetBig())
    CompilerEndIf
    CompilerIf Defined(Player_Player, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\Player()), @Player_Player())
    CompilerEndIf
    CompilerIf Defined(Player_Update, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\Update()), @Player_Update())
    CompilerEndIf
    CompilerIf Defined(Player_Render, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\Render()), @Player_Render())
    CompilerEndIf
    CompilerIf Defined(Player_OnRespawn, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\OnRespawn()), @Player_OnRespawn())
    CompilerEndIf
    CompilerIf Defined(Player_CheckDead, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\CheckDead()), @Player_CheckDead())
    CompilerEndIf
    CompilerIf Defined(Player_Release, #PB_Procedure)
      PokeL(_VT_Player + OffsetOf(Player\Release()), @Player_Release())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Player
  CompilerIf Defined(Player_Player, #PB_Procedure) = #True
    Player_Player(*this, X, Y)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure

Procedure ConstructGame()
  Protected *this.sGame = AllocateMemory(SizeOf(sGame))
  Protected *thisM.Game = *this
  If Not *this : ProcedureReturn #False : EndIf
  If Not _VT_Game And SizeOf(Game)
    _VT_Game = AllocateMemory(SizeOf(Game)) ; Global virtual table
    CompilerIf Defined(GameInterface_Release, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\Release()), @GameInterface_Release())
    CompilerEndIf
    CompilerIf Defined(Game_Game, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\Game()), @Game_Game())
    CompilerEndIf
    CompilerIf Defined(Game_Release, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\Release()), @Game_Release())
    CompilerEndIf
    CompilerIf Defined(Game_GetEntityTypes, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\GetEntityTypes()), @Game_GetEntityTypes())
    CompilerEndIf
    CompilerIf Defined(Game_GetCamera, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\GetCamera()), @Game_GetCamera())
    CompilerEndIf
    CompilerIf Defined(Game_GetMap, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\GetMap()), @Game_GetMap())
    CompilerEndIf
    CompilerIf Defined(Game_GetEntities, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\GetEntities()), @Game_GetEntities())
    CompilerEndIf
    CompilerIf Defined(Game_Free, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\Free()), @Game_Free())
    CompilerEndIf
    CompilerIf Defined(Game_Init, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\Init()), @Game_Init())
    CompilerEndIf
    CompilerIf Defined(Game_Load, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\Load()), @Game_Load())
    CompilerEndIf
    CompilerIf Defined(Game_Save, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\Save()), @Game_Save())
    CompilerEndIf
    CompilerIf Defined(Game_AddEntityType, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\AddEntityType()), @Game_AddEntityType())
    CompilerEndIf
    CompilerIf Defined(Game_GetEntityType, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\GetEntityType()), @Game_GetEntityType())
    CompilerEndIf
    CompilerIf Defined(Game_CreateEntity, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\CreateEntity()), @Game_CreateEntity())
    CompilerEndIf
    CompilerIf Defined(Game_PlayerDead, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\PlayerDead()), @Game_PlayerDead())
    CompilerEndIf
    CompilerIf Defined(Game_PlayerHitSavePoint, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\PlayerHitSavePoint()), @Game_PlayerHitSavePoint())
    CompilerEndIf
    CompilerIf Defined(Game_PlayerHitWarp, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\PlayerHitWarp()), @Game_PlayerHitWarp())
    CompilerEndIf
    CompilerIf Defined(Game_AddLife, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\AddLife()), @Game_AddLife())
    CompilerEndIf
    CompilerIf Defined(Game_AddCoin, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\AddCoin()), @Game_AddCoin())
    CompilerEndIf
    CompilerIf Defined(Game_GetPlayer, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\GetPlayer()), @Game_GetPlayer())
    CompilerEndIf
    CompilerIf Defined(Game_AddEntity, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\AddEntity()), @Game_AddEntity())
    CompilerEndIf
    CompilerIf Defined(Game_CheckMusic, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\CheckMusic()), @Game_CheckMusic())
    CompilerEndIf
    CompilerIf Defined(Game_Update, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\Update()), @Game_Update())
    CompilerEndIf
    CompilerIf Defined(Game_Render, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\Render()), @Game_Render())
    CompilerEndIf
    CompilerIf Defined(Game_RenderHud, #PB_Procedure)
      PokeL(_VT_Game + OffsetOf(Game\RenderHud()), @Game_RenderHud())
    CompilerEndIf
  EndIf
  *this\vt = _VT_Game
  CompilerIf Defined(Game_Game, #PB_Procedure) = #True
    Game_Game(*this)
  CompilerEndIf
  ProcedureReturn *this
EndProcedure


Procedure Camera_Release(*this)
EndProcedure 


Procedure GameInterface_Release(*this)
EndProcedure 


Procedure Entity_Release(*this)
EndProcedure 


Procedure Goomba_Release(*this)
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf
EndProcedure 


Procedure Bomb_Release(*this)
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf
EndProcedure 


Procedure Tortoise_Release(*this)
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf
EndProcedure 


Procedure Fly_Release(*this)
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf
EndProcedure 


Procedure Rocket_Release(*this)
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf
EndProcedure 


Procedure Fireball_Release(*this)
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf
EndProcedure 


Procedure Boss_Release(*this)
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf
EndProcedure 


Procedure Shoot_Release(*this)
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf
EndProcedure 


Procedure SavePoint_Release(*this)
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf
EndProcedure 


Procedure Platform_Release(*this)
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf
EndProcedure 


Procedure PowerUp_Release(*this)
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf
EndProcedure 


Procedure Coin_Release(*this)
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf
EndProcedure 


Procedure CoinBlink_Release(*this)
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf
EndProcedure 


Procedure Killer_Release(*this)
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf
EndProcedure 


Procedure Player_Release(*this)
  CompilerIf Defined(Entity_Release, #PB_Procedure) : Entity_Release(*this) : CompilerEndIf
EndProcedure  
; jaPBe Version=3.8.2.693
; Build=0
; FirstLine=0
; CursorPosition=0
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF