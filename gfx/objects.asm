xc=0 ; x byte offset
yc=1 ; y byte offset
objlostart:
ship = 4*0 ; offset in oam_lo
.byte %00100000 ; xxxxxxxx
.byte %00100000 ; yyyyyyyy
.byte %00000000 ; tttttttt
.byte %00110000 ; vhppccct
enemy = 4*1
.byte %00100000 ; xxxxxxxx
.byte %00100000 ; yyyyyyyy
.byte %00000010 ; tttttttt
.byte %00010000 ; vhppccct
; bullet pool
bullet_first = 4*2
.repeat 10
.byte %00100000 ; xxxxxxxx
.byte %11110111 ; yyyyyyyy
.byte %00100000 ; tttttttt
.byte %00000000 ; vhppccct
.endrepeat
bullet_last = 4*13
objloend:

objhistart:
.byte %00001010 ; sxsxsxsx - obj 0-3
objhiend: