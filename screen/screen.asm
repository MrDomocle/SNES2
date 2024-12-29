.segment "CODE"
.macro LoadText label
   ldx #0
   ldy #0
   @loop:
      lda label,y
      cmp #NULL
      beq @break
         adc #VRAM_LETTER_START
         sta title_text,x
         inx
         lda #$04
         sta title_text,x
         inx
         lda label,y
         
         iny
         bra @loop
      @break:
      sta title_text,x
      inx
      lda #$04
      sta title_text,x
.endmacro
; MARK: TITLE
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
   ldy title_main_ofs
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
   ldy title_credits_ofs
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
   ldy title_credits1_ofs
   jsr DrawText
   setXY8
   rts
.endproc

; MARK: GAME OVER
.proc DrawTitleGameOver
   setXY16
   setA8
   LoadText title_lose
   ldy title_lose_ofs
   jsr DrawText
   setXY8
   rts
.endproc

; MARK: TECH
.proc DrawText ; load tilemap start offset in (16-bit) Y
   setXY16
   ; set VMAIN
   lda #%10000000
   sta VMAIN
   setA16
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
      cmp #$0400
      beq @break
         ; store in VRAM
         sta VMDATAL
      inx
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

.proc ScrollBG
   ; acceleration
   setA16
   lda screen_vscroll_speed
   cmp screen_vscroll_speed_target
   bcs @accel_speed_gr
      ; if speed less
      adc screen_vscroll_accel
      sta screen_vscroll_speed
      bra @accel_done
   @accel_speed_gr:
      ; if speed more
      sbc screen_vscroll_accel
      sta screen_vscroll_speed
   @accel_done:
   ; set scroll
   lda screen_vscroll
   sbc screen_vscroll_speed
   sta screen_vscroll
   setA8
   lda screen_vscroll+1 ; MSB
   sta BG2VOFS
   stz BG2VOFS
   rts
.endproc
.proc MosaicDissolve
   lda #1
   sta mosaic_stage
   jsr MosaicDissolveUpdate
   rts
.endproc
; MARK: Transition to Greatness
.proc MosaicDissolveUpdate
   lda mosaic_stage
   .repeat 4
      asl ; shift stage 4 bits left for MOSAIC register format
   .endrepeat
   adc mosaic_mask ; set lowest 2 bits to activate bg1/2 mosaic
   sta MOSAIC
   ; check for last stage on title
   lda mosaic_mask
   cmp #1
   bne @return
      lda mosaic_stage
      cmp #$0f
      bcc @return
         stz MOSAIC
         jsr ClearText
   @return:
   rts
.endproc