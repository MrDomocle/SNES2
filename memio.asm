.segment "CODE"
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
   @loop: ; oam_lo
      lda objlostart,x
      sta oam_lo,x
      inx
      cpx #(objloend-objlostart)
      bne @loop
   ldx #0
   @loop1: ; oam_hi
      lda objhistart,x
      sta oam_hi,x
      inx
      cpx #(objhiend-objhistart)
      bne @loop1

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