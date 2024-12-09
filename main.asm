.p816
.smart

.include "include/snes.inc"
.include "include/macros.inc"
.include "include/memio.asm"
.include "gfx/charset.asm"
.include "gfx/palette.asm"
.include "gfx/objects.asm"

.bss ; oam bss
   oam_lo: .res 512
   oam_hi: .res 32

.zeropage
VRAM_CHARS = $0000 ; vram offset of bg characters
VRAM_BG1 = $0000 ; vram offset of tilemap
ZERO = $0069 ; address that will be set to 0 for vram/cgram clears
VRAM_SIZE = $ffff ; size of vram in bytes
CGRAM_SIZE = $0200 ; size of cgram in bytes
OAM_SIZE = $0220 ; size of oam in bytes
; WRAM addresses ("variables")
nmi_count = $00
move_down = $01

.segment "CODE"
.proc ResetHandler
   ; init dance
   sei ; disable interrupts
   clc ; carry clear
   xce ; swap carry and emulation bits

   jsr ClearVRAM
   jsr CharLoad ; load character data to VRAM
   jsr ClearCGRAM
   jsr SetPalette
   jsr ClearOAM
   jsr LoadOBJ

   lda #%00000001
   sta BGMODE
   lda #0
   sta OBSEL

   lda #%00010000
   sta TM
   lda #%00000001
   sta TS

   lda #$0f
   sta INIDISP

   ; enable non-maskable interrupt
   lda #$81
   sta NMITIMEN

   stz nmi_count
   stz move_down
   jmp GameLoop
.endproc

.proc GameLoop
   lda nmi_count
@nmi_wait:
   wai
   cmp nmi_count
   beq @nmi_wait ; don't proceed until nmi_count changes

   ; check input
   lda JOY1H
   bit #$02 ; l
   beq @not_l
      dec oam_lo+ship+xc
   @not_l:
   bit #$01 ; r
   beq @not_r
      inc oam_lo+ship+xc
   @not_r:
   bit #$08 ; u
   beq @not_u
      dec oam_lo+ship+yc
   @not_u:
   bit #$04 ; d
   beq @not_d
      inc oam_lo+ship+yc
   @not_d:

   lda move_down
   beq @not_move
      inc oam_lo+ship+1
   @not_move:

   jsr UpdateOAM ; update OAM every frame

   jmp GameLoop
.endproc

.proc NMIHandler
   pha
   inc nmi_count
   pla
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