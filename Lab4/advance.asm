    LIST    P=18F4520
    #include <p18f4520.inc>
    CONFIG  OSC = INTIO67, WDT = OFF

    ORG     0x00
    ;測資
    MOVLW   0xFA
    MOVWF   0x000
    MOVLW   0x9F
    MOVWF   0x001
    MOVLW   0x03
    MOVWF   0x002
    MOVLW   0x45
    MOVWF   0x003
	division:
	    CLRF 0X010 ;商數高位
	    CLRF 0X011 ;商數低位
	    CLRF 0X012 ;餘數高位
	    CLRF 0X013 ;餘數低位
	    MOVLW 0x10 ;計數器=16
	    MOVWF 0x004       

	    MOVFF 0X000, 0X005 ;被除數先複製到0x005 0x006
	    MOVFF 0X001, 0X006
	    CLRF 0x010       ; Quotient High
	    CLRF 0x011       ; Quotient Low
	    BCF STATUS, C ;清空C flag
	    
	    LOOP:
		RLCF 0X013 ;餘數整個左移一次
		RLCF 0X012
		;範例
		;STATUS.C = 0
		;0x012: 0000 0011b
		;0x013: 1010 0110b
		;經過RLCF 0x013
		;STATUS.C = 1
		;0x013: 0100 1100b
		;經過RLCF 0x012
		;STATUS.C = 0
		;0x012: 0000 0111b
		BCF STATUS, C;清空C flag
		RLCF 0X011 ;商數也整個左移一次
		RLCF 0X010
		
		RLCF 0X006 ;被除數也整個左移一次
		RLCF 0X005 
		BTFSC STATUS, C ;這樣c就等於下一個要拉下來參與除法的那個bit
		INCF 0X013 ;拉下來的是1就在餘數加1
		COMPARE_HIGH8BIT:
		    MOVF 0X012, WREG	;餘數高位
		    CPFSGT 0X002 ;如果除數高位>餘數高位(不能減了) 跳到SKIP
		    GOTO COMPARE_LOW8BIT ;如果除數高位<=餘數高位，則比低位
		    GOTO SKIP
		COMPARE_LOW8BIT: 
		    CPFSEQ 0X002 ;如果除數高位=餘數高位，跳過MINUS，去比較低位
		    GOTO MINUS
		    MOVF 0X013, WREG
		    CPFSGT 0X003 ;如果除數低位>餘數低位(不能減了)，跳過MINUS，去SKIP
		    GOTO MINUS
		    GOTO SKIP
		MINUS:
		    ;餘數減除數
		    MOVF    0x003, WREG       ; W = B_L
		    SUBWF   0x013       ; W = A_L - B_L
		    MOVF    0x002, WREG       ; W = B_H
		    SUBWFB  0x12       ; W = A_H - B_H - borrow 
		    ;MOVF 0X010, WREG
		    CLRF WREG
		    INCF 0X011 ;商數加1
		    BTFSC STATUS,C
		    ADDWFC 0X010
		    
	    SKIP:
	    DECFSZ 0X004
	    GOTO LOOP
	    RETURN
END
