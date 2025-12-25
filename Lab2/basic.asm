List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00
	TEMP1   EQU 0x20
	TEMP2   EQU 0x21
;step1--------initialization----------
	LFSR 0, 0x120
	MOVLW 0x03
	MOVWF POSTINC0
	MOVLW 0x05
	MOVWF POSTINC0
;step2-------------------------------
	LFSR    0, 0x122
    Loop:
	;取出 [add-2]
	MOVF   FSR0L, W ;把指向0x122的FSR0拿來在WREG裡-2，
	ADDLW 0xFE;0xFE=-2;W=FSR0L-2
	MOVWF  FSR1L;FSR1L=[add-2]=0x20
	INCF FSR1H;FSR1H=0x01 ==> FSR1指向0x120
	MOVF  INDF1, W ;取出FSR1指向的值
	MOVWF   TEMP1
	
	CLRF FSR1H;clear FSR1H
	
	;取出 [add-1]
	MOVF   FSR0L, W
	ADDLW 0xFF;0xFF=-1;W=FSR0L-1
	MOVWF  FSR1L;FSR1L=[add-1]=0x21
	INCF FSR1H;FSR1H=0x01 ==> FSR1指向0x121
	MOVF  INDF1, W;取出FSR1指向的值
	MOVWF   TEMP2
	
	CLRF FSR1H
	odd or even
	MOVF FSR0L,W
	ANDLW 0x01;取出 FSR0L的最後一bit，也就是0x122的0x22，是0。AND完結果存回WREG
	BZ even_case ;如果是0，表示是偶數
    odd_case:
	MOVF TEMP2,W
	SUBWF TEMP1,W;TEMP1-TEMP2
	BRA store
    even_case:
	MOVF TEMP2,W
	ADDWF TEMP1,W
    store:
	MOVWF INDF0
	INCF FSR0L,F
	MOVLW 0x126
	CPFSGT FSR0L;f>0126就跳過LOOP
	BRA Loop
end


