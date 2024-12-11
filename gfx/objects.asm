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
bullet1 = 4*2
.byte %00100000 ; xxxxxxxx
.byte %11110111 ; yyyyyyyy
.byte %00000100 ; tttttttt
.byte %00000000 ; vhppccct
bullet2 = 4*3
.byte %00100000 ; xxxxxxxx
.byte %11110111 ; yyyyyyyy
.byte %00000100 ; tttttttt
.byte %00000000 ; vhppccct
objloend:

objhistart:
.byte %00001010 ; sxsxsxsx - obj 0-3
objhiend: