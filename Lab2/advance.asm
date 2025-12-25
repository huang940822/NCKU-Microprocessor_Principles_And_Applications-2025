List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00
	
	Length_A   EQU 0x30
	Length_B   EQU 0x31
	TEMP_A  EQU 0x32
	TEMP_B  EQU 0x33
;step1----------initialization------
	LFSR 0, 0x200 ; FSR0 -> A[0]
	LFSR 1, 0x210 ; FSR1 -> B[0]
	LFSR 2, 0x220 ; FSR2 -> C[0]
	;A[]
	MOVLW 0x00
	MOVWF POSTINC0
	MOVLW 0x33
	MOVWF POSTINC0
	MOVLW 0x58
	MOVWF POSTINC0
	MOVLW 0x7A
	MOVWF POSTINC0
	MOVLW 0xC4
	MOVWF POSTINC0
	MOVLW 0xF0
	MOVWF POSTINC0
	LFSR 0,0x200 ;pull back pointer
	;B[]
	MOVLW 0x09
	MOVWF POSTINC1
	MOVLW 0x58
	MOVWF POSTINC1
	MOVLW 0x6E
	MOVWF POSTINC1
	MOVLW 0xB8
	MOVWF POSTINC1
	MOVLW 0xDD
	MOVWF POSTINC1
	LFSR 1,0x210 ;pull back pointer
	
	MOVLW 0x06
	MOVWF Length_A
	MOVLW 0x05
	MOVWF Length_B
	
	
;step2--------------------------------
    check_A:
	MOVF Length_A,W
	BNZ check_B
	BRA copyAll_B
	
    check_B:
	MOVF Length_B,W
	BNZ compare
	BRA copyAll_A
	
;step3-----compare----------------
    compare:
	MOVF INDF0,W ;W=A[i]
	MOVWF TEMP_A
	MOVF INDF1,W ;W=B[i]
	MOVWF TEMP_B
	
	;A<=B?
	MOVF TEMP_B,W
	CPFSLT TEMP_A ;A<=B -> skip
	BRA take_B

    take_A:
	MOVF TEMP_A,W
	MOVWF POSTINC2 ;C[k]=A[i]
	INCF FSR0L,F ;i++ ，指向下一個A[]
	DECF Length_A,F 
	BRA check_A
    take_B:
	MOVF TEMP_B,W
	MOVWF POSTINC2 ;C[k]=B[j]
	INCF FSR1L,F ;j++，指向下一個B[]
	DECF Length_B,F 
	BRA check_A
;step4-----如果其中一個陣列變成0--------
    copyAll_A:
	MOVF Length_A,W
	BZ Done ;A[]是0了，結束
	MOVF INDF0,W
	MOVWF POSTINC2
	INCF FSR0L,F
	DECF Length_A,F
	BRA copyAll_A

    copyAll_B:
	MOVF Length_B,W
	BZ Done ;B[]是0了，結束
	MOVF INDF1,W
	MOVWF POSTINC2
	INCF FSR1L,F
	DECF Length_B,F
	BRA copyAll_B

    Done:
	
end


