#include "p18f4520.inc"

; ================================
; CONFIG
; ================================
  CONFIG  OSC = INTIO67
  CONFIG  FCMEN = OFF
  CONFIG  IESO = OFF
  CONFIG  PWRT = OFF
  CONFIG  BOREN = SBORDIS
  CONFIG  BORV = 3
  CONFIG  WDT = OFF
  CONFIG  WDTPS = 32768
  CONFIG  CCP2MX = PORTC
  CONFIG  PBADEN = OFF       ; PORTB<4:0> ?? Digital I/O
  CONFIG  LPT1OSC = OFF
  CONFIG  MCLRE = ON
  CONFIG  STVREN = ON
  CONFIG  LVP = OFF
  CONFIG  XINST = OFF
  CONFIG  CP0 = OFF
  CONFIG  CP1 = OFF
  CONFIG  CP2 = OFF
  CONFIG  CP3 = OFF
  CONFIG  CPB = OFF
  CONFIG  CPD = OFF
  CONFIG  WRT0 = OFF
  CONFIG  WRT1 = OFF
  CONFIG  WRT2 = OFF
  CONFIG  WRT3 = OFF
  CONFIG  WRTC = OFF
  CONFIG  WRTB = OFF
  CONFIG  WRTD = OFF
  CONFIG  EBTR0 = OFF
  CONFIG  EBTR1 = OFF
  CONFIG  EBTR2 = OFF
  CONFIG  EBTR3 = OFF
  CONFIG  EBTRB = OFF

; ================================
; Registers
; ================================
COUNT     EQU 0x20            ; ???
STATE     EQU 0x21            ; 0=??(0.25s) 1=??(1s)
TICK_CNT  EQU 0x22            ; 0.25s ?? tick
TMP       EQU 0x23            ; ?????

; ================================
; Reset Vector
; ================================
        ORG 0x00
        GOTO INIT

; ================================
; Interrupt Vector
; ================================
        ORG 0x08
ISR:
    ; ===== Timer2 Check =====
    BTFSS PIR1, TMR2IF
        BRA CHECK_INT0

    BCF  PIR1, TMR2IF
    INCF TICK_CNT, F

    ; even=1 tick / odd=4 ticks
    BTFSC STATE, 0
        MOVLW d'4'
    BTFSS STATE, 0
        MOVLW d'1'

    XORWF TICK_CNT, W
    BTFSS STATUS, Z
        BRA ISR_EXIT

    CLRF TICK_CNT

    ; COUNT += 2
    INCF COUNT, F
    INCF COUNT, F

    ; even wrap (>=16 ? 0)
    BTFSC STATE, 0
        BRA ODD_WRAP
EVEN_WRAP:
    MOVLW d'16'
    SUBWF COUNT, W           ; W = COUNT - 16
    BTFSS STATUS, C          ; C=1 ?? COUNT>=16
        BRA SHOW
    CLRF COUNT
    BRA SHOW

    ; odd wrap (>=16 ? 1)  ????? 16 ???15 ????
ODD_WRAP:
    MOVLW d'16'
    SUBWF COUNT, W
    BTFSS STATUS, C
        BRA SHOW
    MOVLW d'1'
    MOVWF COUNT

SHOW:
    ; ? COUNT ?4bit ??? RD7~RD4
    MOVF  COUNT, W
    SWAPF WREG, W
    ANDLW b'11110000'
    MOVWF LATD
    BRA   ISR_EXIT

; ===== INT0?RB0?Check =====
CHECK_INT0:
    BTFSS INTCON, INT0IF
        BRA ISR_EXIT

    ; ----- INT0 ISR??????????? Timer2? -----
    BCF  INTCON, INT0IF      ; ????????
    BCF  PIE1, TMR2IE        ; ?? Timer2 ????
    BCF  T2CON, TMR2ON       ; ?? Timer2 ??
    BCF  PIR1, TMR2IF        ; ??????? IF
    CLRF TICK_CNT

wait_low:                     ; ????RB0=0?
    BTFSC PORTB, 0
        BRA wait_low

    ; ??????~5ms*2?????????
    MOVLW d'150'
    MOVWF TMP
db1:
    DECFSZ TMP, 1
        BRA db1

wait_high:                    ; ????RB0=1?
    BTFSS PORTB, 0
        BRA wait_high

    MOVLW d'150'
    MOVWF TMP
db2:
    DECFSZ TMP, 1
        BRA db2

    ; ???? & ?? COUNT ??
    BTG  STATE, 0
    BTFSC STATE, 0
        MOVLW d'1'           ; ?????? ? ? 1 ??
    BTFSS STATE, 0
        MOVLW d'0'           ; ????? ? ? 0 ??
    MOVWF COUNT
    CLRF TICK_CNT

    ; ???? LED ??
    MOVF  COUNT, W
    SWAPF WREG, W
    ANDLW b'11110000'
    MOVWF LATD

    ; ???? Timer2
    BCF  PIR1, TMR2IF
    BSF  T2CON, TMR2ON
    BSF  PIE1, TMR2IE

ISR_EXIT:
    RETFIE

; ================================
; Initialization
; ================================
INIT:
    ; I/O ???
    MOVLW 0x0F
    MOVWF ADCON1

    ; LED?RD7~RD4 ??
    CLRF TRISD
    CLRF LATD

    ; RB0??? + ?? + ????
    BSF  TRISB, 0
    BCF  INTCON2, RBPU       ; ?? PORTB ??
    BCF  INTCON2, INTEDG0    ; ???????=0 ???

    ; Timer2???????? 0.25s ????
    BCF  PIR1, TMR2IF
    BSF  IPR1, TMR2IP
    BSF  PIE1, TMR2IE
    MOVLW b'11111111'        ; Post=1:16, TMR2ON=1, Pres=1:16
    MOVWF T2CON
    MOVLW d'61'
    MOVWF PR2
    MOVLW b'00100000'        ; ???? 1MHz
    MOVWF OSCCON

    ; ????
    BCF  RCON, IPEN
    BCF  INTCON, INT0IF
    BSF  INTCON, INT0IE
    BSF  INTCON, PEIE
    BSF  INTCON, GIE

    ; ????
    CLRF STATE               ; ??????
    CLRF COUNT
    CLRF TICK_CNT

MAIN:
    BRA MAIN

END
