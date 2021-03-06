;/
;/Brot
;/Menu Procedure
;/

Declare Game_End()
Declare Game_Info()
Declare Game_MenuSingleplayer()
Declare Game_Back()
Declare Game_ShowInfo()
Declare Game_Options()
Declare Game_MultiPlayer()
Declare Game_Training()
Declare Game_TeamDeathmatch()

Procedure InitMenu()
    ;{Main-Menu
    Menu(#Menu_Main,#MenuItem_SinglePlayer)\SpriteID = #Sprite_Menu_SinglePlayer
    Menu(#Menu_Main,#MenuItem_MultiPlayer)\SpriteID = #Sprite_Menu_MultiPlayer
    Menu(#Menu_Main,#MenuItem_Info)\SpriteID =#Sprite_Menu_Info
    Menu(#Menu_Main,#MenuItem_Editor)\SpriteID = #Sprite_Menu_Editor
    Menu(#Menu_Main,#MenuItem_Options)\SpriteID = #Sprite_Menu_Options
    Menu(#Menu_Main,#MenuItem_End)\SpriteID = #Sprite_Menu_End
    
    Menu(#Menu_Main,#MenuItem_SinglePlayer)\OnClick = @Game_MenuSingleplayer()
    Menu(#Menu_Main,#MenuItem_MultiPlayer)\OnClick = @Game_MultiPlayer()
    Menu(#Menu_Main,#MenuItem_Info)\OnClick = @Game_ShowInfo()
    Menu(#Menu_Main,#MenuItem_Editor)\OnClick = @Game_Editor()
    Menu(#Menu_Main,#MenuItem_Options)\OnClick = @Game_Options()
    Menu(#Menu_Main,#MenuItem_End)\OnClick = @Game_End()
    ;}
    ;{SubMenu-Singleplayer
    Menu(#Menu_Singleplayer,#MenuItem_Training)\SpriteID = #Sprite_Menu_Training
    Menu(#Menu_Singleplayer,#MenuItem_TeamDeathmatch)\SpriteID = #Sprite_Menu_TeamDeathmatch
    Menu(#Menu_Singleplayer,#MenuItem_Back)\SpriteID = #Sprite_Menu_Back
    
    Menu(#Menu_Singleplayer,#MenuItem_Training)\OnClick = @Game_Training()
    Menu(#Menu_Singleplayer,#MenuItem_TeamDeathmatch)\OnClick = @Game_TeamDeathmatch()
    Menu(#Menu_Singleplayer,#MenuItem_Back)\OnClick = @Game_Back()
    ;}
    ProcedureReturn 1
EndProcedure 
Procedure DoMenu(index.l)
    menustate = -1
    menustate_old = -1
    Repeat
        ClearScreen(0,0,0)
        
        ;{-Steuerung
        ExamineKeyboard()
        ExamineMouse()
        mx = MouseX()
        my = MouseY()
        mblnr = MouseButton(1)
        If mbc
            If mblnr = 0
                mbl = 1
            Else
                mbl = 0
            EndIf
        Else
            mbl = 0
        EndIf
        If mblnr
            mbc = 1
        Else
            mbc = 0
        EndIf
        If menustate <> menustate_old And Menu(index,menustate)\SpriteID > 0
            PlaySound(#Sound_MenuChange)
        EndIf
        menustate_old = menustate
        ;}
        ;{-Anzeigen
        DisplaySprite(#Sprite_Menu_BG,0,0)
        For I = 0 To #MenuItems_Count
            If Menu(index,I)\SpriteID > 0
                DisplayTransparentSprite(#Sprite_Menu_Button+Menu(index,I)\State,367-Menu(index,I)\State*70,324+60*I)
                DisplayTransparentSprite(Menu(index,I)\SpriteID,400,324+60*I)
            EndIf
            If mx > 367 And mx < 367 + SpriteWidth(#Sprite_Menu_Button) And my > 324+60*I And my < 324+60*I + SpriteHeight(#Sprite_Menu_Button)
                Menu(index,I)\State = 1
            Else
                Menu(index,I)\State = 0
            EndIf
            If Menu(index,I)\State = 1
                menustate = I
                If mbl And Menu(index,I)\SpriteID > 0
                    CallFunctionFast(Menu(index,I)\OnClick)
                EndIf
            EndIf
        Next
        DisplayTransparentSprite(#Sprite_Menu_MousePointer,mx,my)
        ;}
        
        FlipBuffers()
    Until Quit = #True 
    Quit = #False 
EndProcedure
Procedure Game_Back()
    Quit = #True 
EndProcedure
Procedure Game_End()
    Quit = #True 
EndProcedure
Procedure Game_Training()
    GameMode = #GameMode_Training
    Game_Game()
EndProcedure
Procedure Game_TeamDeathmatch()
    GameMode = #GameMode_TeamDeathmatch
    Game_Game()
EndProcedure
Procedure Game_Menu()
    DoMenu(#Menu_Main)
EndProcedure
Procedure Game_MenuSingleplayer()
    DoMenu(#Menu_Singleplayer)
EndProcedure
Procedure Game_ShowInfo()
    Repeat
        ExamineKeyboard()
        ExamineMouse()
        ClearScreen(0,0,0)
        
        DisplaySprite(#Sprite_InfoField,0,0)
        DisplayTransparentSprite(#Sprite_Menu_MousePointer,MouseX(),MouseY())
        
        FlipBuffers()
    Until KeyboardPushed(1) Or MouseButton(1)
EndProcedure
Procedure Game_Options()
    ;Clear
EndProcedure
Procedure Game_MultiPlayer()
    ;Clear
EndProcedure 
; jaPBe Version=2.5.2.24
; FoldLines=000F002900100000001F0000002A006200300000004900000063006500660068
; FoldLines=0069006C006D00700071007300740076007700820083008500860088
; Build=0
; FirstLine=0
; CursorPosition=134
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF