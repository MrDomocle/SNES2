.p816

.include "include/snes.inc"
.include "include/macros.inc"
.include "include/memio.asm"
.include "gfx/charset.asm"
.include "gfx/palette.asm"
.include "gfx/objects.asm"
.include "gfx/tilemap.asm"
.include "gfx/charmap.inc"
.include "screen/titles.asm"
.include "screen/screen.asm"
.include "gamelogic.asm"
.include "enemy.asm"

.segment "BSS"
   oam_lo: .res 512
   oam_hi: .res 32
   oam_end:
; MARK: WRAM map
.segment "ZEROPAGE"
nmi_count: .res 2 ; word
ZERO: .res 2 ; stores the 0 for clearing VRAM/CGRAM with DMA
ZERO_OAM: .res 2 ; stores the OAM data for a hidden sprite
game_state: .res 1 ; byte, 0 title 1 game 2 dead 3 won
oam_update: .res 1 ; byte, ccccccba: a=clear oam, b=clear buffer, c(any)=update oam normally, neither=do nothing
score_l: .res 2 ; word, low word for 24-bit BCD score
score_h: .res 1 ; byte, high byte for 24-bit BCD score
shot_cooldown: .res 2 ; word
joy1_buffer_last: .res 2 ; word, joy1_buffer of the last frame
joy1_buffer: .res 2 ; word, buffer for storing joypad data
joy1_up: .res 2 ; mask for buttons that were released
joy1_down: .res 2 ; mask for buttons that were pressed

screen_vscroll_sub: .res 1 ; byte, overflows into screen_vscroll when using 16-bit addition/subtraction
screen_vscroll: .res 1 ; byte, actual BG2VOFS (MSB of screen_vscroll_sub)
screen_vscroll_speed: .res 2 ; word, speed of scroll in subpixels/frame
screen_vscroll_speed_target: .res 2 ; word, target for scroll speed acceleration
screen_vscroll_accel: .res 2 ; word

random_word: .res 2 ; word, rng outputs here
title_timer: .res 1 ; byte

mosaic_active: .res 1 ; byte, whether to run transition
mosaic_substage: .res 1 ; byte, overflows into mosaic_stage with 16-bit addition/subtraction
mosaic_stage: .res 1 ; byte, actual stage (MSB of mosaic_substage)
mosaic_mask: .res 1 ; byte, lower 4 bits of MOSAIC to determine which backgrounds will be affected by the transition
mosaic_target: .res 1 ; byte, target mosaic stage
mosaic_mode: .res 1 ; byte, 0 - hide title, 1 - game over (blur bg), 2 - game restart (fade in bg)

amogus_timer: .res 1 ; byte, timer for updating amogus directions randomly
amogus_directions: .res POOL_SIZE_ENEMY ; array of bytes
amogus_shot_timers: .res POOL_SIZE_ENEMY ; array of bytes, cooldown between shots of each amogus

explosion_objs: .res POOL_SIZE_EXPLOSION ; array of bytes
explosion_timers: .res POOL_SIZE_EXPLOSION ; array of bytes
explosion_stages: .res POOL_SIZE_EXPLOSION ; array of bytes

title_draw_now: .res 1 ; byte, individual bits toggle title types: C---dcba, a=title screen, b=score, c=game over, d=game complete, C=clear screen
title_ofs: .res 2 ; word, VRAM offset for currently rendering title
title_text: .res 2*32 ; array of words, buffer for tile data of titles before they're drawn. text should be drawn one line at a time, so it won't be longer than 32 words

; MARK: ResetHandler
.segment "CODE"
.proc ResetHandler
   ; init dance
   sei ; disable interrupts
   clc ; carry clear
   xce ; swap carry and emulation bits

   setAXY8 ; start in 8-bit mode
   

   ; MARK: variable init
   setA16
   stz ZERO

   lda #$f730
   sta ZERO_OAM

   stz nmi_count
   stz random_word

   lda #$9999
   sta score_l
   
   stz shot_cooldown
   stz joy1_buffer
   stz mosaic_active

   lda #SCROLL_SPEED_LO
   sta screen_vscroll_speed
   sta screen_vscroll_speed_target
   lda #SCROLL_ACCEL_MI
   sta screen_vscroll_accel

   lda #$ffff
   sta screen_vscroll
   setA8
   lda #$41
   sta score_h
   stz amogus_timer
   
   lda #4
   sta oam_update

   stz title_draw_now

   ; object things
   ldx #0
   @enemy_clear_loop:
      stz amogus_directions,x
      jsr TickRNG
      lda random_word
      sta amogus_shot_timers,x

      inx
      cpx #POOL_SIZE_ENEMY
      bne @enemy_clear_loop
   ldx #0
   @explosion_clear_loop:
      lda #EXPLODE_DISABLED_STAGE
      sta explosion_stages,x
      inx
      cpx #POOL_SIZE_EXPLOSION
      bne @explosion_clear_loop
   lda #POOL_SIZE_ENEMY
   lda #TITLE_TIME
   sta title_timer
   
   stz game_state

   ; set bg and obj modes
   lda #%00000001
   sta BGMODE
   lda #%00000000
   sta OBSEL ; sssnnbbb
   ; set tilemap address
   lda #VRAM_BG1SC
   sta BG1SC
   lda #VRAM_BG2SC
   sta BG2SC

   jsr ClearVRAM
   jsr CharLoad ; load character data to VRAM
   jsr ClearCGRAM
   jsr SetPalette
   jsr ClearOAMBuffer
   jsr LoadOBJ
   jsr ClearText
   jsr DrawTitle
   jsr DrawScore
   jsr BG2Load
   jsr UpdateOAM
   
   ; set main & subscreen designations
   lda #%00010011
   sta TM
   lda #%00000010
   sta TS

   lda #$0f
   sta INIDISP

   ; enable non-maskable interrupt
   lda #$81
   sta NMITIMEN

   ldx #0

   jmp GameLoop
.endproc

; MARK: GameLoop
.proc GameLoop
   lda nmi_count
@nmi_wait:
   wai
   cmp nmi_count
   beq @nmi_wait ; don't proceed until nmi_count changes
   
   jsr UpdateTimers

   ; check if game state is play
   lda game_state
   cmp #1
   bne @frozen
      jsr ReadInput
      jsr TickBullets
      jsr TickEnemyBullets
      jsr TickEnemy
      jsr HandleCollisions
      jsr TickExplosions
   @frozen:
   
   jmp GameLoop
.endproc
; MARK: NMIHandler
.proc NMIHandler
   setAXY16
   inc nmi_count

   lda joy1_buffer
   sta joy1_buffer_last

   lda JOY1L ; load joypad register now because vblank starts soon
   sta joy1_buffer

   eor joy1_buffer_last
   tax
   and joy1_buffer_last
   sta joy1_up
   txa
   and joy1_buffer
   sta joy1_down
   
   
   setAXY8
   ; Run code that needs PPU registers (otherwise logic can take too long and skip update)
   jsr UpdateOAM
   jsr UpdateTitles
   jsr ScrollBG

   rti ; return from interrupt
.endproc
; MARK: VECTOR
.segment "VECTOR"
; native mode   COP,        BRK,        ABT,
.addr           $0000,      $0000,      $0000
;               NMI,        RST,        IRQ
.addr           NMIHandler, $0000,      $0000

.word           $0000, $0000    ; four unused bytes

; emulation m.  COP,        BRK,        ABT,
.addr           $0000,      $0000,      $0000
;               NMI,        RST,        IRQ
.addr           $0000 ,     ResetHandler, $0000