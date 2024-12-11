SHOT_INTERVAL = 6 ; frames of cooldown between shots
BULLET_SPEED = 3 ; speed of bullets in pixels per frame
SHIP_BOUND_Y_HI = $cf
SHIP_BOUND_Y_LO = $20
SHIP_BOUND_X_HI = $f0
SHIP_BOUND_X_LO = $00
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
      ldx #%10
      jsr MoveShip
   @not_l:
   bit #$0100 ; right
   beq @not_r
      ldx #%11
      jsr MoveShip
   @not_r:
   bit #$0800 ; up
   beq @not_u
      ldx #%00
      jsr MoveShip
   @not_u:
   bit #$0400 ; down
   beq @not_d
      ldx #%01
      jsr MoveShip
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
   
   ldx #bullet_first
   @loop:
      lda oam_lo+yc,x
      cmp #$f7
      bne @continue ; skip this bullet if it's not hidden
      ; otherwise use that bullet
      bra @apply

      @continue:
      .repeat 4
         inx
      .endrepeat
      cpx #bullet_last
      bne @loop
   
   @apply:
      lda oam_lo+xc+ship
      adc #3
      sta oam_lo+xc,x ; x as offset - to get to the bullet we chose
      lda oam_lo+yc+ship
      sbc #5
      sta oam_lo+yc,x
   
   @return:
   setA16
   rts
.endproc
.proc MoveShip ; load direction to X before calling. bits 0,1: 00 up 01 down 10 left 11 right
   setA8
   cpx #%00 ; up
   bne @not_up
      lda oam_lo+yc+ship
      cmp #SHIP_BOUND_Y_LO
      beq @not_up ; skip if at lower (top of screen) bound
         ; otherwise move up
         dec oam_lo+yc+ship
   @not_up:
   cpx #%01 ; down
   bne @not_down
      lda oam_lo+yc+ship
      cmp #SHIP_BOUND_Y_HI
      beq @not_down
         inc oam_lo+yc+ship
   @not_down:
   cpx #%10 ; left
   bne @not_left
      lda oam_lo+xc+ship
      cmp #SHIP_BOUND_X_LO
      beq @not_left
         dec oam_lo+xc+ship
   @not_left:
   cpx #%11 ; right
   bne @not_right
      lda oam_lo+xc+ship
      cmp #SHIP_BOUND_X_HI
      beq @not_right
         inc oam_lo+xc+ship
   @not_right:
   @return:
   setA16
   rts
.endproc
.proc TickBullets
   setA8
   ldx #bullet_first
   @loop: ; iterate through every bullet and tick it if it's on screen
      lda oam_lo+yc,x
      cmp #$f6
      bcs @continue ; skip this bullet if it's offscreen (register > #$f6)

      sbc #BULLET_SPEED
      bcs @not_over
         jsr HideObject ; hide if yc overflows
         bra @continue
      @not_over:
      sta oam_lo+yc,x
      
      @continue:
      .repeat 4
         inx
      .endrepeat
      cpx #bullet_last
      bne @loop
   @return:
   rts
.endproc
.proc HideObject ; put obj offscreen. obj's offset in oam_lo has to be in X before call
   lda #$f7
   sta oam_lo+yc,x
   rts
.endproc