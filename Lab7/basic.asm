LIST    P=18F4520
#include <p18f4520.inc>

    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    CONFIG LVP = OFF

	L1      EQU 0x14
	L2      EQU 0x15
      COUNTER_STATE EQU 0x16

ORG 0x00
goto Initial			; 避免程式一開始就會執行子程式 
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

;DEBOUNCE子程式
DEBOUNCE_SUB:
    DELAY d'250', d'5'  ; 約 25ms 延遲
    RETURN
        
Initial:				; 初始化的相關設定
    MOVLW 0x0F
    MOVWF ADCON1		; 設定成要用數位的方式，Digitial I/O 
    
    CLRF TRISD          ; 設定 PORTD (RD7-RD4) 為輸出
    CLRF LATD           ; 關閉所有 LED
    BSF TRISB,  0	 ;設定 TRISB, bit 0 (RB0) 為輸入 (按鈕)
    
    CLRF COUNTER_STATE  ; 預設啟動狀態 (State 1) 的計數器為 0
    GOTO STATE1_LOOP    ; 跳至 State 1 (Count-Up)
STATE1_LOOP:
    ; COUNTER_STATE 存的是 0000_XXXX
    ; 我們要顯示在 RD7-RD4, 所以要變成 XXXX_0000
    SWAPF COUNTER_STATE, W  ; 將高低 nibble 交換, 結果存入 W
    MOVWF LATD      ; 輸出到 LATD (RD7-RD4)
    
    DELAY d'222', d'112'
    
    INCF COUNTER_STATE, F ;計數器加1，讓燈泡換一種亮
    MOVLW 0x10              ; W = 16 (0x10)
    CPFSEQ COUNTER_STATE    ; 比較 COUNTER_STATE 是否等於 16? (跳過 if =) ;16表示跑完了
    BRA CHECK_BUTTON_S1     ; 不等於 16, 跳去檢查按鈕
    CLRF COUNTER_STATE      ; 等於 16 (剛從 15 溢位), 重設為 0
    
CHECK_BUTTON_S1:
    BTFSC PORTB, 0          ; 檢查 RB0 (PORTB, bit 0)
                             ; BTFSC = Skip if C (bit is 1, 沒按)
    BRA STATE1_LOOP         ; 沒按 (bit=1), 回到 S1 迴圈頂部
    CALL DEBOUNCE_SUB       ; 呼叫去彈跳延遲
    BTFSC PORTB, 0          ; 再次檢查 (Skip if C, bit is 1, 沒按)
    BRA STATE1_LOOP         ; 是雜訊 (彈跳), 按鈕並未真的按下
    
WAIT_REL_S1:
    BTFSS PORTB, 0          ; 檢查 RB0 (PORTB, bit 0)
                            ; BTFSS = Skip if S (bit is 0, 按著)
    BRA WAIT_REL_S1         ; 持續等待 (還按著)
    
    ;按鈕已放開 (bit=1), 準備切換到 State 2
    MOVLW d'15'             ; 載入 State 2 的初始值 (15)
    MOVWF COUNTER_STATE     ; 存入計數器
    BRA STATE2_LOOP         ; 跳至 State 2
    
STATE2_LOOP:
    SWAPF COUNTER_STATE, W  ; 0000_XXXX -> XXXX_0000
    MOVWF LATD              ; 輸出到 RD7-RD4
    
    DELAY d'138', d'100'    ; 約 0.5 秒延遲
    
    DECF COUNTER_STATE, F   ; 計數器 - 1
    MOVLW 0xFF              ; W = -1 (0xFF)
    CPFSEQ COUNTER_STATE    ; 比較 COUNTER_STATE 是否等於 -1? (跳過 if =)
    BRA CHECK_BUTTON_S2     ; 不等於 -1, 跳去檢查按鈕
    MOVLW d'15'             ; 等於 -1 (剛从 0 變來), 重設為 15
    MOVWF COUNTER_STATE
    
CHECK_BUTTON_S2:
    ;檢查按鈕
    BTFSC PORTB, 0          ; 檢查 RB0 (Skip if C, bit is 1, 沒按)
    BRA STATE2_LOOP         ; 沒按, 回到 S2 迴圈頂部
    ;按鈕被按下了, 執行去彈跳
    CALL DEBOUNCE_SUB
    BTFSC PORTB, 0
    BRA STATE2_LOOP         ; 是雜訊
WAIT_REL_S2:
    BTFSS PORTB, 0          ; 檢查 RB0 (Skip if S, bit is 0, 按著)
    BRA WAIT_REL_S2         ; 持續等待
    ;按鈕已放開, 切換到 State 1
    CLRF COUNTER_STATE      ; 重設 State 1 的初始值 (0)
    BRA STATE1_LOOP         ; 跳至 State 1
    
END


