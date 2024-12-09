; ------------------------------------------------------------------------
; Character data goes here
; ------------------------------------------------------------------------
; 0
t0a0 = %00001111
t0a1 = %00011111
t0a2 = %00111111
t0a3 = %00111111
t0a4 = %01110011
t0a5 = %01110011
t0a6 = %01110011
t0a7 = %01111111
; 0a
t0b0 = %00000000
t0b1 = %00001111
t0b2 = %00011111
t0b3 = %00011111
t0b4 = %00110111
t0b5 = %00110111
t0b6 = %00110011
t0b7 = %00111111
; 0c
t0c0 = %00000000
t0c1 = %00000000
t0c2 = %00000000
t0c3 = %00000000
t0c4 = %00001000
t0c5 = %00001000
t0c6 = %00001100
t0c7 = %00000000
; 0d
t0d0 = %00000000
t0d1 = %00000000
t0d2 = %00000000
t0d3 = %00000000
t0d4 = %00000000
t0d5 = %00000000
t0d6 = %00000000
t0d7 = %00000000


; 1a
t1a0 = %11110000
t1a1 = %11111000
t1a2 = %11111100
t1a3 = %11111100
t1a4 = %11001110
t1a5 = %11001110
t1a6 = %11001110
t1a7 = %11111110
; 1b
t1b0 = %00000000
t1b1 = %11110000
t1b2 = %11111000
t1b3 = %11111000
t1b4 = %11011100
t1b5 = %11011100
t1b6 = %11001100
t1b7 = %11111100
; 1c
t1c0 = %00000000
t1c1 = %00000000
t1c2 = %00000000
t1c3 = %00000000
t1c4 = %00100000
t1c5 = %00100000
t1c6 = %00110000
t1c7 = %00000000
; 1d
t1d0 = %00000000
t1d1 = %00000000
t1d2 = %00000000
t1d3 = %00000000
t1d4 = %00000000
t1d5 = %00000000
t1d6 = %00000000
t1d7 = %00000000

; 2a
t2a0 = %01111111
t2a1 = %01111111
t2a2 = %01111111
t2a3 = %01110000
t2a4 = %01100000
t2a5 = %01100000
t2a6 = %01100000
t2a7 = %11110000
; 2b
t2b0 = %00111111
t2b1 = %00111111
t2b2 = %00000000
t2b3 = %00000000
t2b4 = %00000000
t2b5 = %00000000
t2b6 = %00000000
t2b7 = %00000000
; 2c
t2c0 = %00000000
t2c1 = %00000000
t2c2 = %00000000
t2c3 = %00000000
t2c4 = %00000000
t2c5 = %00000000
t2c6 = %00000000
t2c7 = %00000000
; 2d
t2d0 = %00000000
t2d1 = %00000000
t2d2 = %00000000
t2d3 = %00000000
t2d4 = %00000000
t2d5 = %00000000
t2d6 = %00000000
t2d7 = %00000000
; 3a
t3a0 = %11111110
t3a1 = %11111110
t3a2 = %11111110
t3a3 = %00001110
t3a4 = %00000110
t3a5 = %00000110
t3a6 = %00000110
t3a7 = %00001111
; 3b
t3b0 = %11111100
t3b1 = %11111100
t3b2 = %00000000
t3b3 = %00000000
t3b4 = %00000000
t3b5 = %00000000
t3b6 = %00000000
t3b7 = %00000000
; 3c
t3c0 = %00000000
t3c1 = %00000000
t3c2 = %00000000
t3c3 = %00000000
t3c4 = %00000000
t3c5 = %00000000
t3c6 = %00000000
t3c7 = %00000000
; 3d
t3d0 = %00000000
t3d1 = %00000000
t3d2 = %00000000
t3d3 = %00000000
t3d4 = %00000000
t3d5 = %00000000
t3d6 = %00000000
t3d7 = %00000000

charstart:
.byte t0a0
.byte t0b0
.byte t0a1
.byte t0b1
.byte t0a2
.byte t0b2
.byte t0a3
.byte t0b3
.byte t0a4
.byte t0b4
.byte t0a5
.byte t0b5
.byte t0a6
.byte t0b6
.byte t0a7
.byte t0b7
.byte t0c0
.byte t0d0
.byte t0c1
.byte t0d1
.byte t0c2
.byte t0d2
.byte t0c3
.byte t0d3
.byte t0c4
.byte t0d4
.byte t0c5
.byte t0d5
.byte t0c6
.byte t0d6
.byte t0c7
.byte t0d7
.byte t1a0
.byte t1b0
.byte t1a1
.byte t1b1
.byte t1a2
.byte t1b2
.byte t1a3
.byte t1b3
.byte t1a4
.byte t1b4
.byte t1a5
.byte t1b5
.byte t1a6
.byte t1b6
.byte t1a7
.byte t1b7
.byte t1c0
.byte t1d0
.byte t1c1
.byte t1d1
.byte t1c2
.byte t1d2
.byte t1c3
.byte t1d3
.byte t1c4
.byte t1d4
.byte t1c5
.byte t1d5
.byte t1c6
.byte t1d6
.byte t1c7
.byte t1d7

.res 8*4*(16-2) ; spacing for 16x16 sprite

.byte t2a0
.byte t2b0
.byte t2a1
.byte t2b1
.byte t2a2
.byte t2b2
.byte t2a3
.byte t2b3
.byte t2a4
.byte t2b4
.byte t2a5
.byte t2b5
.byte t2a6
.byte t2b6
.byte t2a7
.byte t2b7
.byte t2c0
.byte t2d0
.byte t2c1
.byte t2d1
.byte t2c2
.byte t2d2
.byte t2c3
.byte t2d3
.byte t2c4
.byte t2d4
.byte t2c5
.byte t2d5
.byte t2c6
.byte t2d6
.byte t2c7
.byte t2d7

.byte t3a0
.byte t3b0
.byte t3a1
.byte t3b1
.byte t3a2
.byte t3b2
.byte t3a3
.byte t3b3
.byte t3a4
.byte t3b4
.byte t3a5
.byte t3b5
.byte t3a6
.byte t3b6
.byte t3a7
.byte t3b7
.byte t3c0
.byte t3d0
.byte t3c1
.byte t3d1
.byte t3c2
.byte t3d2
.byte t3c3
.byte t3d3
.byte t3c4
.byte t3d4
.byte t3c5
.byte t3d5
.byte t3c6
.byte t3d6
.byte t3c7
.byte t3d7

charend: