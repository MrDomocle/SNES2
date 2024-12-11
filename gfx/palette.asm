chrpalettestart:
; colour 0: #0000
.byte %00000000 ; low byte (gggrrrrr)
.byte %00000000 ; high byte(-bbbbbgg)
; colour 1: #7c1f (magenta)
.byte %00011111 ; low byte
.byte %01111100 ; high byte
; colour 2: 03e0 (green)
.byte %11100000 ; low
.byte %00000011 ; high
chrpaletteend:

objpalletestart:
.word $0000 ; transparency
.word %0000000000011111
.word %0010100011000110
.word %0010010100101001
.word %0101010100001001
.word %0111111101111011
.word %0110011100111001
.word %0111111000110010
.word %0100101001010010
objpaletteend:

