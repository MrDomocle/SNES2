.p816
.smart

.include "snes.inc"
.include "macros.inc"
.include "charset.asm"
.include "palette.asm"
.include "objects.asm"

VRAM_CHARS = $0000
VRAM_BG1 = $0000
ZERO = $0069
VRAM_SIZE = $ffff
CGRAM_SIZE = $0200
OAM_SIZE = $0220

.segment "CODE"
.proc ResetHandler
   ; init dance
   sei ; disable interrupts
   clc ; carry clear
   xce ; swap carry and emulation bits

   jsr ClearVRAM
   jsr CharLoad ; load character data to VRAM
   jsr ClearCGRAM
   jsr SetPalette

   lda #%00000001
   sta BGMODE

   lda #%00010000
   sta TM

   lda #$0f
   sta INIDISP

   ; enable non-maskable interrupt
   lda #$81
   sta NMITIMEN
   jmp GameLoop
.endproc

.proc CharLoad
   setXY16
   lda #%10000000
   sta VMAIN ; prepare VMDATAL to autoincrement
   ldx #VRAM_CHARS
   stx VMADDL ; set vm start address to character data
   setXY8

   doDMA charstart,0,<VMDATAL,(charend-charstart),1 ; channel a_addr a_bank b_addr len control
   rts
.endproc

.proc ClearVRAM
   setXY16
   ldx #0
   stx ZERO ; set up source to be zero
   ldx #%10000000 ; vram auto increment
   sta VMAIN
   setXY8

   doDMA ZERO,0,<VMDATAL,VRAM_SIZE,%00001001 ; DMA without incrementing A address (copy ZERO over and over)
   rts
.endproc

.proc SetPalette
   stz CGADD
   ldx #0
   @loop:
      lda palettestart,x
      sta CGDATA
      inx
      lda palettestart,x
      sta CGDATA
      inx

      cpx #(paletteend-palettestart)
      bne @loop
   lda #$80
   sta CGADD
   ldx #0
   @loop_obj: ; set object palettes
      lda objpalletestart,x
      sta CGDATA
      inx
      lda objpalletestart,x
      sta CGDATA
      inx

      cpx #(objpaletteend-objpalletestart)
      bne @loop_obj

   rts
.endproc

.proc ClearCGRAM
   setXY16
   ldx #0
   stx ZERO ; set up source to be zero
   stz CGADD ; CGADD starts from 0
   setXY8

   doDMA ZERO,0,<CGDATA,CGRAM_SIZE,%00001010
   rts
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