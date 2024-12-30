; MARK: CONSTANTS
; Technical constants
VRAM_CHARS = $0000 ; vram offset of bg characters
VRAM_BG1 = $1000 ; vram offset of bg1 tilemap 
VRAM_BG2 = $2000 ; vram offset of bg2 tilemap 
VRAM_BG1SC = %00010000 ; bg1 tilemap settings, including 6-bit VRAM offset
VRAM_BG2SC = %00100000 ; bg2 tilemap settings, including 6-bit VRAM offset
VRAM_LETTER_START = $7f ; in tilemap address format
VRAM_NUMBER_START = $9c ; in tilemap address format
LETTER_ATTR = $04 ; attribute byte for letter tiles
VRAM_SIZE = $ffff ; size of vram in bytes
CGRAM_SIZE = $0200 ; size of cgram in bytes
OAM_SIZE = $0220 ; size of oam in bytes
OAM_LO_SIZE = $0200 ; size of oam low table in bytes
TILEMAP_SIZE = 32*32*2 ; size of a 32x32 tilemap in bytes

; Logic constants

; Scoring (USES BCD)
ENEMY_DEAD_SCORE = $1000
SCREEN_CLEAR_SCORE = $9999
TARGET_SCORE_H = $42

; Entity speeds
BULLET_SPEED = 3 ; speed of bullets in pixels per frame
BULLET_SPEED_ENEMY = 2
ENEMY_HSPEED = 1 ; speed of enemies moving horizontally
; Timings
TITLE_TIME = 150 ; time for title to stay in frames
EXPLODE_TIME = 8 ; frames between explosion stages
SHOT_INTERVAL = 6 ; frames of cooldown between shots
ENEMY_DIR_CHANGE_INTERVAL = 128 ; frames between randomising direction of amogi
; Controls
SHIP_BOUND_Y_HI = $cf
SHIP_BOUND_Y_LO = $20
SHIP_BOUND_X_HI = $f0
SHIP_BOUND_X_LO = $00
HIT_RANGE = 16

; Entity data
EXPLODE_TILE_1 = $04
EXPLODE_TILE_2 = $06
ENEMY_TILE = $02
EXPLODE_DISABLED_STAGE = $ff ; set to explode stage when there isn't an explosion in that slot

; Scrolling
SCROLL_ACCEL_LO = 12 ; game -> title
SCROLL_ACCEL_MI = 24 ; title -> game
SCROLL_ACCEL_HI = 48 ; game -> speedup

SCROLL_SPEED_LO = 64 ; during titles
SCROLL_SPEED_MI = 1024 ; during gameplay
SCROLL_SPEED_HI = 3400 ; speedup

; Mosaic
MOSAIC_MODE_FADE_OUT_TITLE = 0
MOSAIC_MODE_FADE_OUT_BG = 1
MOSAIC_MODE_FADE_IN_BG = 2

MOSAIC_MASK_TITLE = %00000001
MOSAIC_MASK_BG = %00000010

MOSAIC_TARGET_FADE_OUT_TITLE = 15
MOSAIC_TARGET_FADE_OUT_BG = 6
MOSAIC_TARGET_FADE_IN = 0

MOSAIC_SPEED_FADE_IN_BG = 30
MOSAIC_SPEED_FADE_OUT_TITLE = 256
MOSAIC_SPEED_FADE_OUT_BG = 15

.segment "CODE"
; MARK: CD & CONTROLS
.proc UpdateTimers
   setXY16
   setA8
   lda shot_cooldown
   beq @shot_ready
      dec shot_cooldown
   @shot_ready:
   
   lda mosaic_active ; check if mosaic is active, update transition if so
   beq @mosaic_inactive
      jsr MosaicUpdate
   @mosaic_inactive:

   lda title_timer
   beq @title_ready
      dec title_timer
      bra @title_done
   @title_ready:
      setA8
      lda game_state
      cmp #0
      bne @title_done
         jsr MosaicFadeOutTitle
         ; scroll speed change
         setA16
         lda #SCROLL_SPEED_MI
         sta screen_vscroll_speed_target
         setA8
         ; done, start gameplay
         lda #1
         sta game_state
         jsr RandomiseEnemyPositions
   @title_done:

   lda amogus_timer
   beq @reset_amogus
      dec amogus_timer
      bra @done_amogus
   @reset_amogus:
      lda #ENEMY_DIR_CHANGE_INTERVAL
      sta amogus_timer
   @done_amogus:

   @return:
   setAXY8
   rts
.endproc

.proc ReadInput
   setAXY16
   ; check input

   ; holding - check buffer
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
   
   ; up/down - check masks
   lda joy1_down
   bit #$0080 ; a
   beq @not_a_down
      setXY16
      ldx #SCROLL_SPEED_HI
      stx screen_vscroll_speed_target
      ldx #SCROLL_ACCEL_HI
      stx screen_vscroll_accel
      setXY8
   @not_a_down:

   lda joy1_up
   bit #$0080
   beq @not_a_up
      setXY16
      ldx #SCROLL_SPEED_MI
      stx screen_vscroll_speed_target
      ldx #SCROLL_ACCEL_MI
      stx screen_vscroll_accel
      setXY8
   @not_a_up:

   @return:
   setA8
   rts
.endproc
; MARK: SHIP LOGIC
.proc ShootBullet
   setA8
   setXY16
   lda #0
   cpa shot_cooldown
   bne @return ; return if nmi_count is less
      lda #SHOT_INTERVAL
      sta shot_cooldown ; reset cooldown
   
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
.proc AddScore ; load (16-bit BCD) increment to accumulator before call
   sed
   clc
   adc score_l
   sta score_l
   bcc @return
      setA8
      setXY8
      lda score_h
      clc
      adc #1
      sta score_h
      cmp #TARGET_SCORE_H
      bcc @return
         ; A >= TARGET_SCORE_H
         cld
         lda #3
         sta game_state
         
         setA16
         lda #SCROLL_ACCEL_LO
         sta screen_vscroll_accel
         lda #SCROLL_SPEED_LO
         sta screen_vscroll_speed_target
         setA8
         setXY8
         jsr Clear
         jsr DrawWin
         lda #1
         sta oam_update
         jsr MosaicFadeOutBG
         ;setXY16
         rts
   @return:
   setA16
   cld
   jsr DrawScore
   rts
.endproc
.proc MoveShip
   setA8
   setXY16
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
; MARK: Collisions
.proc HandleCollisions
   setAXY8
   ; player - enemy bullet
   ldx #enemy_bullet_first
   @loop_e:
      lda oam_lo+yc,x
      sbc oam_lo+yc+ship ; check if bullet matches ship y
      cmp #HIT_RANGE
      bcs @continue_e
         lda oam_lo+xc,x
         sbc oam_lo+xc+ship ; check if bullet matches ship x
         cmp #HIT_RANGE
         bcs @continue_e
            ; game over
            setXY16
            lda #2
            sta game_state
            ldx #SCROLL_SPEED_LO
            stx screen_vscroll_speed_target
            ldx #SCROLL_ACCEL_LO
            stx screen_vscroll_accel
            setXY8
            jsr DrawTitleGameOver
            ldx #ship
            jsr Explode
            lda #1
            sta oam_update
            lda #MOSAIC_MASK_BG
            sta mosaic_mask
            jsr MosaicFadeOutBG
            bra @break_e
      @continue_e:
      .repeat 4
         inx
      .endrepeat
      cpx #enemy_bullet_last
      bne @loop_e
   @break_e:

   ; enemy - player bullet
   ldx #enemy_first
   @loop: ; each enemy
      lda oam_lo+yc,x
      cmp #HIDDEN_Y ; skip if enemy is offscreen
      beq @continue
      lda oam_lo+tile_addr,x
      cmp #ENEMY_TILE ; skip if enemy is exploding (not ENEMY_TILE)
      bne @continue
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
                  ; increment score
                  phx
                  phy
                  setA16
                     lda #ENEMY_DEAD_SCORE
                     jsr AddScore
                  setA8
                  ply
                  plx
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
; MARK: TICK
.proc TickBullets
   setAXY8
   ldx #bullet_first
   @loop: ; iterate through every bullet and tick it if it's on screen
      lda oam_lo+yc,x
      cmp #HIDDEN_Y
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
      lda explosion_stages,x
      cmp #EXPLODE_DISABLED_STAGE
      beq @continue
         lda explosion_timers,x
         cmp #0
         beq @time_up
            dec explosion_timers,x
            bra @continue
         @time_up:
         ; go to next stage or disable explosion
         lda explosion_stages,x
         cmp #1 ; last stage index
         beq @disable_explosion
            ; update tile
            ldy explosion_objs,x
            lda #EXPLODE_TILE_2
            sta oam_lo+tile_addr,y
            ; increment stage, reset timer
            inc explosion_stages,x
            lda #EXPLODE_TIME
            sta explosion_timers,x
            bra @continue
         @disable_explosion:
         lda #EXPLODE_DISABLED_STAGE
         sta explosion_stages,x
         ; hide explosion
         phx
         lda explosion_objs,x
         tax
         jsr HideObject
         plx
      @continue:
      inx
      cpx #POOL_SIZE_EXPLOSION
      bne @loop

      rts
.endproc

.proc Explode ; load obj's offset to X before call
   lda #EXPLODE_TILE_1
   sta oam_lo+tile_addr,x
   ; set up explosion data
   ; go up the explosion list until we find an EXPLODE_DISABLED_STAGE and put the explosion there
   ldy #0
   @loop:
      lda explosion_stages,y
      cmp #EXPLODE_DISABLED_STAGE
      bne @continue ; go to next if not disabled
         lda #0
         sta explosion_stages,y
         lda #EXPLODE_TIME
         sta explosion_timers,y
         stx explosion_objs,y ; exploding object's offset is in X
         bra @break
      @continue:
      iny
      cpy #POOL_SIZE_EXPLOSION
      bne @loop
      @break:

   rts
.endproc
.proc HideObject ; put obj offscreen. obj's offset in oam_lo has to be in X before call
   lda #HIDDEN_Y
   sta oam_lo+yc,x
   rts
.endproc