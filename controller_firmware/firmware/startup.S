;
; Startup code for cc65 (C64 version)
;
; This must be the *first* file on the linker command line
;

;	.export		_exit
	.import		initlib, donelib
       	.import	       	zerobss, push0
	.import _main
        .import         RESTOR, BSOUT, CLRCH
	.import     __STARTUP_LOAD__
	.import		__RAM_START__, __RAM_SIZE__	; Linker generated
	.import      __STARTUP_SIZE__,__CODE_SIZE__,__RODATA_SIZE__,__DATA_SIZE__

	.include        "zeropage.inc"


; ------------------------------------------------------------------------
; Place the startup code in a special segment.

.segment "UCOMMAND"
.byte $75 ;u
.word __STARTUP_LOAD__
.word (__STARTUP_SIZE__+__CODE_SIZE__+__RODATA_SIZE__+__DATA_SIZE__)

.segment "JCOMMAND"
.byte $6a ;j
.word __STARTUP_LOAD__
.segment       	"STARTUP"

; ------------------------------------------------------------------------
; Actual code

startup:
;int off, setup stack
	sei
	ldx #$ff
	txs

;now we do the rest of the C startup stuff
; Clear the BSS data

	jsr	zerobss

	lda    	#<(__RAM_START__ + __RAM_SIZE__)
	sta	sp
	lda	#>(__RAM_START__ + __RAM_SIZE__)
	sta	sp+1   		; Set argument stack ptr

; Call module constructors

	jsr	initlib

	jmp _main
	
; ------------------------------------------------------------------------
; Data

.data
