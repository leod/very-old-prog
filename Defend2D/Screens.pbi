;/
;/Brot
;/Screens
;/

Procedure.s ExePath() 
    ExePath$ = Space(2048) 
    GetModuleFileName_(0,@ExePath$,2048) 
    test = 0
    If test = 1
        ProcedureReturn GetPathPart(ExePath$) 
    Else
        ProcedureReturn "C:\Dokumente und Einstellungen\Leo\Desktop\Selobrain\Brot\"
    EndIf 
EndProcedure 
Procedure GetMapFiles()
    ClearList(File())
    ExamineDirectory(0,ExePath()+"maps\","*.map")
    Repeat
        Type = NextDirectoryEntry()
        If Type = 1
            AddElement(File())
            File() = DirectoryEntryName()
        EndIf
    Until Type <> 1    
EndProcedure
Procedure Screen_LoadMap()
    GetMapFiles()
    AddElement(File())
    File() = ""
    AddElement(File())
    File() = "Zur�ck"
    
    Repeat
        ExamineKeyboard()
        ExamineMouse()
        ClearScreen(0,0,0)

        StartDrawing(ScreenOutput())
        DrawingMode(1)
        ForEach File()
            tPosX = 30 
            tPosY = ListIndex(File())*13+20
            Locate(tPosX,tPosY)
            If MouseX() => tPosX And MouseX() <= tPosX + TextLength(File())
                If MouseY() => tPosY And MouseY() <= tPosY + 10
                    If MouseButton(1)
                        If File() <> "" And File() <> "Zur�ck"
                            LoadMap(File())
                            Quit = #True 
                        ElseIf File() = "Zur�ck"
                            Quit = #True 
                        EndIf 
                    EndIf
                    FrontColor(255,0,0)
                Else
                    FrontColor(255,255,255)
                EndIf
            Else
                FrontColor(255,255,255)
            EndIf
            DrawText(File())
        Next
        StopDrawing()
        
        DisplayTransparentSprite(#Sprite_MousePointer,MouseX(),MouseY())
        
        FlipBuffers()
    Until Quit = #True 
    Quit = #False 
EndProcedure
Procedure Screen_SaveMap()
    Name.s = ""
    BackDelay = 0
    Repeat
        ExamineKeyboard()
        ExamineMouse()
        ClearScreen(0,0,0)
        
        StartDrawing(ScreenOutput())
        Locate(30,20)
        DrawingMode(1)
        FrontColor(255,0,0)
        DrawText("Bitte Karten-Name eingeben: ")
        Locate(30,35)
        FrontColor(255,255,255)
        DrawText(Name)
        StopDrawing()
        
        Name + KeyboardInkey()
        If KeyboardReleased(#PB_Key_Back) 
            Name = Mid(Name,0,Len(Name)-1)
        EndIf 
        If KeyboardPushed(#PB_Key_Return)
            If Name
                Quit = #True 
            EndIf
        EndIf
        
        FlipBuffers()
    Until Quit = #True 
    If Name
        If GetExtensionPart(Name) <> "map"
            Name + ".map"
        EndIf
        SaveMap(Name)
    EndIf
    Quit = #False 
EndProcedure
Procedure Screen_NewMap()
    Repeat 
        ExamineKeyboard()
        ClearScreen(0,0,0)
        
        If weiter=0
            key$=key$+KeyboardInkey()
            
            If StartDrawing(ScreenOutput())
                Locate(30,30)
                FrontColor(255,0,0)
                BackColor(0,0,0)
                DrawText("Bitte breite angeben:")
                Locate(30,50)
                DrawText(key$)
                StopDrawing()
            EndIf 
            
            If KeyboardPushed(#PB_Key_Back)
                key$ = Mid(key$,0,Len(key$)-1)
            EndIf
            If KeyboardPushed(#PB_Key_Return) And pressed=0 
                pressed=1
                w=Val(key$)
                key$=""
                weiter=1 
            EndIf 
        EndIf  
        
        If weiter=1
            key$=key$+KeyboardInkey() 
            If StartDrawing(ScreenOutput())
                Locate(30,30)
                FrontColor(255,0,0)
                BackColor(0,0,0)
                DrawText("Bitte h�he angeben:")
                Locate(30,50)
                DrawText(key$)
                StopDrawing()
            EndIf 
            
            If KeyboardPushed(#PB_Key_Back)
                key$ = Mid(key$,0,Len(key$)-1)
            EndIf
            If KeyboardPushed(#PB_Key_Return) And pressed=0
                pressed=1
                h=Val(key$)
                key$=""
                weiter=2 
            EndIf 
        EndIf 
        
        If KeyboardReleased(#PB_Key_Return)
            pressed=0
        EndIf  
        
        If weiter=2
            w-1 
            h-1 
            NewMap(w,h)
            Quit=#True 
        EndIf  
        
        FlipBuffers() 
    Until Quit=#True 
    Quit = #False 
EndProcedure 
Procedure Screen_BotCount()
    Repeat
        ExamineKeyboard()
        ClearScreen(0,0,0)
        
        StartDrawing(ScreenOutput())
        DrawingMode(1)
        FrontColor(255,0,0)
        Locate(30,20)
        DrawText("Bitte anzahl Bots pro Team eingeben: ")
        Locate(30,35)
        DrawText(InputStr.s)
        StopDrawing()
        
        Temp.s = KeyboardInkey()
        TempAsc.l = Asc(Temp)
        If TempAsc => 48 And TempAsc <= 57
            InputStr + Temp
        EndIf
        If KeyboardReleased(#PB_Key_Back)
            InputStr = Mid(InputStr,0,Len(InputStr)-1)
        EndIf
        If KeyboardPushed(#PB_Key_Return)
            Quit = #True 
        EndIf
        
        FlipBuffers()
    Until Quit = #True
    Quit = #False 
    ProcedureReturn Val(InputStr.s)
EndProcedure 
; jaPBe Version=2.5.2.24
; FoldLines=000F0019001A00460047006C006D00AF00B000CE
; Build=0
; FirstLine=0
; CursorPosition=15
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF