ENEMY_POOL_SIZE = 15 ; ENEMY_POOL_SIZE-3 must be divisible by 4
BULLET_POOL_SIZE = 9
ENEMY_BULLET_POOL_SIZE = 15
HIDDEN_Y = $f0
OFFSCREEN_Y = $e0
xc=0 ; x byte offset
yc=1 ; y byte offset
tile_addr=2 ; tile address byte offset
objlostart:
ship = 4*0 ; offset in oam_lo
.byte %01110100 ; xxxxxxxx
.byte %10000011 ; yyyyyyyy
.byte %00000000 ; tttttttt
.byte %00110000 ; vhppccct
; enemy pool
enemy_first = ship+4
.repeat ENEMY_POOL_SIZE
.byte %00100000 ; xxxxxxxx
.byte HIDDEN_Y ; yyyyyyyy
.byte %00000010 ; tttttttt
.byte %00100000 ; vhppccct
.endrepeat
enemy_last = enemy_first+4*ENEMY_POOL_SIZE
; bullet pool
bullet_first = enemy_last
.repeat BULLET_POOL_SIZE
.byte %00100000 ; xxxxxxxx
.byte HIDDEN_Y ; yyyyyyyy
.byte %00100000 ; tttttttt
.byte %00100000 ; vhppccct
.endrepeat
bullet_last = bullet_first+4*BULLET_POOL_SIZE
enemy_bullet_first = bullet_last
.repeat ENEMY_BULLET_POOL_SIZE
.byte %00100000 ; xxxxxxxx
.byte HIDDEN_Y ; yyyyyyyy
.byte %00100001 ; tttttttt
.byte %00100000 ; vhppccct
.endrepeat
enemy_bullet_last = enemy_bullet_first+4*ENEMY_BULLET_POOL_SIZE
objloend:

objhistart:
.byte %10101010 ; sxsxsxsx - obj 0-3
.repeat (ENEMY_POOL_SIZE-3)/4
   .byte %10101010
.endrepeat
objhiend: