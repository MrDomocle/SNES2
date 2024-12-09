xc=0
yc=1
objlostart:
ship = 4*0 ; index in oam_lo
.byte %00100000 ; xxxxxxxx
.byte %00100000 ; yyyyyyyy
.byte %00000000 ; tttttttt
.byte %00000000 ; vhppccct
enemy = 4*1
.byte %00100000 ; xxxxxxxx
.byte %00100000 ; yyyyyyyy
.byte %00000001 ; tttttttt
.byte %01000000 ; vhppccct
objloend:

objhistart:
.byte %00000010 ; sxsxsxsx - obj 0-3
objhiend: