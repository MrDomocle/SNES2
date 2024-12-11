.macro doDMA a_addr, a_bank, b_addr, len, control
   ; a_addr: 16-bit (long) address in A bus
   ; a_bank: bank in A bus
   ; b_addr: write register address' (e.g. VMDATAL/$2118 gives b_addr $18) LSB ($21 always as MSB)
   ; len: bytes to copy
   ; control: DMAPx: see DMA.png

   setXY16 ; X needs to be 16-bit for DMA

   ldx #a_addr ; source address (16-bit)
   stx A1TxL
   
   lda #a_bank
   sta A1Bx ; source bank

   lda #b_addr ; LSB of B write register
   sta BBADx

   ldx #len; number of bytes to copy
   stx DASxL
   
   lda #control ; configure how DMA should be done. see DMA.png (this is $43x0)
   sta DMAPx
   
   lda #1
   sta MDMAEN ; start transfer

   setXY8
.endmacro

.macro setA8
	sep #$20
   .a8
.endmacro

.macro setA16
	rep #$20
   .a16
.endmacro

.macro setAXY8
	sep #$30
   .a8
   .i8
.endmacro

.macro setAXY16
	rep #$30
   .a16
   .i16
.endmacro

.macro setXY8
	sep #$10
   .i8
.endmacro

.macro setXY16
	rep #$10
   .i16
.endmacro