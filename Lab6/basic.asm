LIST    P=18F4520
#include <p18f4520.inc>

    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    CONFIG LVP = OFF

L1      EQU 0x14
L2      EQU 0x15
STATE   EQU 0x16

ORG 0x00

;DELAY的MACRO
DELAY macro num1, num2
    local LOOP1
    local LOOP2
    
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
    DECFSZ L1,1
    BRA LOOP1
    DECFSZ L2,1
    BRA LOOP2
endm


START:
    MOVLW 0x0F
    MOVWF ADCON1        ; 將PORTA設為digital I/O
    CLRF LATA
    CLRF TRISA          ; RA0~RA2 為輸出
    BSF TRISB,0         ; RB0 為輸入
    CLRF STATE          ; 初始全暗

MAIN_LOOP:
    ; 等待按鈕按下
WAIT_PRESS:
    BTFSC PORTB,0       ; 若RB0=1(未按下)，則繼續等待
    BRA WAIT_PRESS

    ; 去除bounce
    DELAY d'111', d'10'
    BTFSC PORTB,0
    BRA WAIT_PRESS

    ;------------------------------------
    ; 按下後狀態 +1
    ;------------------------------------
    INCF STATE,F
    MOVLW d'4'
    CPFSLT STATE        ; STATE < 4 → ok；STATE >= 4 → 清零
    CLRF STATE

    ;------------------------------------
    ; 根據STATE決定LED狀態
    ;------------------------------------
    CLRF LATA           ; 全暗

    MOVF STATE,W
    XORLW d'0'
    BZ LED_OFF

    MOVF STATE,W
    XORLW d'1'
    BZ LED_RA0

    MOVF STATE,W
    XORLW d'2'
    BZ LED_RA1

    MOVF STATE,W
    XORLW d'3'
    BZ LED_RA2

LED_OFF:
    CLRF LATA
    BRA WAIT_RELEASE

LED_RA0:
    MOVLW b'001'
    MOVWF LATA
    BRA WAIT_RELEASE

LED_RA1:
    MOVLW b'010'
    MOVWF LATA
    BRA WAIT_RELEASE

LED_RA2:
    MOVLW b'100'
    MOVWF LATA
    BRA WAIT_RELEASE

WAIT_RELEASE:
    ; 等待放開按鈕
RELEASE_LOOP:
    BTFSS PORTB,0
    BRA RELEASE_LOOP
    DELAY d'111', d'10'
    BRA MAIN_LOOP

END
