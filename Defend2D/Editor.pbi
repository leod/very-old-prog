;/
;/Brot
;/Editor
;/

Procedure Game_Editor()
    IsEditor = 1
    NewMap(10,10)
    Repeat
        ExamineMouse()
        ExamineKeyboard()
        ClearScreen(0,0,0)
        
        ;{-Steuerung
        ;{Vorberechnungen
        mx  = MouseX()
        my  = MouseY()
        mbl = MouseButton(1)
        mbr = MouseButton(2)
        tsx = (MouseX() - Map\CamX) / #TileWidth * #TileWidth 
        tsy = (MouseY() - Map\CamY) / #TileHeight* #TileHeight
        ;}
        ;{Tiles setzen
        If mbl = 1
            Editor\LButton = 1
            If mx < #MenuX
                If KeyboardPushed(#PB_Key_LeftShift) = 0
                    Map(tSX/#TileWidth,tSY/#TileHeight)\TX = Editor\ActTile\X
                    Map(tSX/#TileWidth,tSY/#TileHeight)\TY = Editor\ActTile\Y
                    If (Editor\ActTile\X = 0 And Editor\ActTile\Y = 1) Or (Editor\ActTile\X = 2 And Editor\ActTile\Y = 3)
                        Map(tSX/#TileWidth,tSY/#TileHeight)\Coll = 1
                    ElseIf Editor\ActTile\X = 0 And Editor\ActTile\Y = 0 
                        Map(tSX/#TileWidth,tSY/#TileHeight)\Coll = 0
                    EndIf
                Else
                    For X = 0 To Map\Width
                        For Y = 0 To Map\Height
                            If Map(X,Y)\Coll = 0
                                Map(X,Y)\TX = Editor\ActTile\X
                                Map(X,Y)\TY = Editor\ActTile\Y
                            EndIf
                        Next
                    Next
                EndIf
            EndIf
        Else
            Editor\LButton = 0
        EndIf
        ;}
        ;{Kollision setzen
        If mbrw = 1 And mbr = 0
            If mx < #MenuX
                Map(tSX/#TileWidth,tSY/#TileHeight)\Coll ! 1
            EndIf
        EndIf
        If mbr = 1
            mbrw = 1
        Else
            mbrw = 0
        EndIf
        ;}
        ;{Beenden
        If KeyboardPushed(1)
            Quit = #True 
        EndIf
        ;}
        ;{Scrollen
        If KeyboardPushed(#PB_Key_Left)
            Map\CamX + Map\EditorSpeed
        ElseIf KeyboardPushed(#PB_Key_Right)
            Map\CamX - Map\EditorSpeed
        EndIf
        If KeyboardPushed(#PB_Key_Up)
            Map\CamY + Map\EditorSpeed
        ElseIf KeyboardPushed(#PB_Key_Down)
            Map\CamY - Map\EditorSpeed
        EndIf
        If KeyboardPushed(#PB_Key_Pad4)
            Map\CamX + Map\EditorSpeed * 16
        ElseIf KeyboardPushed(#PB_Key_Pad6)
            Map\CamX - Map\EditorSpeed * 16
        EndIf
        If KeyboardPushed(#PB_Key_Pad8)
            Map\CamY + Map\EditorSpeed * 16
        ElseIf KeyboardPushed(#PB_Key_Pad2)
            Map\CamY - Map\EditorSpeed * 16
        EndIf
        If mx < 5
            Map\CamX + Map\EditorSpeed
        ElseIf mx > #ScrWidth - 5     
            Map\CamX - Map\EditorSpeed
        EndIf
        If my < 5
            Map\CamY + Map\EditorSpeed
        ElseIf my > #ScrHeight - 5     
            Map\CamY - Map\EditorSpeed
        EndIf
        ;}
        ;{Buttons
        If IsButtonClicked(Button_Load)
            Screen_LoadMap()
            For I = 0 To 20
                ExamineKeyboard()
                ExamineMouse()
            Next
        EndIf
        If IsButtonClicked(Button_Save)
            Screen_SaveMap()
            For I = 0 To 20
                ExamineKeyboard()
                ExamineMouse()
            Next
        EndIf
        If IsButtonClicked(Button_New)
            Screen_NewMap()
            For I = 0 To 20
                ExamineKeyboard()
                ExamineMouse()
            Next
        EndIf
        ;}
        ;{SpawnPoints / WayPoints - setzen / l�schen
        If KeyboardReleased(#PB_Key_S)
            AddElement(SpawnPoint())
            SpawnPoint()\X = tSX / #TileWidth * #TileWidth
            SpawnPoint()\Y = tSY / #TileHeight* #TileHeight
            SpawnPoint()\Team = 0
        EndIf
        If KeyboardReleased(#PB_Key_X)
            AddElement(SpawnPoint())
            SpawnPoint()\X = tSX / #TileWidth * #TileWidth
            SpawnPoint()\Y = tSY / #TileHeight* #TileHeight
            SpawnPoint()\Team = 1
        EndIf
        If KeyboardReleased(#PB_Key_W)
            AddElement(WayPoint())
            WayPoint()\X = tSX / #TileWidth * #TileWidth
            WayPoint()\Y = tSY / #TileHeight* #TileHeight
        EndIf
        If KeyboardPushed(#PB_Key_D)
            ForEach SpawnPoint()
                If tSX => SpawnPoint()\X And tSX <= SpawnPoint()\X + SpriteWidth(#Sprite_SpawnPoint)
                    DeleteElement(SpawnPoint())
                EndIf
            Next
            ForEach WayPoint()
                If tSX => WayPoint()\X And tSX <= WayPoint()\X + SpriteWidth(#Sprite_WayPoint)
                    DeleteElement(WayPoint())
                EndIf
            Next
        EndIf
        ;}
        ;}        
        ;{-Anzeigen
        EditorDisplayMap()
        EditorDisplaySpawnPoints()
        EditorDisplayWayPoints()
        
        ;{Aktulles Tile an Mausposition anzeigen
        If mx < #MenuX
            ClipSprite(#Sprite_Tileset,Editor\ActTile\X*#TileWidth,Editor\ActTile\Y*#TileHeight,#TileWidth,#TileHeight)
            DisplayTranslucideSprite(#Sprite_Tileset,mx,my,100)
        EndIf
        ;}
        ;{Tiles setzen 
        If mx => #MenuX + 10 And mx <= #MenuX + 10 + Editor\Tileset\w And my => 10 
            If Editor\LButton = 1 
                Editor\IsSettingTile = 1
                Editor\ActTile\X = (mx - #MenuX - 10) / #TileWidth
                Editor\ActTile\Y = (my - 10) / #TileHeight
                
                StartDrawing(SpriteOutput(#Sprite_Tileset_Choose))
                DrawImage(UseImage(#Image_Tileset),0,0)
                DrawingMode(4)
                Box(Editor\ActTile\X*#TileWidth,Editor\ActTile\Y*#TileHeight,#TileWidth,#TileHeight,RGB(0,0,255))
                StopDrawing()
            EndIf
        EndIf
        ;}
        ;{Blaue-Hintergrund Box
        StartDrawing(ScreenOutput())
        DrawingMode(4)
        Box(Map\CamX,Map\CamY,Map\Width*#TileWidth,Map\Height*#TileHeight,RGB(255,0,0))
        DrawingMode(1)
        Box(#MenuX,0,#MenuX,#ScrHeight,RGB(0,0,122))     
        Line(#MenuX,0,0,#ScrHeight,RGB(255,0,0))
        StopDrawing()
        ;}
        
        DisplaySprite(#Sprite_Tileset_Choose,#MenuX+10,10)
        DoButtons()
        DisplayTransparentSprite(#Sprite_MousePointer,mx,my)
        ;}
        
        FlipBuffers()
    Until Quit = #True 
    Quit = #False
EndProcedure 
; jaPBe Version=2.5.2.24
; FoldLines=000D0098000E00000016000000310000003D0000004200000062000000790000
; FoldLines=009900C0009E000000A4000000B30000
; Build=0
; Manual Parameter= /COMMENTED
; FirstLine=0
; CursorPosition=13
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF