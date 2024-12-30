.segment "CODE"
.macro LoadText label ; load .asciiz text as tiles to title_text
   ldx #0
   ldy #0
   @loop:
      lda label,y
      cmp #NULL
      beq @break
         clc
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
   ldy #2
   @loop:
      lda score_l,y
      .repeat 4
         lsr
      .endrepeat
      clc
      adc #VRAM_NUMBER_START
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
      clc
      adc #VRAM_NUMBER_START
      sta title_text,x
      inx
      lda #LETTER_ATTR
      sta title_text,x
      inx

      dey
      bpl @loop ; branch if y hasn't overflown to ff (high bit isn't 1)

   stz title_text,x
   inx
   lda #LETTER_ATTR
   sta title_text,x
.endmacro
; MARK: TITLES
; These put titles in queue
.proc DrawTitle
   lda title_draw_now
   ora #1
   sta title_draw_now
   rts
.endproc
.proc DrawScore
   lda title_draw_now
   ora #2
   sta title_draw_now
   rts
.endproc
.proc DrawGameOver
   lda title_draw_now
   ora #4
   sta title_draw_now
   rts
.endproc
.proc DrawWin
   lda title_draw_now
   ora #8
   sta title_draw_now
   rts
.endproc
.proc Clear
   lda title_draw_now
   ora #128
   sta title_draw_now
   rts
.endproc

; These draw the titles
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

.proc DrawScoreText
   setXY16
   setA8
   LoadText score_text
   ldy score_text_ofs
   jsr DrawText
   setXY8
   rts
.endproc

.proc DrawScoreNum
   setXY16
   setA8
   LoadScoreText
   ldy score_num_ofs
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
   sty title_ofs
   lda #VRAM_BG1
   clc
   adc title_ofs
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
.proc UpdateTitles
   setAXY8
   ; clearing is always first
   lda title_draw_now
   bit #128
   beq @not_clear
      stz MOSAIC
      jsr ClearText
      
      lda title_draw_now
      eor #128
      sta title_draw_now
   @not_clear:

   ; check which titles were set to draw and draw them
   lda title_draw_now
   bit #1
   beq @not_title
      jsr DrawTitleMain
      jsr DrawTitleCredits
      jsr DrawTitleCredits1

      lda title_draw_now
      eor #1
      sta title_draw_now
   @not_title:
   lda title_draw_now
   bit #2
   beq @not_score
      jsr DrawScoreText
      jsr DrawScoreNum

      lda title_draw_now
      eor #2
      sta title_draw_now
   jsr DrawScoreNum
   @not_score:
   lda title_draw_now
   bit #4
   beq @not_game_over
      jsr DrawTitleGameOver

      lda title_draw_now
      eor #4
      sta title_draw_now
   @not_game_over:
   lda title_draw_now
   bit #8
   beq @not_game_complete
      jsr DrawTitleWin

      lda title_draw_now
      eor #8
      sta title_draw_now
   @not_game_complete:
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
         jsr Clear
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
         lda amogus_transition
         beq @not_amogus
            ; if transition for resetting amogi, fade back in
            jsr MosaicFadeInBG
            bra @return
         @not_amogus:
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
         ; this is only called by amogus reset, so this is used to finish the reset
         ; back up ship coordinates
         lda oam_lo+xc+ship
         sta ship_x
         lda oam_lo+yc+ship
         sta ship_y
         ; reset oam
         jsr LoadOBJ
         jsr RandomiseEnemyPositions
         ; restore ship coordinates
         lda ship_x
         sta oam_lo+xc+ship
         lda ship_y
         sta oam_lo+yc+ship

         lda #POOL_SIZE_ENEMY
         sta amogus_count
         stz amogus_transition
         stz mosaic_active
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