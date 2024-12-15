.segment "CODE"
.macro LoadText label
   ldx #0
   ldy #0
   @loop:
      lda #$04
      sta title_text,x
      inx
      lda label,y
      sta title_text,x
      inx
      cmp #NULL
      beq @break
      iny
      bra @loop
      @break:
.endmacro
.proc DrawTitle
   jsr DrawTitleMain
   jsr DrawTitleCredits
   jsr DrawTitleCredits1
   rts
.endproc
.proc DrawTitleMain
   setXY16
   setA8
   ; load title
   LoadText title_main
   ; draw title
   ldy #(32*14+2)
   jsr DrawText
   setXY8
   rts
.endproc
.proc DrawTitleCredits
   setXY16
   setA8
   ; load title
   LoadText title_credits
   ; draw title
   ldy #(32*18)
   jsr DrawText
   setXY8
   rts
.endproc
.proc DrawTitleCredits1
   setXY16
   setA8
   ; load title
   LoadText title_credits1
   ; draw title
   ldy #(32*20+1)
   jsr DrawText
   setXY8
   rts
.endproc
.proc DrawText ; load tilemap start offset in (16-bit) Y
   setAXY16
   ; set VMADD to the correct offset
   lda #VRAM_BG1
   @loop_add:
      inc
      dey
      cpy #0
      bne @loop_add
   sta VMADDL
   ldx #0
   @loop:
      lda title_text,x
      cmp #$0004
      beq @break
         ; apply VRAM address offset and store in VRAM
         adc #VRAM_LETTER_START
         sta VMDATAL
      inx
      bra @loop
      @break:
   setAXY8
   rts
.endproc
.proc ClearText
   setXY16
   ldx #0
   lda #%10000000 ; vram auto increment
   sta VMAIN
   ldx #VRAM_BG1
   stx VMADDL
   setXY8

   doDMA empty_tile,0,<VMDATAL,TILEMAP_SIZE,%00001001 ; DMA without incrementing A address (copy empty_tile over and over)
   rts
.endproc