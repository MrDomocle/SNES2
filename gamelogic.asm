SHOT_INTERVAL = 60 ; frames of cooldown between shots
.segment "CODE"
.proc UpdateCooldowns
   setAXY16
   ldx #0
   cpx shot_cooldown
   beq @shot_ready
      dec shot_cooldown
   @shot_ready:

   @return:
   setAXY8
   rts
.endproc

.proc ReadInput
   setAXY16
   ; check input
   lda joy1_buffer
   bit #$0200 ; left
   beq @not_l
      dec oam_lo+xc+ship
   @not_l:
   bit #$0100 ; right
   beq @not_r
      inc oam_lo+xc+ship
   @not_r:
   bit #$0800 ; up
   beq @not_u
      dec oam_lo+yc+ship
   @not_u:
   bit #$0400 ; down
   beq @not_d
      inc oam_lo+yc+ship
   @not_d:

   bit #$8000 ; b
   beq @not_b
      jsr ShootBullet
   @not_b:

   @return:
   setA8
   rts
.endproc
.proc ShootBullet
   setA8
   setXY16
   ldx #0
   cpx shot_cooldown
   bne @return ; return if nmi_count is less
      ldx #SHOT_INTERVAL
      stx shot_cooldown ; reset cooldown

   lda oam_lo+yc+bullet1
   cmp #$f7
   beq @b1_free
      ; if 1st bullet object isn't free (not hidden), check 2nd
      lda oam_lo+yc+bullet2
      cmp #$f7
      bne @return ; ignore call if no bullets free
         ; use bullet2 otherwise
         ldx #bullet2
         bra @apply
   @b1_free:
      ldx #bullet1
      bra @apply
   @apply:
      lda oam_lo+xc+ship
      adc #8
      sta oam_lo+xc,x ; x as offset - to get to the bullet we chose
      lda oam_lo+yc+ship
      sbc #8
      sta oam_lo+yc,x
   
   @return:
   setA16
   rts
.endproc
.proc TickBullets
   setA8
   lda oam_lo+yc+bullet1
   cmp #$f6 ; check if 1st bullet is active (yc is more than f6, so it's hidden)
   bcs @b1_out
      ; move bullet1 2 pixels up
      dec oam_lo+yc+bullet1
      dec oam_lo+yc+bullet1
      dec oam_lo+yc+bullet1
   @b1_out:
   lda oam_lo+yc+bullet2
   cmp #$f6
   bcs @b2_out
      dec oam_lo+yc+bullet2
      dec oam_lo+yc+bullet2
      dec oam_lo+yc+bullet2
   @b2_out:
   @return:
   rts
.endproc
.proc HideObject ; put obj offscreen. obj's offset has to be in x
   lda #$f7
   sta oam_lo+yc,x
   rts
.endproc