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
	.import		__RAM_START__, __RAM_SIZE__	; Linker generated
	.import		__DATA_LOAD__,__DATA_RUN__,__DATA_SIZE__;

    .include        "zeropage.inc"


; ------------------------------------------------------------------------
; Place the startup code in a special segment.


.segment       	"VECTORS"

.word startup	;reset vector
.word startup	;interrupt vector


.segment       	"STARTUP"

; ------------------------------------------------------------------------
; Actual code

startup:
;int off, setup stack
	sei
	ldx #$ff
	txs

;now we copy the data segment to ram
	lda	#<(__DATA_LOAD__)
	sta	$fb
	lda	#>(__DATA_LOAD__)
	sta	$fc
	lda	#<(__DATA_RUN__)
	sta	$fd
	lda	#>(__DATA_RUN__)
	sta	$fe
	ldy	#$00
	ldx	#((>(__DATA_SIZE__))+1)
scpylp:
	dex
	beq  scpylp1
scpylp2:
	lda	($fb),y
	sta	($fd),y
	iny
	bne	scpylp2
	inc	$fc
	inc	$fe
	jmp  scpylp
	
scpylp1:
	lda	($fb),y
	sta	($fd),y
	iny
	cpy	#<(__DATA_SIZE__)
	bne	scpylp1

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
