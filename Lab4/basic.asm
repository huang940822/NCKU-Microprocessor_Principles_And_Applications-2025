List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
	org 0x00
;MACRO定義	
And_Mul MACRO xh, xl, yh, yl  
    MOVF    yh, W
    ANDWF   xh, W
    MOVWF   0x000 ;高位AND結果
    
    MOVF    yl, W
    ANDWF   xl, W
    MOVWF   0x001 ;低位AND結果
    
    MOVF    0x000, W
    MOVWF   0x20 ; MULTIPLIER (高位)
    MOVF    0x001, W
    MOVWF   0x21 ; MULTIPLICAND (低位)
    CLRF    0x22 ;高位RESULT
    CLRF    0x23 ;低位RESULT
    MOVLW   0x08 ;八次LOOP計數器
    MOVWF   0x24
MUL_LOOP:
    BTFSS   0x21, 0 ;若最低位為 1，執行加法
    GOTO    SKIP_ADD
    ;加法
    MOVF    0x20, W
    ADDWF   0x23, F ;0x20的乘數加到低位RESULT
    BTFSC   STATUS, C ; 若產生進位
    INCF    0x22, F ;高位+1
SKIP_ADD:
    RRNCF    0x21, F ; 右移被乘數
    RLNCF    0x20, F ; 左移乘數
    DECF    0x24, F
    BNZ     MUL_LOOP
    
    MOVF    0x22, W
    MOVWF   0x010 ; 高位結果
    MOVF    0x23, W
    MOVWF   0x011 ; 低位結果
    
    
endm

    MOVLW 0x55
    MOVWF 0x002
    MOVLW 0x55
    MOVWF 0x003
    MOVLW 0x55
    MOVWF 0x004
    MOVLW 0x55
    MOVWF 0x005
    
    And_Mul 0x002, 0x003, 0x004, 0x005
    
end
