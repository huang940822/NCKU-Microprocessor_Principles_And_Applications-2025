;一?是?到第一?1之前有??0，但不用BRANCH
    List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
	org 0x00
	
	MOVLW	b'11111111'
	MOVWF 0x000
		
	STEP1:
	    MOVLW 0x10;00010000
	    CPFSLT 0x000
	    GOTO STEP2 
	plus4:
		INCF 0x010
		INCF 0x010
		INCF 0x010
		INCF 0x010
	leftShift4:
		RLNCF 0x000
		RLNCF 0x000
		RLNCF 0x000
		RLNCF 0x000
	CLRF WREG
;-----------------------------------	
	STEP2:
	    MOVLW 0x40 ;00100000
	    CPFSLT 0x000
	    GOTO STEP3
	plus2:
		INCF 0x010
		INCF 0x010
	leftShift2:
		RLNCF 0x000
		RLNCF 0x000
	    CLRF WREG
;------------------------------------
	STEP3:
	    MOVLW 0x80
	    CPFSLT 0x000
	    GOTO STEP4
	plus1:
		INCF 0x010
	leftShift1:
		RLNCF 0x000
	    CLRF WREG
;-----------------------------------
	STEP4:
	    BTFSC 0x000,7
	    GOTO END_COMP
	    INCF 0x010
	END_COMP:
    
	end
	
