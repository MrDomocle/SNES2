chrpalettestart:
.word $0000 ; transparency
.word %0110001011001100 ; #64b3c1
.word %0011111001101001 ; #4e9c7a
.word %0001100001000001 ; #0b1737
.word %0001010001000000 ; #00142b
.word %0010110100000000 ; #00425f
.word %0001100001000000 ; #001336
.word %0101000111000000 ; #0072a6
.word %0001010010000000 ; #00202c
.word %0101001100101110 ; #73cda6
.word %0111111100000000 ; #00c5fb
.word %0111111111111111 ; #ffffff
.word %0110111111010111 ; #baf5db
chrpaletteend:

titlepalettestart:
.word $0000 ; transparency
.word %0111111111111111 ; #ffffff
.res 28
.word $0000
.word %0111001110011100 ;
titlepaletteend:

objpalletestart:
.word $0000 ; transparency
.word %0000000000011111 ; #ff0000
.word %0010100011000110 ; #333554
.word %0000000111011111 ; #ff7200
.word %0010010100101001 ; #4d4d4d
.word %0101010100001001 ; #4b42ab
.word %0111111101111011 ; #ddd9ff
.word %0000001011011111 ; #ffb700
.word %0110011100111001 ; #c8c8c8
.word %0111111000110010 ; #9389ff
.word %0100101001010010 ; #919191
.word %0010000100011111 ; #ff4646
.word %0111110101001100 ; #6152fa
objpaletteend: