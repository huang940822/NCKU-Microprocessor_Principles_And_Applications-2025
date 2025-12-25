LIST    P=18F4520
#include <p18f4520.inc>

    CONFIG OSC = INTIO67
    CONFIG WDT = OFF
    CONFIG LVP = OFF
    
    COUNT       EQU 0x20 ;燈泡的變化計數
    TICK_CNT    EQU 0x21 ;中斷次數計數器
    org 0x00
    GOTO Initial
ISR:				
    org 0x08                
    INCF TICK_CNT, F ;中斷次數加一
    ;判斷需要幾個 Tick(0.5秒，在Initial裡設定的)
    BTFSC COUNT, 0        ; 判斷奇偶(LSB=1) (測試 COUNT 的 bit 0)
    MOVLW d'1'            ; 0.5秒 (1次tick) 放到WREG等待判斷
    BTFSS COUNT, 0        ; 判斷奇偶(LSB=0) (測試 COUNT 的 bit 0)
    MOVLW d'2'            ; 1秒 (2次tick)
    BCF PIR1, TMR2IF        ; 離開前記得把TMR2IF清空 (清空flag bit)
    
    XORWF TICK_CNT, W     ; 以需要1秒為例，如果要兩次tick，但目前只執行一次，就提前離開ISR，不更新狀態，直到下一個0.5秒後再來
    BTFSS STATUS, 2	    ; 如果要兩次tick，目前執行了兩次，就跳過RETFIE繼續執行
    RETFIE
    ; === 已經達到目標時間了 ===
    CLRF TICK_CNT         ; 清除 Tick 計數
    
    ; ===== COUNT-1 =====
    DECF COUNT, F
    BTFSS COUNT, 4        ; 檢查 COUNT有沒有 < 0，如果有 -> Bit4會是1(因為溢位變成255)
        BRA UPDATE_DISPLAY ;是1表示變-1了就跳過UPDATE_DISPLAY，先把COUNT調回15，再UPDATE_DISPLAY
    MOVLW d'15'
    MOVWF COUNT

UPDATE_DISPLAY:
    MOVF COUNT, W
    SWAPF WREG, W         ; 題目要求顯示在RD7-RD4，所以要高低位交換
    ANDLW b'11110000'     ; 保證低位都是0，只保留高位
    MOVWF LATD            ; 顯示

    RETFIE
;到這裡都屬於ISR
Initial:			
    MOVLW 0x0F
    MOVWF ADCON1
    CLRF TRISD
    CLRF LATD
    ;一開始全亮
    BSF LATD, 7
    BSF LATD, 6
    BSF LATD, 5
    BSF LATD, 4
    
    MOVLW D'15'
    MOVWF COUNT
    CLRF TICK_CNT
    
    ; === TIMER2 啟動 ===
    BSF RCON, IPEN              ;啟用優先級
    BSF INTCON, GIE		;啟用Interrupt
    BCF PIR1, TMR2IF		; 為了使用TIMER2，所以要設定好相關的TMR2IF、TMR2IE、TMR2IP。
    BSF IPR1, TMR2IP
    BSF PIE1 , TMR2IE          ;讓Timer可以進行中斷
    BSF INTCON, PEIE      ; Peripheral interrupt enable
    MOVLW b'11111111'
    MOVWF T2CON
    MOVLW d'122' ;0.5秒
    MOVWF PR2
    
    MOVLW b'00100000'
    MOVWF OSCCON	        ;將系統時脈調整成250kHz
Main:
    BRA Main
END


