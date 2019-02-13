;/
;/Brot
;/Bomben
;/

Procedure NewBomb(X,Y,OwnerPtr)
    AddElement(Bomb())
    Bomb()\X = X
    Bomb()\Y = Y
    Bomb()\Time = GetTime()
    Bomb()\OwnerPtr = OwnerPtr
    EndProcedure
Procedure DoBomb()
    ForEach Bomb()
        DisplayTranslucideSprite(#Sprite_Bomb,Bomb()\X+Map\CamX,Bomb()\Y+Map\CamY,50)
        If Time(Bomb()\Time) > 10000 Or Bomb()\Explode 
            NewExplosion(Bomb()\X-SpriteWidth(#Sprite_heExplosionIndex)/2,Bomb()\Y-SpriteHeight(#Sprite_heExplosionIndex)/2,#Sprite_heExplosionIndex,Bomb()\OwnerPtr)
            DeleteElement(Bomb())
        EndIf
    Next
EndProcedure 
; jaPBe Version=2.5.2.24
; Build=0
; FirstLine=0
; CursorPosition=16
; ExecutableFormat=Windows
; DontSaveDeclare
; EOF