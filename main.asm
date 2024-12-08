.p816
.smart

.include "snes.inc"
.include "macros.inc"
.include "charset.asm"

VRAM_CHARS = $0000
VRAM_BG1 = $0000
LOAD_INDEX_1 = $00
LOAD_INDEX_2 = $02

.segment "CODE"
.proc ResetHandler
   ; init dance
   sei ; disable interrupts
   clc ; carry clear
   xce ; swap carry and emulation bits
   
   setXY16 ; X needs to be 16-bit to set the vram add address
   ; load character data to VRAM
   lda #$80
   sta VMAIN ; set vram increment mode
   ldx #VRAM_CHARS
   stx VMADDL ; set vram load start address
   setXY8 ; dont need that anymore

   ; loop
   stz LOAD_INDEX_1 ; bp1
   lda #8
   sta LOAD_INDEX_2 ; bp2

   ldy #0
   @loop:
      ldx LOAD_INDEX_1
      lda charstart,x
      sta VMDATAL
      inx
      stx LOAD_INDEX_1
      
      ldx LOAD_INDEX_2
      lda charstart,x
      sta VMDATAH ; write to high increments vram address
      inx
      stx LOAD_INDEX_2
 
      iny
      cpy #8 ; check if a character was loaded completely
      bne @nojump
      
      ldy #0
      lda LOAD_INDEX_1
      adc #7
      sta LOAD_INDEX_1

      lda LOAD_INDEX_2
      adc #8
      sta LOAD_INDEX_2
 
      @nojump:
 
      cpx #(charend - charstart) ; compare x to number of bytes for chars
      bne @loop

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