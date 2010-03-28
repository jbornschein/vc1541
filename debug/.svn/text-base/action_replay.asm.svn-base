0150    SEI
0151    JSR 018F
0154    LDA #7A
0156    STA 1802 ;set drive number bits to output -- mask out?
0159    JSR F5E9 ;calculate xor over page ($30)??? delay?
015C    JSR 0162
015F    JMP 0300
0162    LDY #00
0164    LDA #00
0166    STA 1800;release all lines
0169    LDA 1800
016C    BNE 0169 ;wait for line release from c64
016E    PHP
016F    LDA 1800 ;get line states  
0172    ASL ;0000c0d0
0173    PLP
0174    EOR 1800 ; a000cCdD
0177    ASL
0178    ASL
0179    ASL ; 0cCdD000
017A    NOP
017B    NOP
017C    NOP
017D    EOR 1800 ;0cCdDc0d
0180    ASL
0181    NOP
0182    NOP
0183    NOP
0184    EOR 1800 ;cCdDcCdD
0187    STA 0300,y
018A    INY
018B    NOP
018C    NOP
018D    BNE 0169
018F    LDA #08
0191    STA 1800 ;clk out low
0194    RTS
0195    JSR 0000
0198    BRK

02af  wird von 0305 0xff ???

0300    TSX
0301    STX 033D; save s
0304    DEY	;y is 00
0305    STY 02AF ; y is ff
0308    INY
0309    STY 11
030B    INY
030C    STY 1C;flag for diskchange
030E    LDA #20
0310    STA 1C07;Timer 1-Latch High-Byte (IRQ Timer)
0313    JSR C100;LED an, int an
0316    SEI
0317    LDX 0205;teil des M-E befehls, wieviele Blöcke ab $400 laden? (2)
031A    LDA #04
031C    STA 0189
031F    JSR 0162 ;Weitere Blöcke laden
0322    INC 0189
0325    DEX
0326    BNE 031F ;soviele wie angegeben
0328    LDA 0208
032B    STA 03A7 ; befehl für 03a7 (bit?!?)
032E    JMP (0206) ;wo weiter? (0331)
0331    JSR 05BD ;code nach $0600 kopieren und möglicherweise $447 patchen
0334    JSR 036C ; ein byte in a laden, y wird 0
0337    BMI 0345 ; >7f : goto 345
0339    STA 026C ; nach fehlerflag speichern
033C    LDX #43 ;stack wieder herstellen
033E    TXS
033F    JSR 03AC ;hm? mumpitz? lösche int flag?
0342    JMP C194 ; befehl abschliessen; o.k. oder fehlermeldung
0345    TAX
0346    JSR 0371 ; read track number
0349    STA 0E ;buffer 4
034B    STA 08 ;buffer 1
034D    JSR 0371 ; read sector number
0350    STA 09 ; buffer 4
0352    STA 0F ; buffer 1
0354    TXA
0355    CMP #E0 ; e0?
0357    BNE 0360
0359    LDX #01
035B    JSR 0387 ; job e0 ausführen(switch drive on and find track, execute buffer(0400))
035E    BCC 0334 ;branch always
0360    CMP #80 ; 80?
0362    BNE 0367
0364    JMP 0600 ;80 : job 80, sector lesen und zum c64
0367    LDA #B0 
0369    JMP 05A3 ; else: job b0
;ein byte vom c64 in a laden
;call from 0334
036C    LDY #00
036E    STY 0189 ;lader auf page 0 patchen
;call from 346
0371    DEY ;byte zeiger auf $ff
0372    JSR 0164 ; ein byte nach $00ff laden ?!? warum so kompliziert??
0375    LDA FF ;byte in a
0377    STY FF ; 0 nach $00ff
0379    RTS ;fertig

037A    STA 0189
037D    JMP 0162
0380    LDA #90
0382    .byte 2c (bit $80a9)
;call from 0600
0383    LDA #80  ;read sector buffer 4
;call from 05A3
0385    LDX #04
;call from 035b: x=1 a=E0
0387    STX F9
0389    PHA
038A    LDA 11
038C    BNE 0393 ;run for first time?
038E    LDA #B0 ;yes: einmal job $00 setzen
0390    JSR 0396
0393    PLA
0394    STA 11 ;11 = e0
0396    SEI
0397    JSR D57D ; a nach $00+x, $25d+x und $24d speichern ( als job für puffer x)
039A    JSR 03AC ;clear atn interrupt
039D    CLI
039E    JSR D599 ;warten auf ende des jobs
03A1    SEI
03A2    LDA 1801
03A5    AND #DF
;jump from 03b1
03A7    BIT 1801 ;?? könnte auch sta sein, patch von 032b
03AA    CLC
03AB    RTS
;call from 033f
;call from 0397
03AC    LDA #20
03AE    ORA 1801 ;check for some mumpitz on free porta?
03B1    BNE 03A7 ;hm, jump allways?
;call from 0603
03B3    LDA #00
03B5    .byte 2c
03B6    LDA #FF
;transmit byte in a to c64, inc y
03B8    STY 10 ;save y
03BA    TAY ;save a in y
03BB    AND #0F ; low nibble
03BD    TAX ; low nibble to x
03BE    TYA ; get byte back
03BF    LSR
03C0    LSR
03C1    LSR
03C2    LSR
03C3    TAY ;high nibble to y
03C4    LDA 03EF,x ;encode low nibble
03C7    LDX #00
03C9    STX 1800 ; release lines
03CC    LDX 1800
03CF    BNE 03CC ;wait for lines low from c64
03D1    STA 1800 ;put on bus
03D4    ASL
03D5    AND #0F
03D7    STA 1800 ; put other bits on bus
03DA    LDA 03EF,y ;encode high nibble
03DD    STA 1800 ;put on bus
03E0    ASL
03E1    AND #0F
03E3    STA 1800 ;put other bits on bus
03E6    LDY 10 ; restore y
03E8    LDA #08
03EA    INY ; inc y
03EB    STA 1800 ;clk low
03EE    RTS

03ef:
0F 07 0D 05 0B 03 09 01 0E 06 0C 04 0A 02 08 00
20

0400    JSR 03A1 ; int flag löschen
0403    LDX 43
0405    STX C3
0407    LDA #07
0409    STA 31
040B    LDA #FF
040D    STA 07DF,x
0410    DEX
0411    BNE 040D
0413    LDA #7F
0415    STA C2
0417    LDA 43
0419    JSR 03B8
041C    DEC C2
041E    BNE 0423
0420    JMP 059D
0423    LDX #FF
0425    TXS
0426    DEX
0427    BEQ 0420
0429    JSR F556
042C    BVC 042C
042E    CLV
042F    LDA 1C01
0432    CMP 24
0434    BNE 0426
0436    INY
0437    BVC 0437
0439    CLV
043A    LDA 1C01
043D    STA (30),y
043F    INY
0440    CPY #04
0442    BNE 0437
0444    LDY #02
0446    JSR F82B;447:smf
0449    LDX 54
044B    CPX 43
044D    BCS 041C
044F    LDA 07E0,x
0452    BPL 041C
0454    TXA
0455    STA 07E0,x
0458    JSR F556
045B    LDY #40
045D    BVC 045D
045F    CLV
0460    LDA 1C01
0463    LSR
0464    STA 0741,y
0467    BVC 0467
0469    CLV
046A    LDA 1C01
046D    ROR
046E    STA 0700,y
0471    AND #1F
0473    STA 063D,y
0476    BVC 0476
0478    CLV
0479    LDA 1C01
047C    TAX
047D    ROR
047E    LSR
047F    LSR
0480    LSR
0481    STA 0782,y
0484    BVC 0484
0486    CLV
0487    LDA 1C01
048A    STA 067E,y
048D    ASL
048E    TXA
048F    ROL
0490    AND #1F
0492    STA 06BF,y
0495    BVC 0495
0497    CLV
0498    LDA 1C01
049B    PHA
049C    AND #1F
049E    STA 05BF,y
04A1    DEY
04A2    BPL 045D
04A4    LDX #FF
04A6    TXS
04A7    LDX #40
04A9    LDA 0741,x
04AC    LSR
04AD    ROR 0700,x
04B0    LSR
04B1    STA 0741,x
04B4    LDA 0700,x
04B7    ROR
04B8    LSR
04B9    LSR
04BA    LSR
04BB    STA 0700,x
04BE    LDA 067E,x
04C1    LSR
04C2    ROR 01BF,x
04C5    LSR
04C6    AND #1F
04C8    STA 067E,x
04CB    LDA 01BF,x
04CE    ROR
04CF    LSR
04D0    LSR
04D1    LSR
04D2    PHA
04D3    DEX
04D4    BPL 04A9
04D6    LDA 54
04D8    JSR 03B8
04DB    LDA 1800
04DE    LSR
04DF    BCS 04DB
04E1    LDA #00
04E3    STA 1800
04E6    NOP
04E7    NOP
04E8    LDA #08
04EA    STA 1800
04ED    BIT 80
04EF    LDA #00
04F1    STA 1800
04F4    NOP
04F5    LDA #08
04F7    STA 1800
04FA    LDX #3F
04FC    LDA #00
04FE    STA 1800
0501    LDY 0783,x
0504    LDA 060B,y
0507    STA 1800
050A    ASL
050B    AND #0F
050D    STA 1800
0510    LDY 063E,x
0513    LDA 060B,y
0516    STA 1800
0519    ASL
051A    AND #0F
051C    STA 1800
051F    LDY 067F,x
0522    LDA 060B,y
0525    STA 1800
0528    ASL
0529    AND #0F
052B    STA 1800
052E    LDY 06C0,x
0531    LDA 060B,y
0534    STA 1800
0537    ASL
0538    AND #0F
053A    STA 1800
053D    LDY 05C0,x
0540    LDA 060B,y
0543    STA 1800
0546    ASL
0547    AND #0F
0549    STA 1800
054C    LDY 01C0,x
054F    LDA 060B,y
0552    STA 1800
0555    ASL
0556    AND #0F
0558    STA 1800
055B    LDY 0700,x
055E    LDA 060B,y
0561    STA 1800
0564    ASL
0565    AND #0F
0567    STA 1800
056A    LDY 0741,x
056D    LDA 060B,y
0570    STA 1800
0573    ASL
0574    AND #0F
0576    STA 1800
0579    LDA #08
057B    DEX
057C    BMI 0584
057E    STA 1800
0581    JMP 04FC
0584    STA 1800
0587    LDX 0782
058A    LDA F8C0,x
058D    LDX 063D
0590    ORA F8A0,x
0593    JSR 03B8
0596    DEC C3
0598    BEQ 059D
059A    JMP 0423
059D    JSR 03B6
05A0    JMP F418


05A3    JSR 0385 ; job b0: find sector buffer 4
05A6    JSR 036C ; get byte from c64 in a
05A9    STA 8C ; to 8c
05AB    JSR 036C 
05AE    STA 8D ; and to 8d
05B0    LDX #03
05B2    INC 0207 ; jump nach $ 400 ändern
05B5    LDA #00
05B7    STA 0206
05BA    JMP 031A ; neuen code nach $400 - $5ff laden
05BD    LDX #3C; 3c bytes von 05d3 nach 0600 kopieren
05BF    LDA 05D3,x
;ab hier wird später überschrieben.
05C2    STA 0600,x
05C5    DEX
05C6    BPL 05BF
05C8    LDA F81F ;umwandlung gcr->binär; (B1)
05CB    BMI 05D2
05CD    LDA #1A ;bei irgendner anderen 1541 revision
05CF    STA 0447;code patchen
05D2    RTS
;ab hier kopieren:
05D3    JSR 0383
05D6    JSR 03B3
05D9    LDY #00
05DB    LDA 0700,y
05DE    JSR 03B8
05E1    BNE 05DB
05E3    JMP 0334


0600    JSR 0383 ; read sector buffer 4
0603    JSR 03B3 ; 0 byte senden
0606    LDY #00
0608    LDA 0700,y
060b    JSR 03B8 ; puffer zum c64 kopieren
060e    BNE 0608
0610    JMP 0334 ; fertig: await command
0613:
			  FF 0E 0F 07 FF 0A 0B 03 FF FF 0D 05 FF
00 09 01 FF 06 0C 04 FF 02 08 FF 4C 00 00 00 00
00 00 00 00 00 00 00 00 00 00 00 00 00
