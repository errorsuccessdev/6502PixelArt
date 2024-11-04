JSR someFunction
dead:
  JMP dead

someFunction:
   LDA #$06
   PHA
   LDA #$0c
   PHA
   RTS

unintended:
   LDA #$ff
   RTS