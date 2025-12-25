List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00
	
	initial:
	    MOVLW b'00001000'
	    MOVWF 0x000
	Loop:
	    BTFSC 0x000,7
	    GOTO END_COMP
	    BTFSS 0x000,7
	    INCF 0x010
	    RLNCF 0x000
	    GOTO Loop
	END_COMP:
	end
	    
	
	


