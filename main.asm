.p816
.i16
.a8

.include "snes.inc"

.segment "CODE"
.proc ResetHandler
   ; init dance
   sei ; disable interrupts
   clc ; carry clear
   xce ; swap carry and emulation bits

   ; enable non-maskable interrupt
   lda #$81
   sta NMITIMEN
   jmp GameLoop
.endproc

.proc GameLoop
   wai
   jmp GameLoop
.endproc

.proc NMIHandler
   lda RDNMI
   rti ; return from interrupt
.endproc

.segment "VECTOR"
; native mode   COP,        BRK,        ABT,
.addr           $0000,      $0000,      $0000
;               NMI,        RST,        IRQ
.addr           NMIHandler, $0000,      $0000

.word           $0000, $0000    ; four unused bytes

; emulation m.  COP,        BRK,        ABT,
.addr           $0000,      $0000,      $0000
;               NMI,        RST,        IRQ
.addr           $0000 ,     ResetHandler, $0000