.segment "CODE"
mapstart:
.repeat 34
.word t0
.endrepeat
.word t1
.repeat 20
.word t0
.endrepeat
.word t2
.word t3
.word t4
.word t5
.repeat 14
.word t0
.endrepeat
.word t1
.repeat 13
.word t0
.endrepeat
.word t6
.word t7
.word t8
.word t9
.repeat 28
.word t0
.endrepeat
.word t10
.word t11
.word t12
.word t13
.repeat 8
.word t0
.endrepeat
.word t2
.word t3
.word t4
.word t5
.repeat 16
.word t0
.endrepeat
.word t14
.word t15
.word t16
.word t17
.repeat 8
.word t0
.endrepeat
.word t6
.word t7
.word t8
.word t9
.repeat 14
.word t0
.endrepeat
.word t18
.repeat 13
.word t0
.endrepeat
.word t10
.word t11
.word t12
.word t13
.repeat 6
.word t0
.endrepeat
.word t19
.repeat 21
.word t0
.endrepeat
.word t14
.word t15
.word t16
.word t17
.repeat 76
.word t0
.endrepeat
.word t18
.repeat 42
.word t0
.endrepeat
.word t19
.repeat 13
.word t0
.endrepeat
.word t1
.repeat 21
.word t0
.endrepeat
.word t18
.repeat 51
.word t0
.endrepeat
.word t2
.word t3
.word t4
.word t5
.repeat 16
.word t0
.endrepeat
.word t18
.repeat 11
.word t0
.endrepeat
.word t6
.word t7
.word t8
.word t9
.repeat 28
.word t0
.endrepeat
.word t10
.word t11
.word t12
.word t13
.repeat 28
.word t0
.endrepeat
.word t14
.word t15
.word t16
.word t17
.repeat 41
.word t0
.endrepeat
.word t18
.repeat 39
.word t0
.endrepeat
.word t18
.repeat 53
.word t0
.endrepeat
.word t2
.word t3
.word t4
.word t5
.repeat 12
.word t0
.endrepeat
.word t19
.repeat 7
.word t0
.endrepeat
.word t1
.repeat 7
.word t0
.endrepeat
.word t6
.word t7
.word t8
.word t9
.repeat 28
.word t0
.endrepeat
.word t10
.word t11
.word t12
.word t13
.repeat 28
.word t0
.endrepeat
.word t14
.word t15
.word t16
.word t17
.repeat 4
.word t0
.endrepeat
.word t1
.repeat 98
.word t0
.endrepeat
.word t2
.word t3
.word t4
.word t5
.repeat 13
.word t0
.endrepeat
.word t1
.repeat 14
.word t0
.endrepeat
.word t6
.word t7
.word t8
.word t9
.repeat 28
.word t0
.endrepeat
.word t10
.word t11
.word t12
.word t13
.repeat 18
.word t0
.endrepeat
.word t19
.repeat 9
.word t0
.endrepeat
.word t14
.word t15
.word t16
.word t17
.repeat 8
.word t0
.endrepeat
.word t19
.repeat 39
.word t0
.endrepeat
.word t0
mapend:
t0 = $0030; #transparent
t1 = $0040; #010000
t2 = $0040; #000001
t3 = $0041; #000002
t4 = $0042; #000003
t5 = $0043; #000004
t6 = $0050; #000005
t7 = $0051; #000006
t8 = $0052; #000007
t9 = $0053; #000008
t10 = $0060; #000009
t11 = $0061; #00000a
t12 = $0062; #00000b
t13 = $0063; #00000c
t14 = $0070; #00000d
t15 = $0071; #00000e
t16 = $0072; #00000f
t17 = $0073; #000010
t18 = $0070; #020000
t19 = $0073; #030000

empty_tile: .word t0