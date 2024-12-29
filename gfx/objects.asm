POOL_SIZE_ENEMY = 15 ; POOL_SIZE_ENEMY-3 must be divisible by 4 because of oam_hi layout (big bit is stored there)
POOL_SIZE_BULLET = 9
POOL_SIZE_BULLET_ENEMY = 8
POOL_SIZE_EXPLOSION = 16
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
.repeat POOL_SIZE_ENEMY
.byte %00100000 ; xxxxxxxx
.byte HIDDEN_Y ; yyyyyyyy
.byte %00000010 ; tttttttt
.byte %00100000 ; vhppccct
.endrepeat
enemy_last = enemy_first+4*POOL_SIZE_ENEMY
; bullet pool
bullet_first = enemy_last
.repeat POOL_SIZE_BULLET
.byte %00100000 ; xxxxxxxx
.byte HIDDEN_Y ; yyyyyyyy
.byte %00100000 ; tttttttt
.byte %00100000 ; vhppccct
.endrepeat
bullet_last = bullet_first+4*POOL_SIZE_BULLET
enemy_bullet_first = bullet_last
.repeat POOL_SIZE_BULLET_ENEMY
.byte %00100000 ; xxxxxxxx
.byte HIDDEN_Y ; yyyyyyyy
.byte %00100001 ; tttttttt
.byte %00100000 ; vhppccct
.endrepeat
enemy_bullet_last = enemy_bullet_first+4*POOL_SIZE_BULLET_ENEMY
objloend:

objhistart:
.byte %10101010 ; sxsxsxsx - obj 0-3
.repeat (POOL_SIZE_ENEMY-3)/4
   .byte %10101010
.endrepeat
objhiend: