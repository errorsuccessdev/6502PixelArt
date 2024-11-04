define white $01 ; The number 1
define green $05 ; The number 5
define lblue $03 ; The number 3
define dblue $06 ; The number 6
define ltgrn $0d ; The number 13
define blue  $0e ; The number 14

define sysRandom  $fe ; Address of random number
define sysLastKey $ff

define mouseLow    $10
define mouseHigh   $11
define mouseXcoord $12
define mouseYcoord $13

define previousColor $14

define startMenuXCoord $15
define startMenuYCoord $16
define startMenuLow    $17
define startMenuHigh   $18

; ASCII values of keys controlling the mouse
define ASCII_w      $77
define ASCII_a      $61
define ASCII_s      $73
define ASCII_d      $64

; Pixels are at $0200 to $05ff
; Each row of pixels is 32 bits wide (0-31)
define midPixelLow  $0f ; change back to ef later
define midPixelHigh $02 ; change back to 03 later

;;;;;
; Main
;;;;;

JMP startMenuTempStartLabel

; "Desktop shortcuts"
JSR getRandom
STA $0221
JSR getRandom
STA $0261
JSR getRandom
STA $02a1
JSR getRandom
STA $02e1

; "Taskbar"
LDA #green
STA $05e0
STA $05e1
LDA #blue
LDX #$e2
drawBlueLine:
  STA $0500,x
  INX
BNE drawBlueLine

; "Mouse"
LDA #0
STA previousColor
LDA #$0f
STA mouseXcoord
STA mouseYcoord
JSR moveMouse

; "Start menu"
startMenuTempStartLabel:
LDA #1 
STA startMenuXCoord ; This is getting overwritten to zero somewhere
drawStartMenuAcross:
   LDA #19
   STA startMenuYCoord
   drawStartMenuLine:
      JSR drawStartMenu
      INC startMenuYCoord
      LDA startMenuYCoord
      CMP #31
   BNE drawStartMenuLine
   INC startMenuXCoord
   LDA startMenuXCoord
   CMP #4
BNE drawStartMenuAcross

; Main loop
loop:
  JSR doMovement
JMP loop

drawStartMenu:
  ; Multiply by 32 (yes, really)
  LDA #0
  STA startMenuHigh
  LDA startMenuYCoord 
  STA startMenuLow ; Why was 1 not stored here?

  ASL startMenuLow
  ROL startMenuHigh
  ASL startMenuLow
  ROL startMenuHigh
  ASL startMenuLow
  ROL startMenuHigh
  ASL startMenuLow
  ROL startMenuHigh
  ASL startMenuLow
  ROL startMenuHigh

  ; Add X
  LDA startMenuXcoord
  ADC startMenuLow

  ; Add 0x200
  LDA #$02
  ADC startMenuHigh
  STA startMenuHigh
  
  LDA #white
  LDX #0
  STA (startMenuLow,x)
RTS


; Mouse movement
doMovement: 
  LDA sysLastKey
  CMP #ASCII_d ; Right
  BEQ rightKey
  CMP #ASCII_s ; Down
  BEQ downKey
  CMP #ASCII_a ; Left
  BEQ leftKey
  CMP #ASCII_w ; Up
  BEQ upKey
RTS

rightKey:
   LDA #01
   CLC
   ADC mouseXcoord
   ; don't put X back if it's >= 32
   CMP #$20
   BCS rightKeyEnd ; if X is >=32, skip to the end
   STA mouseXcoord
   JSR moveMouse
rightKeyEnd:
RTS

downKey:
   LDA #01
   CLC
   ADC mouseYcoord
   ; don't put X back if it's >= 32
   CMP #$20
   BCS downKeyEnd ; if X is >=32, skip to the end
   STA mouseYcoord
   JSR moveMouse
downKeyEnd:
RTS

leftKey:
   DEC mouseXcoord
   BPL leftKeyEnd
   INC mouseXcoord
   leftKeyEnd: 
   JSR moveMouse
RTS

upKey:
   DEC mouseYcoord
   BPL upKeyEnd
   INC mouseYcoord
   upKeyEnd: 
   JSR moveMouse
RTS

moveMouse:
  JSR clearMouse

  LDA #0
  STA mouseHigh
  LDA mouseYcoord
  STA mouseLow

  ; Multiply by 32 (yes, really)
  ASL mouseLow
  ROL mouseHigh
  ASL mouseLow
  ROL mouseHigh
  ASL mouseLow
  ROL mouseHigh
  ASL mouseLow
  ROL mouseHigh
  ASL mouseLow
  ROL mouseHigh

  ; Add X
  LDA mouseXcoord
  ADC mouseLow
  STA mouseLow

  ; Add 0x200
  LDA #$02
  ADC mouseHigh
  STA mouseHigh

setLastKey:
   LDA #0
   STA sysLastKey
   JSR drawMouse
RTS

getRandom:
  LDA sysRandom
  ; zero out first number? top 4 bits
  AND #$0f
  BEQ getRandom
RTS

drawMouse:
  LDA (mouseLow,x)
  STA previousColor  
  LDA #white
  LDX #$0
  STA (mouseLow,x)
RTS

clearMouse:
  LDA previousColor
  LDX #$0
  STA (mouseLow,x)
RTS