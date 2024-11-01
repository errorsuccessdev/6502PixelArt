define white $01 ; The number 1
define green $05 ; The number 5
define lblue $03 ; The number 3
define dblue $06 ; The number 6
define ltgrn $0d ; The number 13
define blue  $0e ; The number 14
; 
define sysRandom  $fe ; Address of random number
define sysLastKey $ff

define mouseLow  $10
define mouseHigh $11
define mouseMove $12

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
LDA #midPixelLow
STA mouseLow
LDA #midPixelHigh
STA mouseHigh
JSR drawMouse

loop:
  JSR doMovement
  JSR sleep
JMP loop

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
   STA mouseMove
   JSR moveMouse
RTS

downKey:
   LDA #32
   STA mouseMove
   JSR moveMouse
RTS

leftKey:
   LDA #$ff 
   STA mouseMove
   JSR moveMouse
RTS

upKey:
   LDA #$e0 ; TBD
   STA mouseMove
   JSR moveMouse
RTS

moveMouse:
   JSR clearMouse
   LDA mouseLow
   AND #$f0 ; Keep first 4 bits?
   CMP #$f0
;   BEQ movePage 
   CMP #$e0
 ;  BEQ movePage
   JMP moveLowBit
movePage:
   LDA mouseHigh
   CMP #5
   BEQ setLastKey
   INC mouseHigh
moveLowBit:
   LDA mouseLow
   CLC
   ADC mouseMove ; VARIABLES :D
   STA mouseLow
setLastKey:
   LDA #0
   STA sysLastKey
   JSR drawMouse
RTS

sleep:
  LDX #0
  spinloop:
     NOP
     NOP
     DEX
  BNE spinloop
RTS

getRandom:
  LDA sysRandom
  ; zero out first number? top 4 bits
  AND #$0f
  BEQ getRandom
RTS

drawMouse:
  LDA #white
  LDX #$0
  STA (mouseLow,x)
RTS

clearMouse:
  LDA #0
  LDX #$0
  STA (mouseLow,x)
RTS
