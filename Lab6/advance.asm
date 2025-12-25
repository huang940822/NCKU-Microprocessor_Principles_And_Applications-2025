LIST    P=18F4520
#include <p18f4520.inc>

    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    CONFIG LVP = OFF

;----------------------------------
; 變數定義
;----------------------------------
L1      EQU 0x14
L2      EQU 0x15
STATE   EQU 0x16

;----------------------------------
; 延遲 macro (大約 0.75 秒)
;----------------------------------
DELAY   macro num1, num2
    local LOOP1, LOOP2
    MOVLW num2
    MOVWF L2
LOOP2:
    MOVLW num1
    MOVWF L1
LOOP1:
    NOP
    NOP
    NOP
    NOP
    NOP
    DECFSZ L1, 1
    BRA LOOP1
    DECFSZ L2, 1
    BRA LOOP2
endm

;----------------------------------
; 主程式開始
;----------------------------------
ORG 0x00

START:
    MOVLW 0x0F
    MOVWF ADCON1        ; 設定 PORTA 為 digital I/O
    CLRF LATA
    CLRF TRISA          ; RA0~RA2 為輸出
    BSF TRISB, 0        ; RB0 為輸入
    CLRF STATE

MAIN_LOOP:
    ; 等待按鈕按下
WAIT_PRESS:
    BTFSC PORTB, 0       ; 若RB0=1(未按下)，則繼續等待
    BRA WAIT_PRESS

    ; 去除彈跳
    DELAY d'111', d'10'
    BTFSC PORTB, 0
    BRA WAIT_PRESS

    ;--------------------------------
    ; 按下後，自動執行整個LED循環
    ;--------------------------------
    CALL LED_SEQUENCE

    ; 等待放開按鈕
WAIT_RELEASE:
    BTFSS PORTB, 0
    BRA WAIT_RELEASE
    DELAY d'111', d'10'
    BRA MAIN_LOOP


;--------------------------------
; 子程序：LED_SEQUENCE
;--------------------------------
LED_SEQUENCE:
    ; 狀態 1：RA0亮
    MOVLW b'001'
    MOVWF LATA
    DELAY d'111', d'210'

    ; 狀態 2：RA1亮
    MOVLW b'010'
    MOVWF LATA
    DELAY d'111', d'210'

    ; 狀態 3：RA0、RA1亮
    MOVLW b'011'
    MOVWF LATA
    DELAY d'111', d'210'

    ; 狀態 4：RA0、RA2亮
    MOVLW b'101'
    MOVWF LATA
    DELAY d'111', d'210'

    ; 狀態 5：全暗
    CLRF LATA
    DELAY d'111', d'210'

    RETURN

END
