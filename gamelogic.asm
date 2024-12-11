SHOT_INTERVAL = 6 ; frames of cooldown between shots
.segment "CODE"
.proc ShootBullet
   pha
   phx
   phy
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
      sta oam_lo+xc,x ; x as offset - to get to the bullet we chose
      lda oam_lo+yc+ship
      sbc #8
      sta oam_lo+yc,x
   @return:
   setXY8
   pla
   plx
   ply
   rts

.endproc
.proc HideObject ; put obj offscreen. obj's offset has to be in x
   lda #$f7
   sta oam_lo+yc,x
   rts
.endproc