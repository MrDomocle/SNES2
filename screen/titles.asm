.segment "CODE"
NULL = 0 ; end of text character

title_main: .asciiz "SPACE SHOOTER"
title_main_ofs: .word 32*12+9

title_credits: .asciiz "GAME BY MRDOMOCLE"
title_credits_ofs: .word 32*24+7

title_credits1: .asciiz "BG ART BY ALEXREN"
title_credits1_ofs: .word 32*26+7

title_win: .asciiz "GAME COMPLETE"
title_win_ofs: .word 32*12+9
title_lose: .asciiz "GAME OVER"
title_lose_ofs: .word 32*12+11

score_text: .asciiz "SCORE"
score_text_ofs: .word 32*1+1
score_num_ofs: .word 32*1+1+6