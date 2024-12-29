.segment "CODE"
.macro LoadText label ; load .asciiz text as tiles to title_text
   ldx #0
   ldy #0
   @loop:
      lda label,y
      cmp #NULL
      beq @break
         adc #VRAM_LETTER_START
         sta title_text,x
         inx
         lda #LETTER_ATTR
         sta title_text,x
         inx
         lda label,y
         
         iny
         bra @loop
      @break:
      sta title_text,x
      inx
      lda #LETTER_ATTR
      sta title_text,x
.endmacro
.macro LoadScoreText ; load bcd text as tiles to title_text
   ldx #0
   ldy #3
   @loop:
      lda score_l,y
      .repeat 4
         lsr
      .endrepeat
      adc #VRAM_LETTER_START
      sta title_text,x
      inx
      lda #LETTER_ATTR
      sta title_text,x
      inx
      lda score_l,y
      .repeat 4
         asl
      .endrepeat
      .repeat 4
         lsr
      .endrepeat
      adc #VRAM_LETTER_START
      sta title_text,x
      inx
      lda #LETTER_ATTR
      sta title_text,x
      inx

      dey
      cpy #0
      bne @loop

   stz title_text,x
   inx
   lda #LETTER_ATTR
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

.proc DrawTitleGameOver
   setXY16
   setA8
   LoadText title_lose
   ldy title_lose_ofs
   jsr DrawText
   setXY8
   rts
.endproc

.proc DrawTitleWin
   setXY16
   setA8
   LoadText title_win
   ldy title_win_ofs
   jsr DrawText
   setXY8
   rts
.endproc

.proc DrawScore
   setXY16
   setA8
   LoadScoreText
   ldy #32
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
; MARK: BG SCROLL
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
   lda screen_vscroll_sub
   sbc screen_vscroll_speed ; will overflow to screen_vscroll (MSB)
   sta screen_vscroll_sub
   setA8
   lda screen_vscroll
   sta BG2VOFS
   stz BG2VOFS
   rts
.endproc
; MARK: Transition Init
.proc MosaicFadeOutTitle
   ; set up mosaic transition parameters for hiding title text
   stz mosaic_substage
   stz mosaic_stage
   lda #MOSAIC_MASK_TITLE
   sta mosaic_mask
   lda #MOSAIC_TARGET_FADE_OUT_TITLE
   sta mosaic_target
   lda #MOSAIC_MODE_FADE_OUT_TITLE
   sta mosaic_mode
   ; start transition
   lda #1
   sta mosaic_active
   stz mosaic_stage
   jsr MosaicUpdate
   rts
.endproc
.proc MosaicFadeOutBG
   ; set up mosaic transition parameters for blurring bg
   stz mosaic_substage
   stz mosaic_stage
   lda #MOSAIC_MASK_BG
   sta mosaic_mask
   lda #MOSAIC_TARGET_FADE_OUT_BG
   sta mosaic_target
   lda #MOSAIC_MODE_FADE_OUT_BG
   sta mosaic_mode
   ; start transition
   lda #1
   sta mosaic_active
   stz mosaic_stage
   jsr MosaicUpdate
   rts
.endproc
.proc MosaicFadeInBG
   ; set up mosaic transition parameters for unblurring bg
   stz mosaic_substage
   stz mosaic_stage
   lda #MOSAIC_MASK_BG
   sta mosaic_mask
   lda #MOSAIC_TARGET_FADE_IN
   sta mosaic_target
   lda #MOSAIC_MODE_FADE_IN_BG
   sta mosaic_mode
   ; start transition
   lda #1
   sta mosaic_active
   lda #MOSAIC_TARGET_FADE_OUT_BG
   sta mosaic_stage
   jsr MosaicUpdate
   rts
.endproc

; MARK: Transition Update
.proc MosaicUpdate
   lda mosaic_mode
   cmp #MOSAIC_MODE_FADE_OUT_TITLE
   beq @title_out
   cmp #MOSAIC_MODE_FADE_OUT_BG
   beq @bg_out
   cmp #MOSAIC_MODE_FADE_IN_BG
   beq @bg_in

   @title_out:
      lda mosaic_stage
      cmp mosaic_target
      beq @finish_title_out
         setA16
         lda mosaic_substage
         adc #MOSAIC_SPEED_FADE_OUT_TITLE
         sta mosaic_substage
         setA8
         bra @apply
      @finish_title_out:
         stz mosaic_active
         jsr ClearText
         bra @return

   @bg_out:
      lda mosaic_stage
      cmp mosaic_target
      beq @finish_bg_out
         setA16
         lda mosaic_substage
         adc #MOSAIC_SPEED_FADE_OUT_BG
         sta mosaic_substage
         setA8
         bra @apply
      @finish_bg_out:
         stz mosaic_active
         bra @return

   @bg_in:
      lda mosaic_stage
      cmp mosaic_target
      beq @finish_bg_in
         setA16
         lda mosaic_substage
         sbc #MOSAIC_SPEED_FADE_IN_BG
         sta mosaic_substage
         setA8
         bra @apply
      @finish_bg_in:
         ; start title fade out immediately
         jsr MosaicFadeOutTitle
         bra @return

   @apply:
      lda mosaic_stage
      .repeat 4
         asl ; shift stage 4 bits left for MOSAIC register format
      .endrepeat
      adc mosaic_mask ; set lowest 4 bits according to mask (which BGs will be blurred)
      sta MOSAIC

   @return:
   rts
.endproc