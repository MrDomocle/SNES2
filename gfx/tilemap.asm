.segment "CODE"
mapstart:
.repeat 2*(32*2+4)
   .word $0030
.endrepeat
.word $0040
.word $0041
.word $0042
.word $0043
.repeat (32-4)
   .word $0030
.endrepeat
.word $0050
.word $0051
.word $0052
.word $0053
.repeat (32-4)
   .word $0030
.endrepeat
.word $0060
.word $0061
.word $0062
.word $0063
.repeat (32-4)
   .word $0030
.endrepeat
.word $0070
.word $0071
.word $0072
.word $0073
.repeat (32*12+12)
   .word $0030
.endrepeat
.word $0040
.word $0041
.word $0042
.word $0043
.repeat (32-4)
   .word $0030
.endrepeat
.word $0050
.word $0051
.word $0052
.word $0053
.repeat (32-4)
   .word $0030
.endrepeat
.word $0060
.word $0061
.word $0062
.word $0063
.repeat (32-4)
   .word $0030
.endrepeat
.word $0070
.word $0071
.word $0072
.word $0073
.repeat (8)
   .word $0030
.endrepeat
.word $0040
.word $0041
.word $0042
.word $0043
.repeat (32-4)
   .word $0030
.endrepeat
.word $0050
.word $0051
.word $0052
.word $0053
.repeat (32-4)
   .word $0030
.endrepeat
.word $0060
.word $0061
.word $0062
.word $0063
.repeat (32-4)
   .word $0030
.endrepeat
.word $0070
.word $0071
.word $0072
.word $0073

.repeat (32*3+24)
   .word $0030
.endrepeat
mapend: