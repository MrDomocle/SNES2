SHOT_INTERVAL = 6 ; frames of cooldown between shots
BULLET_SPEED = 3 ; speed of bullets in pixels per frame
ENEMY_HSPEED = 1 ; speed of enemies moving horizontally
ENEMY_DIR_CHANGE_INTERVAL = 128 ; frames between randomising direction of amogi
SHIP_BOUND_Y_HI = $cf
SHIP_BOUND_Y_LO = $20
SHIP_BOUND_X_HI = $f0
SHIP_BOUND_X_LO = $00
HIT_RANGE = 16
EXPLODE_TIME = 30
EXPLODE_DISABLED_TIME = $ff ; set to explode time when there isn't an explosion in that slot
MAX_EXPLOSIONS = 16
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
      cmp #HIDDEN_Y
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
.proc HandleCollisions
   setAXY8
   ldx #enemy_first
   @loop: ; each enemy
      lda oam_lo+yc,x
      cmp #HIDDEN_Y ; skip if enemy is offscreen
      beq @continue
      lda oam_lo+tile_addr,x
      cmp #$04 ; skip if enemy is exploding
      beq @continue
      ldy #bullet_first
      @loop_b: ; each bullet
         lda oam_lo+yc,y
         cmp #HIDDEN_Y ; skip hidden
         beq @continue_b
            sbc oam_lo+yc,x
            cmp #HIT_RANGE ; compare to enemy y
            bcs @continue_b
               lda oam_lo+xc,y
               sbc oam_lo+xc,x
               cmp #HIT_RANGE ; compare to enemy x
               bcs @continue_b
                  dec amogus_count
                  phy
                  jsr Explode ; hide enemy in x
                  ply
                  tyx
                  jsr HideObject ; also hide bullet that hit it
                  txy

         @continue_b:
         .repeat 4
            iny
         .endrepeat
         cpy #bullet_last
         bne @loop_b
      @continue:
      .repeat 4
         inx
      .endrepeat
      cpx #enemy_last
      bne @loop
   @return:
   rts
.endproc
.proc TickBullets
   setAXY8
   ldx #bullet_first
   @loop: ; iterate through every bullet and tick it if it's on screen
      lda oam_lo+yc,x
      cmp #(HIDDEN_Y-1)
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
.proc TickEnemy
   setAXY8
   ldx #enemy_first
   ldy #0
   @loop:
      lda oam_lo+yc,x
      cmp #HIDDEN_Y
      beq @continue ; skip if this one is offscreen
      lda amogus_timers,y
      beq @rng ; if timer 0, change direction to whatever tickRNG says
         ; otherwise, continue moving in the same direction
         dec
         sta amogus_timers,y
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
      @rng:
      lda #ENEMY_DIR_CHANGE_INTERVAL
      sta amogus_timers,y
      jsr TickRNG
      lda random_word ; loads low byte
      bit #1 ; check if even
      bne @odd
         @even:
            lda #1
            sta amogus_directions,y
            bra @continue
      @odd:
         lda #0
         sta amogus_directions,y
         bra @continue
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
      adc oam_lo+yc,x
      sta oam_lo+yc,x
      
      .repeat 4
         inx
      .endrepeat
      cpx #enemy_last
      bne @loop
   @return:
   rts
.endproc
.proc TickRNG ; https://codebase64.org/doku.php?id=base:small_fast_8-bit_prng with a hack to make it 16-bit; theres a proper 16-bit version on the same website but i found out too late
   setA16
   lda random_word
   beq @doEOR ; if random_word is 0, do XOR to make it non-zero
      asl
      bcc @return ; if no bit shifted out, don't EOR
   @doEOR:
      eor #$1dff ; magic number idk
   @return:
   sta random_word
   setA8
   rts
.endproc
.proc TickExplosions
   ldx #0
   @loop:
      lda explosion_timers,x
      cmp #EXPLODE_DISABLED_TIME
      beq @continue
         cmp #0
         beq @stop_explosion
            dec explosion_timers,x
            bra @continue
         @stop_explosion:
         ; disable explosion
         lda #EXPLODE_DISABLED_TIME
         sta explosion_timers,x
         ; hide explosion
         phx
         lda explosion_objs,x
         tax
         jsr HideObject
         plx
      @continue:
      inx
      cpx #MAX_EXPLOSIONS
      bne @loop

      rts
.endproc

.proc Explode ; load obj's offset to X before call
   lda #$04 ; explosion tile address
   sta oam_lo+tile_addr,x
   ; set up explosion data
   ; go up the explosion list until we find an EXPLODE_DISABLED_TIME and put the explosion there
   ldy #0
   @loop:
      lda explosion_timers,y
      cmp #EXPLODE_DISABLED_TIME
      bne @continue ; go to next if not disabled
         lda #EXPLODE_TIME
         sta explosion_timers,y
         stx explosion_objs,y ; exploding object's offset is in X
         bra @break
      @continue:
      iny
      cpy #MAX_EXPLOSIONS
      bne @loop
      @break:

   rts
.endproc
.proc HideObject ; put obj offscreen. obj's offset in oam_lo has to be in X before call
   lda #HIDDEN_Y
   sta oam_lo+yc,x
   rts
.endproc