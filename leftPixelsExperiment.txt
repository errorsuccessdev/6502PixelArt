; Left of screen
LDA #$21

drawLeftPixels:
  CLC
  ADC #$40
  STA $00
  LDX $00
  LDA #white
  STA $0200,x
  LDA $00
  CPX #$a1
BNE drawLeftPixels