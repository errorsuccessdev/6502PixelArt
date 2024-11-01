define smallNumber $10
define bigNumber   $11
define y $1f ; The number 0x04
define x $1f ; The number 0x14

LDA #0
STA bigNumber
LDA #y
STA smallNumber

; Multiply by 32 (yes, really)
ASL smallNumber
ROL bigNumber
ASL smallNumber
ROL bigNumber
ASL smallNumber
ROL bigNumber
ASL smallNumber
ROL bigNumber
ASL smallNumber
ROL bigNumber

; Add X
LDA #x
ADC smallNumber
STA smallNumber

; Add 0x200
LDA #$02
ADC bigNumber
STA bigNumber


