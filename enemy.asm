.segment "CODE"
.proc TickEnemyBullets
   setAXY8
   ldx #enemy_bullet_first
   @loop: ; iterate through every bullet and tick it if it's on screen
      lda oam_lo+yc,x
      cmp #HIDDEN_Y
      bcs @continue ; skip this bullet if it's offscreen (register > #$f6)

      adc #BULLET_SPEED_ENEMY
      cmp #OFFSCREEN_Y
      bcc @not_offscreen
         lda #HIDDEN_Y ; hide if bullet went offscreen
      @not_offscreen:
      sta oam_lo+yc,x
      
      @continue:
      .repeat 4
         inx
      .endrepeat
      cpx #enemy_bullet_last
      bne @loop
   @return:
   rts
.endproc
.proc TickEnemy
   setAXY8
   ldx #enemy_first ; enemy oam offset
   ldy #0 ; enemy nummber
   @loop:
      lda oam_lo+yc,x
      cmp #HIDDEN_Y
      beq @continue ; skip if this one is offscreen
      
      ; update shooting
      lda amogus_shot_timers,y
      bne @no_shot ; branch if timer didnt run out yet
         @rng_rep:
            jsr TickRNG
            lda random_word
            cmp #$80
            bcc @rng_rep ; keep regenerating until a value more than $80 is found
         lda random_word
         sta amogus_shot_timers,y
         phy
         jsr EnemyShoot
         ply
         bra @shot_done
      @no_shot:
      lda amogus_shot_timers,y
      dec
      sta amogus_shot_timers,y
      @shot_done:

      lda amogus_timer
      beq @dir_change ; if timer 0, change direction to whatever tickRNG says
         ; otherwise, continue moving in the same direction
         lda amogus_directions,y
         beq @right ; right if dir is 0
         @left:
            lda oam_lo+xc,x
            sbc #ENEMY_HSPEED
            sta oam_lo+xc,x
            bra @continue
         @right:
            lda oam_lo+xc,x
            adc #ENEMY_HSPEED
            sta oam_lo+xc,x
            bra @continue
      @dir_change:
      jsr TickRNG
      lda random_word ; loads low byte
      bit #1 ; check if even
      bne @odd
      @even:
         lda #1
         sta amogus_directions,y
         bra @dir_done
      @odd:
         lda #0
         sta amogus_directions,y
         bra @dir_done

      @dir_done:
      @continue:
      .repeat 4
         inx
      .endrepeat
      iny
      cpx #enemy_last
      bne @loop
   @return:
   rts
.endproc
.proc RandomiseEnemyPositions
   setAXY8
   ldx #enemy_first
   @loop:
      jsr TickRNG
      lda random_word ; low byte
      ; x coordinate: direct
      sta oam_lo+xc,x
      ; y coordinate: use high byte, crop some bits
      lda random_word+1
      and #$2f
      adc #$20
      sta oam_lo+yc,x
      
      .repeat 4
         inx
      .endrepeat
      cpx #enemy_last
      bne @loop
   @return:
   rts
.endproc
.proc EnemyShoot ; put enemy offset in x
   ldy #enemy_bullet_first
   @loop:
      lda oam_lo+yc,y
      cmp #HIDDEN_Y ; check if bullet is hidden (available)
      bne @continue
         lda oam_lo+xc,x ; enemy x
         sta oam_lo+xc,y ; bullet x
         lda oam_lo+yc,x ; enemy y
         sta oam_lo+yc,y ; bullet y
         bra @break
      @continue:
      .repeat 4
         iny
      .endrepeat
      cpy #enemy_bullet_last
      bne @loop 
   @break:
   rts
.endproc