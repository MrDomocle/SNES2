palettestart:
; colour 0: #0000
.byte %00000000 ; low byte (gggrrrrr)
.byte %00000000 ; high byte(-bbbbbgg)
; colour 1: #7c1f (magenta)
.byte %00011111 ; low byte
.byte %01111100 ; high byte
; colour 2: 03e0 (green)
.byte %11100000 ; low
.byte %00000011 ; high
; colour 1: #7c1f (magenta)
.byte %00011111 ; low byte
.byte %01111100 ; high byte
; colour 2: 03e0 (green)
.byte %11100000 ; low
.byte %00000011 ; high
; colour 1: #7c1f (magenta)
.byte %00011111 ; low byte
.byte %01111100 ; high byte
; colour 2: 03e0 (green)
.byte %11100000 ; low
.byte %00000011 ; high
; colour 1: #7c1f (magenta)
.byte %00011111 ; low byte
.byte %01111100 ; high byte
; colour 2: 03e0 (green)
.byte %11100000 ; low
.byte %00000011 ; high
; colour 1: #7c1f (magenta)
.byte %00011111 ; low byte
.byte %01111100 ; high byte
; colour 2: 03e0 (green)
.byte %11100000 ; low
.byte %00000011 ; high
; colour 1: #7c1f (magenta)
.byte %00011111 ; low byte
.byte %01111100 ; high byte
; colour 2: 03e0 (green)
.byte %11100000 ; low
.byte %00000011 ; high
; colour 1: #7c1f (magenta)
.byte %00011111 ; low byte
.byte %01111100 ; high byte
; colour 2: 03e0 (green)
.byte %11100000 ; low
.byte %00000011 ; high
; colour 1: #7c1f (magenta)
.byte %00011111 ; low byte
.byte %01111100 ; high byte
paletteend:

objpalletestart:
; colour 0: #0000
.byte %00000000 ; low byte (gggrrrrr)
.byte %00000000 ; high byte(-bbbbbgg)
; 1 - grey
.word $294A
; 2 - white
.word $7fff
; 3 - yellow
.word $03bf
; 4 - blue
.word $7c02
objpaletteend:

