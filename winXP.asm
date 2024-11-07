; Ann's color defines
define white  $01 ; The number 1
define green  $05 ; The number 5
define lblue  $03 ; The number 3
define dblue  $06 ; The number 6
define ltgrn  $0d ; The number 13
define blue   $0e ; The number 14
define yellow $07 ; The number 7
define orange $08 ; The number 8
define ltgray $0f ; The number 15
define black  $00 ; The number 0

define sysRandom  $fe ; Address of random number
define sysLastKey $ff

define mouseLowByte  $10
define mouseHighByte $11
define mouseXcoord   $12
define mouseYcoord   $13
define previousColor $14

; Rectangle drawing variables
define rectXcoord      $00
define rectYcoord      $01
define rectHeight      $02
define rectLength      $03
define rectLowByte     $04
define rectHighByte    $05
define rectOrigLowByte $06

; Start menu variables
define startMenuShown $07

; ASCII values of keys controlling the mouse
define ASCII_w      $77 ; Up
define ASCII_a      $61 ; Left
define ASCII_s      $73 ; Down
define ASCII_d      $64 ; Right
define ASCII_f      $66 ; Click

;;;;;
; Main
;;;;;

; Draw "Desktop shortcuts"
JSR getRandom
STA $0221
JSR getRandom
STA $0261
JSR getRandom
STA $02a1
JSR getRandom
STA $02e1

; Draw "Taskbar"
LDA #0
STA rectXcoord
LDA #31
STA rectYcoord
JSR ComputePosition
LDA #2
STA rectLength
LDA #green
JSR DrawLineHorizontal
LDA #30
STA rectLength
LDA #blue
JSR DrawLineHorizontal

; Initialize "Mouse"
LDA #0
STA previousColor
LDA #$0f
STA mouseXcoord
STA mouseYcoord
JSR moveMouse

; "Start menu"
LDA #0
STA startMenuShown

; Main loop
loop:
   JSR doMovement
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
   CMP #ASCII_f ; F
   BEQ click
RTS

click:
   JSR checkForStartMenu
   LDA #0
   STA sysLastKey
RTS

checkForStartMenu:
	LDA mouseYcoord
	CMP #31
	BNE checkForStartMenuEnd
	LDA mouseXcoord
	CMP #0
	BEQ drawStartMenu
	CMP #1
	BEQ drawStartMenu
checkForStartMenuEnd:
RTS

eraseStartMenu:
	LDA #0
	STA rectXcoord
	LDA #$13
	STA rectYcoord
	JSR ComputePosition
	LDA #10
   STA rectLength
   LDA #12
	STA rectHeight
   LDA #black
	JSR DrawRect
	LDA #0
	STA startMenuShown
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

drawStartMenu:
   LDA #1
   CMP startMenuShown
   ; Erase if we are already showing the start menu
   BEQ eraseStartMenu 
   STA startMenuShown
   ; Compute position of start menu
   LDA #$00
   STA rectXcoord
   LDA #$13
   STA rectYcoord
   JSR ComputePosition
   ; Draw top
   LDA #10
   STA rectLength
   LDA #2
   STA rectHeight
   LDA #blue
   JSR DrawRect
   ; Draw left side
   LDA #5
   STA rectLength
   LDA #9
   STA rectHeight
   LDA #white
   JSR DrawRect
   ; Draw left bottom
   LDA #blue
   JSR DrawLineHorizontal
   ; Draw log off button
   LDA #1
   STA rectLength
   LDA #yellow
   JSR DrawLineHorizontal
   LDA #blue
   JSR DrawLineHorizontal
   ; Draw shutdown button
   LDA #orange
   JSR DrawLineHorizontal
   ; Draw rest of bottom
   LDA #2
   STA rectLength
   LDA #blue
   JSR DrawLineHorizontal
   ; Draw right side (have to reposition ourselves)
   LDA #5
   STA rectXcoord
   LDA #$15
   STA rectYcoord
   JSR ComputePosition
   LDA #5
   STA rectLength
   LDA #9
   STA rectHeight
   LDA #lblue
   JSR DrawRect
RTS

moveMouse:
   JSR clearMouse

   LDA #0
   STA mouseHighByte
   LDA mouseYcoord
   STA mouseLowByte

   ; Multiply by 32 (yes, really)
   ASL mouseLowByte
   ROL mouseHighByte
   ASL mouseLowByte
   ROL mouseHighByte
   ASL mouseLowByte
   ROL mouseHighByte
   ASL mouseLowByte
   ROL mouseHighByte
   ASL mouseLowByte
   ROL mouseHighByte

   ; Add X
   LDA mouseXcoord
   ADC mouseLowByte
   STA mouseLowByte

   ; Add 0x200
   LDA #$02
   ADC mouseHighByte
   STA mouseHighByte

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
   LDA (mouseLowByte,x)
   STA previousColor  
   LDA #ltgray
   LDX #$0
   STA (mouseLowByte,x)
RTS

clearMouse:
   LDA previousColor
   LDX #$0
   STA (mouseLowByte,x)
RTS

ComputePosition:
   LDA #$00
   STA rectHighByte
   LDA rectYcoord
   LDX #$05
ComputePosition_loop:
   ASL A
   ROL rectHighByte
   DEX
   BNE ComputePosition_loop 
   ; A is low byte
   ; R3 is high byte
   ADC rectXcoord
   STA rectLowByte

   INC rectHighByte
   INC rectHighByte
RTS

DrawLineHorizontal:
; A is the color
   LDX #$00
   LDY rectLength
DrawLineHorizontal_loop:
   DEY
   BMI DrawLineHorizontal_end

   STA (rectLowByte,X)
   INC rectLowByte
   JMP DrawLineHorizontal_loop
DrawLineHorizontal_end:
RTS

DrawLineVertical:
; A is the color
   LDX #$00
   LDY rectLength ; rectLength is in Y
DrawLineVertical_loop:
   DEY
   BMI DrawLineVertical_end

   ;  LDA R0 ; Load color at R0 into A
   STA (rectLowByte,X) ; Draw color to screen
   PHA ; Put A (color) on stack
   LDA #$20 ; Put 32 in A
   CLC ; Clear carry
   ADC rectLowByte ; Add R2 to A
   STA rectLowByte ; Store A at R2
   PLA ; Pop A (color) from stack
   BCC DrawLineVertical_loop ; If we haven't wrapped, do this again
   INC rectHighByte ; Increment high byte if we wrap 
   JMP DrawLineVertical_loop
DrawLineVertical_end:
RTS

DrawRect:
DrawRect_loop:
   LDX rectLowByte
   STX rectOrigLowByte ; R4 is original low byte

   DEC rectHeight
   BMI DrawRect_end

   JSR DrawLineHorizontal
   PHA ; Put color on stack
   LDA rectOrigLowByte
   CLC
   ADC #$20
   STA rectLowByte
   PLA ; Pop color off stack
   BCC DrawRect_loop ; If we haven't wrapped, go again
   INC rectHighByte
   JMP DrawRect_loop
DrawRect_end:
RTS