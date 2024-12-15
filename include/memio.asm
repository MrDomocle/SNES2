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
.proc BG2Load
   setXY16
   lda #%10000000
   sta VMAIN
   ldx #VRAM_BG2
   stx VMADDL
   setXY8

   doDMA mapstart,0,<VMDATAL,(mapend-mapstart),1
   rts
.endproc
.proc SetPalette
   stz CGADD
   ldx #0
   @loop: ; bg palettes
      lda chrpalettestart,x
      sta CGDATA
      inx
      lda chrpalettestart,x
      sta CGDATA
      inx

      cpx #(chrpaletteend-chrpalettestart)
      bne @loop
   
   lda #$10
   sta CGADD
   ldx #0
   @loop_title: ; title palettes
      lda titlepalettestart,x
      sta CGDATA
      inx
      lda titlepalettestart,x
      sta CGDATA
      inx

      cpx #(titlepaletteend-titlepalettestart)
      bne @loop_title
   
   lda #$80
   sta CGADD
   ldx #0
   @loop_obj: ; obj palettes
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
.proc ClearOAM ; this is a special case as we need to hide all unused sprites
   setXY16
   ldx #0
   lda #$f7 ; y position to keep sprite offscreen
   @loop:
      stz oam_lo,x
      inx
      sta oam_lo,x ; sta to make y position f7
      inx
      cpx #(oam_hi-oam_lo)
      bne @loop
   
   ldx #0
   @loop1: ; only stz to oam_hi
      stz oam_hi,x ; sta to make y position f7
      inx
      cpx #(oam_end-oam_hi)
      bne @loop1
   rts
.endproc