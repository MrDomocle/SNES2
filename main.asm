.p816
.smart

.include "snes.inc"
.include "macros.inc"
.include "charset.asm"
.include "palette.asm"
.include "objects.asm"

.bss ; oam bss: 
   oam_lo: .res 512
   oam_hi: .res 32

.zeropage
VRAM_CHARS = $0000 ; vram offset of bg characters
VRAM_BG1 = $0000 ; vram offset of tilemap
ZERO = $0069 ; address that will be set to 0 for vram/cgram clears
VRAM_SIZE = $ffff ; size of vram in bytes
CGRAM_SIZE = $0200 ; size of cgram in bytes
OAM_SIZE = $0220 ; size of oam in bytes
nmi_count = $00

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
   jsr ClearOAM
   jsr LoadOBJ

   lda #%00000001
   sta BGMODE
   lda #%010

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

   doDMA charstart,0,<VMDATAL,(charend-charstart),1 ; a_addr a_bank b_addr len control
   rts
.endproc
.proc SetPalette
   stz CGADD
   ldx #0
   @loop: ; bg palettes
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
.proc UpdateOAM ; loads oam buffer into actual oam
   stz OAMADDL
   stz OAMADDH

   doDMA oam_lo,0,<OAMDATA,OAM_SIZE,0
   rts
.endproc
.proc LoadOBJ ; loads object attributes from rom to oam buffer
   setXY16
   ldx #0
   @loop:
      lda objstart,x
      sta oam_lo,x
      inx
      cpx #(objend-objstart)
      bne @loop
   setXY8
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
.proc ClearCGRAM
   setXY16
   ldx #0
   stx ZERO ; set up source to be zero
   stz CGADD ; CGADD starts from 0
   setXY8

   doDMA ZERO,0,<CGDATA,CGRAM_SIZE,%00001010
   rts
.endproc
.proc ClearOAM
   setXY16
   ldx #0
   @loop:
      stz oam_lo,x
      inx
      cpx #OAM_SIZE
      bne @loop
   setXY8
   rts
.endproc

.proc GameLoop
   stz nmi_count
   lda nmi_count
@nmi_wait:
   wai
   cmp nmi_count
   beq @nmi_wait ; don't proceed until nmi_count changes

   ; move sprite
   inc oam_lo
   inc oam_lo+1

   jsr UpdateOAM ; update OAM every frame

   jmp GameLoop
.endproc

.proc NMIHandler
   lda RDNMI
   inc nmi_count
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