.p816
.smart

.include "include/snes.inc"
.include "include/macros.inc"
.include "include/memio.asm"
.include "gfx/charset.asm"
.include "gfx/palette.asm"
.include "gfx/objects.asm"
.include "gfx/tilemap.asm"
.include "gfx/charmap.inc"
.include "draw/titles.asm"
.include "draw/screen.asm"
.include "gamelogic.asm"

.bss
   oam_lo: .res 512
   oam_hi: .res 32
   oam_end:

VRAM_CHARS = $0000 ; vram offset of bg characters
VRAM_BG1 = $1000 ; vram offset of tilemap 
VRAM_BG2 = $2000 
VRAM_BG1SC = %00010000 ; tilemap settings, including 6-bit address
VRAM_BG2SC = %00100000 
VRAM_LETTER_START = $7e ; in tilemap address format
LETTER_ATTR = $04
VRAM_SIZE = $ffff ; size of vram in bytes
CGRAM_SIZE = $0200 ; size of cgram in bytes
OAM_SIZE = $0220 ; size of oam in bytes
TILEMAP_SIZE = 32*32*2 ; size of a 32x32 tilemap in bytes

; WRAM addresses ("variables")
nmi_count = $00 ; word
game_state = $02 ; byte
shot_cooldown = $04 ; word
joy1_buffer_last = $06 ; joy1_buffer of the last frame
joy1_buffer = $08 ; word, buffer for storing joypad data
joy1_up = $0a ; mask for buttons that were released
joy1_down = $0c ; mask for buttons that were pressed
screen_vscroll = $0e ; word, buffer for BG2VOFS with subpixels (16 subpixels in pixel)
screen_vscroll_speed = $10 ; word, speed of scroll in subpixels/frame
screen_vscroll_speed_target = $12 ; word, target for scroll speed acceleration
screen_vscroll_accel = $14 ; word
random_word = $1c ; rng outputs here
title_timer = $1e ; byte
amogus_count = $1f ; byte
amogus_timer = $2f ; byte
amogus_directions = $40 ; array of bytes 
explosion_objs = $60 ; array of bytes
explosion_timers = $80 ; array of bytes
explosion_stages = $100 ; array of bytes

ZERO = $110 ; address that will be set to 0 for vram/cgram clears

title_text = $120 ; array of words

.segment "CODE"
.proc ResetHandler
   ; init dance
   sei ; disable interrupts
   clc ; carry clear
   xce ; swap carry and emulation bits

   setAXY8 ; start in 8-bit mode
   stz random_word
   stz random_word+1

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
   jsr ClearOAM
   jsr LoadOBJ
   jsr ClearText
   jsr DrawTitle
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
   
   ; clear vars
   setA16
   stz ZERO
   stz nmi_count
   stz shot_cooldown
   stz joy1_buffer

   lda #SCROLL_SPEED_LO
   sta screen_vscroll_speed
   sta screen_vscroll_speed_target
   lda #SCROLL_ACCEL_LO
   sta screen_vscroll_accel

   lda #$ffff
   sta screen_vscroll
   setA8
   stz amogus_timer
   ldx #0
   @enemy_clear_loop:
      stz amogus_directions,x
      inx
      cpx #ENEMY_POOL_SIZE
      bne @enemy_clear_loop
   ldx #0
   @explosion_clear_loop:
      lda #EXPLODE_DISABLED_STAGE
      sta explosion_stages,x
      inx
      cpx #MAX_EXPLOSIONS
      bne @explosion_clear_loop
   lda #ENEMY_POOL_SIZE
   sta amogus_count
   lda #TITLE_TIME
   sta title_timer
   
   stz game_state ; 0 title 1 game

   ldx #0

   jmp GameLoop
.endproc

.proc GameLoop
   lda nmi_count
@nmi_wait:
   wai
   cmp nmi_count
   beq @nmi_wait ; don't proceed until nmi_count changes

   ; scroll screen
   jsr ScrollBG
   
   jsr UpdateCooldowns
   lda game_state
   beq @title
      jsr ReadInput
      jsr TickBullets
      jsr HandleCollisions
      jsr TickEnemy
      jsr TickExplosions
   @title:
   
   jmp GameLoop
.endproc

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
   ; OAM needs to be updated first (which essentially delays sprite updates by 1 frame)
   ; This is because sometimes logic takes long enough to miss the time when you can still
   ; write to PPU registers, so sprites disappear for that frame (e.g. when I do an explosion)
   lda game_state
   beq @title
      jsr UpdateOAM
   @title:
   
   rti ; return from interrupt
.endproc

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