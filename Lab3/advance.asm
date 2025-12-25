        LIST p=18F4520
        #include <p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        ORG 0x00
	
	MIN_H   EQU 0x000    ; 被減數高位 (Minuend high byte)
	MIN_L   EQU 0x001    ; 被減數低位 (Minuend low byte)
	SUB_H   EQU 0x010    ; 減數高位 (Subtrahend high byte)
	SUB_L   EQU 0x011    ; 減數低位 (Subtrahend low byte)
	RES_H   EQU 0x020    ; 結果高位 (Result high byte)
	RES_L   EQU 0x021    ; 結果低位 (Result low byte)
	TEMP    EQU 0x030    ; 暫存暫存器
	;測資
	MOVLW   0x9A
        MOVWF   MIN_H ;被減數高位 = 0x9A
        MOVLW   0xBC
        MOVWF   MIN_L; 被減數低位 = 0xBC

        MOVLW   0x12
        MOVWF   SUB_H; 減數高位 = 0x12
        MOVLW   0x34
        MOVWF   SUB_L; 減數低位 = 0x34
	;step1-------------低位減法----------------------
	MOVF    SUB_L, W     
        COMF    WREG, W ; W = NOT(SUB_L)
        MOVWF   TEMP  ; 暫存在 TEMP
        INCF    TEMP, F   ; +1 變二補數
	
	MOVF    MIN_L, W      
        ADDWF   TEMP, W  ; W = MIN_L + (NOT SUB_L + 1)
        MOVWF   RES_L   ; 存結果低位
        BTFSC   STATUS, C  ; 如果 C=1 => 無借位；C=0 => 有借位
        GOTO    HIGHBYTE_NO_BORROW
	
    HIGHBYTE_BORROW:	
	MOVF SUB_H,W
	COMF WREG,W;SUB_H一補數
	MOVWF TEMP
	INCF TEMP,F;SUB_H二補數
	MOVF MIN_H,W
	ADDWF TEMP,W ;減法
	DECF WREG,W ;扣掉1因為有borrow
	MOVWF RES_H
	GOTO Done
	
    HIGHBYTE_NO_BORROW:
        MOVF    SUB_H, W
        COMF    WREG, W
        MOVWF   TEMP
        INCF    TEMP, F
        MOVF    MIN_H, W
        ADDWF   TEMP, W
        MOVWF   RES_H

    Done:
end

;如果可以用SUBWFB
; 低位減法
        ;MOVF    SUB_L, W         ; W = SUB_L
        ;SUBWF   MIN_L, W         ; W = MIN_L - SUB_L
        ;MOVWF   RES_L            ; 存結果低位

; 高位減法（帶借位）
        ;MOVF    SUB_H, W         ; W = SUB_H
        ;SUBWFB  MIN_H, W         ; W = MIN_H - SUB_H - borrow
        ;MOVWF   RES_H            ; 存結果高位
