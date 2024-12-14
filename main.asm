.p816
.smart

.include "include/snes.inc"
.include "include/macros.inc"
.include "include/memio.asm"
.include "gfx/charset.asm"
.include "gfx/palette.asm"
.include "gfx/objects.asm"
.include "gfx/tilemap.asm"
.include "gamelogic.asm"

.bss
   oam_lo: .res 512
   oam_hi: .res 32
   oam_end:
.zeropage
VRAM_CHARS = $0000 ; vram offset of bg characters
VRAM_BG1 = $1000 ; vram offset of BG1 tilemap
VRAM_BG1SC = %00010000 ; tilemap settings, including 6-bit address
VRAM_SIZE = $ffff ; size of vram in bytes
CGRAM_SIZE = $0200 ; size of cgram in bytes
OAM_SIZE = $0220 ; size of oam in bytes

; WRAM addresses ("variables")
ZERO = $0069 ; address that will be set to 0 for vram/cgram clears
nmi_count = $00 ; word
joy1_buffer = $04 ; word, buffer for storing joypad data
screen_vscroll = $06 ; word, buffer for BG1VOFS (makes code for scrolling simpler)
random_word = $08 ; random number address. leave uninitialised for a random seed on emulators that set memory to random at startup

shot_cooldown = $02 ; word

amogus_timers = $20 ; array of bytes
amogus_directions = $40 ; array of bytes 

explosion_number = $60 ; byte
explosion_objs = $61 ; array of bytes
explosion_timers = $80 ; array of bytes

.segment "CODE"
.proc ResetHandler
   ; init dance
   sei ; disable interrupts
   clc ; carry clear
   xce ; swap carry and emulation bits

   setAXY8 ; start in 8-bit mode

   jsr ClearVRAM
   jsr CharLoad ; load character data to VRAM
   jsr ClearCGRAM
   jsr SetPalette
   jsr ClearOAM
   jsr LoadOBJ
   jsr MapLoad
   jsr RandomiseEnemyPositions
   
   ; set bg and obj modes
   lda #%00000001
   sta BGMODE
   lda #%00000000
   sta OBSEL ; sssnnbbb
   ; set tilemap address
   lda #VRAM_BG1SC
   sta BG1SC
   
   ; set main & subscreen designations
   lda #%00010001
   sta TM
   lda #%00010000
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
   stz screen_vscroll
   setA8
   ldx #0
   @enemy_clear_loop:
      stz amogus_directions,x
      stz amogus_timers,x
      cpx ENEMY_POOL_SIZE
      bne @enemy_clear_loop
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
   setA16
   dec screen_vscroll
   dec screen_vscroll
   setA8
   lda screen_vscroll ; LSB
   sta BG1VOFS
   lda screen_vscroll+1 ; MSB
   sta BG1VOFS
   
   jsr UpdateCooldowns
   jsr ReadInput
   jsr TickBullets
   jsr HandleCollisions
   jsr TickEnemy
   ;jsr TickExplosions
   
   jsr UpdateOAM ; update OAM every frame

   jmp GameLoop
.endproc

.proc NMIHandler
   setA16
   inc nmi_count
   lda JOY1L ; load joypad register now because vblank starts soon
   sta joy1_buffer
   setA8
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