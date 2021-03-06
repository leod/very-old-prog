;=====================================================
; Tomysoft Fontsystem Include V0.4
; 16.03.2005 by Lebostein
;=====================================================
; Mail: Tomysoft@gmx.de
; Page: http://home.arcor.de/tomysoft/
;=====================================================
; Optimized for PureBasic 3.93
;=====================================================

;-----------------------------------------------------
; Font Datei laden [OK]
;-----------------------------------------------------

Procedure FontMapLoad(FileName$)

  ;Sprite laden und pr�fen

  SpriteID = LoadSprite(#PB_Any, FileName$)
  If SpriteID = 0: ProcedureReturn #PB_Default: EndIf

  ;Datei �ffnen und pr�fen

  Length = Len(FileName$) - Len(GetExtensionPart(FileName$))
  FileID = ReadFile(#PB_Any, Left(FileName$, Length) + "FONT")
  If FileID = 0: FreeSprite(SpriteID): ProcedureReturn #PB_Default: EndIf

  ;Neuen Font erstellen und Daten einlesen

  LastElement(FontMap()): AddElement(FontMap())

  FontMap()\back = ReadLong()
  FontMap()\over = ReadLong()
  FontMap()\wide = ReadWord()
  FontMap()\high = ReadWord()
  FontMap()\numx = ReadWord()
  FontMap()\numy = ReadWord()
  FontMap()\lenx = ReadWord()
  FontMap()\leny = ReadWord()

  For Y = 1 To FontMap()\numy
  For X = 1 To FontMap()\numx

  code = ReadWord()
  FontMap()\maxi[code] = ReadWord()
  FontMap()\posx[code] = FontMap()\lenx * (X - 1)
  FontMap()\posy[code] = FontMap()\leny * (Y - 1)

  Next X
  Next Y

  CloseFile(FileID)

  ;Quell-Sprite initialisieren

  FontMap()\imag = SpriteID
  TransparentSpriteColor(FontMap()\imag, Red(FontMap()\back), Green(FontMap()\back), Blue(FontMap()\back))

  ;Mirror-Sprite initialisieren (wenn Vordergrundfarbe aktiv)

  If FontMap()\over <> #PB_Default

  FontMap()\acol = FontMap()\over
  FontMap()\copy = CopySprite(FontMap()\imag, #PB_Any)
  TransparentSpriteColor(FontMap()\imag, Red(FontMap()\over), Green(FontMap()\over), Blue(FontMap()\over))
  TransparentSpriteColor(FontMap()\copy, Red(FontMap()\back), Green(FontMap()\back), Blue(FontMap()\back))

  EndIf

  ;Listenindex als FontID zur�ckgeben

  FontMapCount = CountList(FontMap())

  ProcedureReturn @FontMap();ListIndex(FontMap())

EndProcedure

;-----------------------------------------------------
; L�nge des Textes ermitteln [OK]
;-----------------------------------------------------

Procedure FontMapWide(FontID, Text$)

  ;FontID pr�fen und ausw�hlen

  ;If FontID < 0 Or FontID >= FontMapCount: ProcedureReturn 0: EndIf
  ;SelectElement(FontMap(), FontID)
  ChangeCurrentElement(FontMap(),FontID)

  ;Breite des Textes berechnen

  Count = Len(Text$) - 1
  For CharIndex = 0 To Count
  ASCII = PeekB(@Text$ + CharIndex) & $FF
  If FontMap()\maxi[ASCII] = 0: Continue: EndIf
  PosiX + FontMap()\maxi[ASCII] + FontMap()\wide
  Next CharIndex

  ;Breite des Textes ausgeben

  ProcedureReturn PosiX - FontMap()\wide

EndProcedure

;-----------------------------------------------------
; H�he des Textes ermitteln [OK]
;-----------------------------------------------------

Procedure FontMapHigh(FontID, Text$)

  ;FontID pr�fen und ausw�hlen

  ;If FontID < 0 Or FontID >= FontMapCount: ProcedureReturn 0: EndIf
  ;SelectElement(FontMap(), FontID)
  ChangeCurrentElement(FontMap(),FontID)
  ;H�he des Textes berechnen

  Lines = CountString(Text$, #CR$) + 1
  PosiY = Lines * (FontMap()\leny + FontMap()\high)

  ;H�he des Textes ausgeben

  ProcedureReturn PosiY - FontMap()\high

EndProcedure

;-----------------------------------------------------
; Text ausgeben [OK]
;-----------------------------------------------------

Procedure FontMapOutput(FontID, Text$, PosiX, PosiY, Hori, Vert, RGB)

  ;FontID pr�fen und ausw�hlen

  ;If FontID < 0 Or FontID >= FontMapCount: ProcedureReturn 0: EndIf
  ;SelectElement(FontMap(), FontID)
  ChangeCurrentElement(FontMap(),FontID)
  ;Sprite ausw�hlen

  If FontMap()\over <> #PB_Default: SpriteID = FontMap()\copy: Else: SpriteID = FontMap()\imag: EndIf

  ;Sprite einf�rben (wenn Vordergrundfarbe aktiv)

  If FontMap()\over <> #PB_Default And FontMap()\acol <> RGB

  UseBuffer(FontMap()\copy)
  ClearScreen(RGB & $FF, RGB >> 8 & $FF, RGB >> 16 & $FF)
  DisplayTransparentSprite(FontMap()\imag, 0, 0)
  UseBuffer(#PB_Default)

  FontMap()\acol = RGB: EndIf

  ;Font auf Bildschirm ausgeben

  LineCount = CountString(Text$, #CR$) + 1

  OutPosiY = PosiY

  For LineIndex = 1 To LineCount

  If LineCount = 1: Line$ = Text$: Else: Line$ = StringField(Text$, LineIndex, #CR$): EndIf

  OutPosiX = PosiX

  Count = Len(Line$) - 1
  For CharIndex = 0 To Count
  ASCII = PeekB(@Line$ + CharIndex) & $FF
  If FontMap()\maxi[ASCII] = 0: Continue: EndIf
  ClipSprite(SpriteID, FontMap()\posx[ASCII], FontMap()\posy[ASCII], FontMap()\maxi[ASCII], FontMap()\leny)
  DisplayTransparentSprite(SpriteID, OutPosiX, OutPosiY)
  OutPosiX + FontMap()\maxi[ASCII] + FontMap()\wide
  Next CharIndex

  OutPosiY + FontMap()\high + FontMap()\leny

  Next LineIndex

EndProcedure

;-----------------------------------------------------
; Ende der Include
;----------------------------------------------------- 
; jaPBe Version=2.5.2.24
; Build=0
; FirstLine=135
; CursorPosition=140
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF