;/
;/Brot
;/Screenshot
;/

Procedure MakeScreenshot()
    DC.l = GetDC_(0)
    MemDC.l = CreateCompatibleDC_(DC)
    ScreenWidth = GetSystemMetrics_(#SM_CXSCREEN)
    ScreenHeight = GetSystemMetrics_(#SM_CYSCREEN)
    ColorDepth = GetDeviceCaps_(DC,#BITSPIXEL)
    BmpID.l = CreateImage(0,ScreenWidth,ScreenHeight)
    SelectObject_(MemDC, BmpID)
    BitBlt_(MemDC, 0, 0, ScreenWidth, ScreenHeight,DC, 0, 0, #SRCCOPY)
    DeleteDC_(MemDC)
    ReleaseDC_(0,DC)
    StartDrawing(ScreenOutput())
    DrawImage(BmpID,0,0)
    SaveImage(0,"Screenshot" + Str(ScreenshotNr) + ".bmp") 
    StopDrawing()
    ScreenshotNr + 1
EndProcedure 
; jaPBe Version=2.5.2.6
; Build=0
; FirstLine=0
; CursorPosition=11
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF