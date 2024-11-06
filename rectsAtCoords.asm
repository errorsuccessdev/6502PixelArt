; Ann's variables
define Xcoord   $00
define Ycoord   $01
define height   $02
define length   $03
define lowByte  $04
define highByte $05
define originalLowByte $06

; Ann's color defines
define white $01 ; The number 1
define green $05 ; The number 5
define lblue $03 ; The number 3
define dblue $06 ; The number 6
define ltgrn $0d ; The number 13
define blue  $0e ; The number 14

start:
; Rectangle
        LDA #$00
        STA Xcoord
        LDA #$13
        STA Ycoord
        JSR ComputePosition
; R2 is low byte, R3 is high byte
        LDA #8
        STA length
        LDA #12
        STA height
        LDA #white
        JSR DrawRect

; Horizontal line
        LDA #0 ; X coordinate
        STA Xcoord
        LDA #21 ; Y coordinate
        STA Ycoord
        JSR ComputePosition
        LDA #10 ; Length
        STA length
        LDA #green ; Color
        JSR DrawLineHorizontal

; Vertical line
        LDA #11 ; X coordinate
        STA Xcoord
        LDA #0 ; Y coordinate
        STA Ycoord
        JSR ComputePosition
        LDA #20 
        STA length ; Length
        LDA #blue ; Color
        JSR DrawLineVertical

; One pixel
        LDA #15
        STA Xcoord
        STA Ycoord
        JSR ComputePosition
	LDA #lblue
        JSR DrawPixel
dead:
        JMP dead

ComputePosition:
; R0 is X coordinate
; R1 is Y coordinate
        LDA #$00
        STA highByte

        LDA Ycoord
        LDX #$05
ComputePosition_loop:
        ASL A
        ROL highByte
        DEX
        BNE ComputePosition_loop 
        ; A is low byte
        ; R3 is high byte
        ADC Xcoord
        STA lowByte ; R2 is now low byte

        INC highByte
        INC highByte

        RTS ; R2 is low byte, R3 is high byte

DrawPixel:
; A is the color
        STA (lowByte,X)
        RTS

DrawLineHorizontal:
; R0 is the length
; A is the color
        LDX #$00
        LDY length
DrawLineHorizontal_loop:
        DEY
        BMI DrawLineHorizontal_end

        STA (lowByte,X)
        INC lowByte
        JMP DrawLineHorizontal_loop
DrawLineHorizontal_end:
        RTS

DrawLineVertical:
; R0 is the length
; A is the color
        LDX #$00
        LDY length ; Length is in Y
     ;   STA R0 ; R0 is now the color
DrawLineVertical_loop:
        DEY
        BMI DrawLineVertical_end

      ;  LDA R0 ; Load color at R0 into A
        STA (lowByte,X) ; Draw color to screen
        PHA ; Put A (color) on stack
        LDA #$20 ; Put 32 in A
        CLC ; Clear carry
        ADC lowByte ; Add R2 to A
        STA lowByte ; Store A at R2
        PLA ; Pop A (color) from stack
        BCC DrawLineVertical_loop ; If we haven't wrapped, do this again
        INC highByte ; Increment high byte if we wrap 
        JMP DrawLineVertical_loop
DrawLineVertical_end:
        RTS

DrawRect:
; R0 is length
; R1 is height
; A is color
; R2 is low byte
; R3 is high byte

DrawRect_loop:
        LDX lowByte
        STX originalLowByte ; R4 is original low byte

        DEC height
        BMI DrawRect_end

        JSR DrawLineHorizontal
        PHA ; Put color on stack
        LDA originalLowByte
        CLC
        ADC #$20
        STA lowByte
        PLA ; Pop color off stack
        BCC DrawRect_loop ; If we haven't wrapped, go again
        INC highByte
        JMP DrawRect_loop
DrawRect_end:
        RTS