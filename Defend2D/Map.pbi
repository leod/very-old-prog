;/
;/Brot
;/Map Proceduren
;/

Procedure NewMap(Width,Height)
    Map\Width = Width
    Map\Height= Height 
    ClearList(SpawnPoint())
    ClearList(WayPoint())
    Dim Map.Tile(Map\Width,Map\Height)
EndProcedure
Procedure LoadMap(file.s)
    file = "Maps\" + file 
    If ReadFile(0,file)
        Map\Name   = ReadString()
        Map\Width  = ReadLong()
        Map\Height = ReadLong()
        NewMap(Map\Width,Map\Height)
        For X = 0 To Map\Width 
            For Y = 0 To Map\Height
                Map(X,Y)\TX = ReadLong()
                Map(X,Y)\TY = ReadLong()
                Map(X,Y)\Coll = ReadLong()
            Next
        Next
        Count = ReadLong()
        ClearList(SpawnPoint())
        For I = 0 To Count - 1
            AddElement(SpawnPoint())
            SpawnPoint()\X = ReadLong()
            SpawnPoint()\Y = ReadLong()
            SpawnPoint()\Team = ReadLong()
        Next
        Count = ReadLong()
        ClearList(WayPoint())
        For I = 0 To Count - 1
            AddElement(WayPoint())
            WayPoint()\X = ReadLong()
            WayPoint()\Y = ReadLong()
        Next
        SelectElement(Player(),1)
        While NextElement(Player())
            DeleteElement(Player(),1)
        Wend
        ClearList(UsedName())
        CloseFile(0)
        ProcedureReturn 1
    Else
        ProcedureReturn 0
    EndIf
EndProcedure
Procedure SaveMap(file.s)
    file = "Maps\" + file 
    If CreateFile(0,file)
        WriteStringN(Map\Name)
        WriteLong(Map\Width)
        WriteLong(Map\Height)
        For X = 0 To Map\Width
            For Y = 0 To Map\Height
                WriteLong(Map(X,Y)\TX)
                WriteLong(Map(X,Y)\TY)
                WriteLong(Map(X,Y)\Coll)
            Next
        Next
        WriteLong(CountList(SpawnPoint()))
        ForEach SpawnPoint()
            WriteLong(SpawnPoint()\X)
            WriteLong(SpawnPoint()\Y)
            WriteLong(SpawnPoint()\Team)
        Next
        WriteLong(CountList(WayPoint()))
        ForEach WayPoint()
            WriteLong(WayPoint()\X)
            WriteLong(WayPoint()\Y)
        Next
        CloseFile(0)
        ProcedureReturn 1
    Else
        ProcedureReturn 0
    EndIf 
EndProcedure
Procedure DisplayMap()
    For X = 0 To Map\Width - 1 
        For Y = 0 To Map\Height - 1
            ClipSprite(#Sprite_Tileset,Map(X,Y)\TX*#TileWidth,Map(X,Y)\TY*#TileHeight,#TileWidth,#TileHeight)
            DisplaySprite(#Sprite_Tileset,X*#TileWidth+Map\CamX,Y*#TileHeight+Map\CamY)
            If Map(X,Y)\Coll = 1
                ForEach Shoot()
                    If SpriteCollision(#Sprite_Shoot,Shoot()\X,Shoot()\Y,#Sprite_Tileset,X*#TileWidth+Map\CamX,Y*#TileHeight+Map\CamY)
                        If Random(5) = 0
                            Sound(#Sound_BulletIndex+Random(6),Shoot()\X,Shoot()\Y)
                        EndIf 
                        NewSmoke(Shoot()\X-Map\CamX-16,Shoot()\Y-Map\CamY-16)
                        DeleteElement(Shoot())
                    EndIf
                Next
            EndIf 
        Next
    Next
EndProcedure
Procedure EditorDisplaySpawnPoints()
    ForEach SpawnPoint()
        DisplayTransparentSprite(#Sprite_SpawnPoint+SpawnPoint()\Team,SpawnPoint()\X+Map\CamX,SpawnPoint()\Y+Map\CamY)
    Next
EndProcedure
Procedure EditorDisplayMap()
    For X = 0 To Map\Width - 1
        For Y = 0 To Map\Height - 1
            ClipSprite(#Sprite_Tileset,Map(X,Y)\TX*#TileWidth,Map(X,Y)\TY*#TileHeight,#TileWidth,#TileHeight)
            DisplaySprite(#Sprite_Tileset,X*#TileWidth+Map\CamX,Y*#TileHeight+Map\CamY)
            If Map(X,Y)\Coll = 1
                DisplaySprite(#Sprite_IsColl,X*#TileWidth+Map\CamX,Y*#TileHeight+Map\CamY)
            EndIf 
        Next
    Next
EndProcedure
Procedure EditorDisplayWayPoints()
    ForEach WayPoint()
        DisplayTransparentSprite(#Sprite_WayPoint,WayPoint()\X+Map\CamX,WayPoint()\Y+Map\CamY)
    Next
EndProcedure 
; jaPBe Version=2.5.2.24
; FoldLines=0005000B000C00330034005100650069006A007400750079
; Build=0
; FirstLine=0
; CursorPosition=86
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF