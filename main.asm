.p816
.smart

.include "snes.inc"
.include "macros.inc"
.include "charset.asm"

VRAM_CHARS = $0000
VRAM_BG1 = $0000

.segment "CODE"
.proc ResetHandler
   ; init dance
   sei ; disable interrupts
   clc ; carry clear
   xce ; swap carry and emulation bits
   
   setXY16 ; X needs to be 16-bit for VRAM DMA
   ldx #%10000000
   stx VMAIN

   ldx #charstart ; source address (16-bit)
   stx A1TxL

   stz A1Bx ; source bank is 0

   lda #$18 ; LSB of VMADDL address
   sta BBADx

   ldx #(charend-charstart); number of bytes to copy
   stx DASxL
   
   lda #%00000001 ; configure how DMA should be done. here: a-bus to b-bus, increment a address, 2 bytes (word) to 2 (VMADDL,H) registers
   sta DMAPx
   
   lda #1
   sta MDMAEN

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