;/
;/Brot
;/Granaten
;/

Procedure NewGrenade(X.l,Y.l,Angle.l,Limit,OwnerPtr.l)
    AddElement(Grenade())
    Grenade()\X = X
    Grenade()\Y = Y
    Grenade()\MovAngle = Angle 
    Grenade()\Time = GetTime()
    Grenade()\Speed = 13
    Grenade()\Limit = Limit
    Grenade()\OwnerPtr = OwnerPtr
EndProcedure
Procedure DoGrenade()
    ForEach Grenade()
        If Grenade()\StopDisAngle = 0
            ZoomSprite3D(#Sprite_Grenade,SpriteWidth(#Sprite_Grenade)+Grenade()\Zoom,SpriteHeight(#Sprite_Grenade)+Grenade()\Zoom)
            RotateSprite3D(#Sprite_Grenade,Grenade()\DisAngle,1)
        Else
            RotateSprite3D(#Sprite_Grenade,Grenade()\DisAngle,0)
        EndIf 
        DisplaySprite3D(#Sprite_Grenade,Grenade()\X+Map\CamX,Grenade()\Y+Map\CamY)
        ZoomSprite3D(#Sprite_Grenade,SpriteWidth(#Sprite_Grenade),SpriteHeight(#Sprite_Grenade))
        If Grenade()\StopDisAngle = 0
            Grenade()\DisAngle + 10
            If Grenade()\DisAngle > 360
                Grenade()\DisAngle = 0
            EndIf
            If Time(Grenade()\Time) < Grenade()\Limit / 3
                Grenade()\ZoomMode = 1
            Else
                Grenade()\ZoomMode = -1
            EndIf
        EndIf 
        Grenade()\Speed - 0.1
        If Time(Grenade()\Time) > Grenade()\Limit
            Grenade()\Speed = 0
            Grenade()\StopDisAngle = 1
            Grenade()\Zoom = 0
        EndIf
        Grenade()\SpeedX = gCos(Grenade()\MovAngle) * Grenade()\Speed
        Grenade()\SpeedY = gSin(Grenade()\MovAngle) * Grenade()\Speed 
        Grenade()\X + Grenade()\SpeedX
        Grenade()\Y + Grenade()\SpeedY
        Grenade()\Zoom + Grenade()\ZoomMode 
        If Time(Grenade()\Time) > 1600
            NewExplosion(Grenade()\X-SpriteWidth(#Sprite_heExplosionIndex)/2,Grenade()\Y-SpriteHeight(#Sprite_heExplosionIndex)/2,#Sprite_heExplosionIndex,Grenade()\OwnerPtr)
            DeleteElement(Grenade())
        EndIf
    Next
EndProcedure 
; jaPBe Version=2.5.2.24
; FoldLines=0005000E000F0034
; Build=0
; FirstLine=0
; CursorPosition=5
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF