List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00
 

 I_IDX      EQU   0x50
 J_IDX      EQU   0x51
 FOUND      EQU   0x52
 VAL_I      EQU   0x53
 VAL_J      EQU   0x54
 REVVAL     EQU   0x55
 PAIR_CNT   EQU   0x56
 K_IDX      EQU   0x57
 PASS       EQU   0x58
 TMP        EQU   0x59


 USED_BASE  EQU   0x240        ; used[0..7] (Bank2)
 LEFT_BASE  EQU   0x270        ; LEFT[0..3] (Bank2)
 IN_BASE    EQU   0x200        ; INPUT
 OUT_BASEH  EQU   0x03         ; [0x320] ~ [0x323]
 OUT_BASEL  EQU   0x20         ; [0x324] ~ [0x327]

;測資------------------------------------------------------
        LFSR    0, IN_BASE
        MOVLW   0xC4      
        MOVWF   POSTINC0
        MOVLW   0xBB      
        MOVWF   POSTINC0
        MOVLW   0xBB       
        MOVWF   POSTINC0
        MOVLW   0x00       
        MOVWF   POSTINC0
        MOVLW   0x4C     
        MOVWF   POSTINC0
        MOVLW   0x8B     
        MOVWF   POSTINC0
        MOVLW   0xBB     
        MOVWF   POSTINC0
        MOVLW   0x00       
        MOVWF   POSTINC0

    START:
    ; used[0..7] = 0, TO RECORD IF THE INPUT[I] HAS BEEN PAIRED OR NOT
     MOVLB   0x02
     CLRF    0x240, 1
     CLRF    0x241, 1
     CLRF    0x242, 1
     CLRF    0x243, 1
     CLRF    0x244, 1
     CLRF    0x245, 1
     CLRF    0x246, 1
     CLRF    0x247, 1

    ; DEFAULT [0X320]~[0X327] ALL 0XFF
     MOVLB   0x03
     MOVLW   0xFF
     MOVWF   0x20, 1
     MOVWF   0x21, 1
     MOVWF   0x22, 1
     MOVWF   0x23, 1
     MOVWF   0x24, 1
     MOVWF   0x25, 1
     MOVWF   0x26, 1
     MOVWF   0x27, 1

    ; CLEAR [0X270]~[0X273], CLEAR LEFT
     MOVLB   0x02
     CLRF    0x270, 1
     CLRF    0x271, 1
     CLRF    0x272, 1
     CLRF    0x273, 1

     CLRF    PAIR_CNT
     CLRF    I_IDX

;??-----------------------------------------------
    FOR_I:
     ; IF 4 PAIRS ARE DONE, SORT AND THEN OUTPUT
     MOVF    PAIR_CNT, W
     SUBLW   4
     BTFSC   STATUS, Z
     GOTO    SORT_AND_OUTPUT

     ; IF I == 8 AND STILL NOT DONE, FAIL, ALL 0XFF
     MOVF    I_IDX, W
     SUBLW   8
     BTFSC   STATUS, Z
     GOTO    FAIL

     MOVF    I_IDX, W
     ADDLW   LOW USED_BASE
     MOVWF   FSR0L
     MOVLW   0x02
     MOVWF   FSR0H
     MOVF    INDF0, W
     BNZ     I_NEXT

     ; VAL_I = input[i]
     LFSR    0, IN_BASE
     MOVF    I_IDX, W
     ADDWF   FSR0L, F
     MOVF    INDF0, W
     MOVWF   VAL_I

     ; REVVAL = swap(VAL_I)
     MOVF    VAL_I, W
     MOVWF   REVVAL
     SWAPF   REVVAL, F

     ; j = i+1, FOUND=0
     MOVF    I_IDX, W
     ADDLW   1
     MOVWF   J_IDX
     CLRF    FOUND

    FOR_J:
     MOVF    J_IDX, W
     SUBLW   8
     BTFSC   STATUS, Z
     GOTO    NOT_FOUND

     MOVF    J_IDX, W
     ADDLW   LOW USED_BASE
     MOVWF   FSR1L
     MOVLW   0x02
     MOVWF   FSR1H
     MOVF    INDF1, W
     BNZ     J_NEXT

     ; VAL_J = input[j]
     LFSR    1, IN_BASE
     MOVF    J_IDX, W
     ADDWF   FSR1L, F
     MOVF    INDF1, W
     MOVWF   VAL_J

     ; input[j] == REVVAL ?
     MOVF    VAL_J, W
     CPFSEQ  REVVAL
     GOTO    J_NEXT

     ;???----------------------------
     MOVLW   0x01
     MOVWF   FOUND

     ; used[i] = 1
     MOVF    I_IDX, W
     ADDLW   LOW USED_BASE
     MOVWF   FSR2L
     MOVLW   0x02
     MOVWF   FSR2H
     MOVLW   0x01
     MOVWF   INDF2

     ; used[j] = 1
     MOVF    J_IDX, W
     ADDLW   LOW USED_BASE
     MOVWF   FSR2L
     MOVLW   0x02
     MOVWF   FSR2H
     MOVLW   0x01
     MOVWF   INDF2

     ; SMALL = min(VAL_I, VAL_J) ? LEFT[PAIR_CNT]
     MOVF    VAL_J, W        
     CPFSGT  VAL_I           
     GOTO    SMALL_IS_A      
     MOVLB   0x02
     MOVF    PAIR_CNT, W
     ADDLW   LOW LEFT_BASE
     MOVWF   FSR2L
     MOVLW   0x02
     MOVWF   FSR2H
     MOVF    VAL_J, W
     MOVWF   INDF2
     GOTO    PAIR_DONE

    SMALL_IS_A:
     MOVLB   0x02
     MOVF    PAIR_CNT, W
     ADDLW   LOW LEFT_BASE
     MOVWF   FSR2L
     MOVLW   0x02
     MOVWF   FSR2H
     MOVF    VAL_I, W
     MOVWF   INDF2

    PAIR_DONE:
     INCF    PAIR_CNT, F
     INCF    I_IDX, F
     GOTO    FOR_I

    J_NEXT:
     INCF    J_IDX, F
     GOTO    FOR_J

    NOT_FOUND:
     GOTO    FAIL

    I_NEXT:
     INCF    I_IDX, F
     GOTO    FOR_I

    ;LEFT????
    SORT_AND_OUTPUT:
     CLRF    PASS
    SORT_PASS:
     MOVF    PASS, W
     SUBLW   3
     BTFSC   STATUS, Z
     GOTO    OUTPUT_ALL

     CLRF    K_IDX
    SORT_INNER:
     ; SORT
     MOVLW   3
     MOVWF   TMP
     MOVF    PASS, W
     SUBWF   TMP, F ;TMP=2-PASS
     MOVF    K_IDX, W
     SUBWF   TMP, W
     BTFSC   STATUS, Z
     GOTO    NEXT_PASS

     ; A = LEFT[K], B = LEFT[K+1]
     MOVLB   0x02
     MOVF    K_IDX, W
     ADDLW   LOW LEFT_BASE
     MOVWF   FSR0L
     MOVLW   0x02
     MOVWF   FSR0H
     MOVF    INDF0, W
     MOVWF   VAL_I

     MOVF    K_IDX, W
     ADDLW   1
     ADDLW   LOW LEFT_BASE
     MOVWF   FSR1L
     MOVLW   0x02
     MOVWF   FSR1H
     MOVF    INDF1, W
     MOVWF   VAL_J

     ; IF A > B ? SWAP
     MOVF    VAL_J, W
     CPFSGT  VAL_I 
     GOTO    NO_SWAP
     MOVF    VAL_J, W
     MOVWF   INDF0
     MOVF    VAL_I, W
     MOVWF   INDF1

    NO_SWAP:
     INCF    K_IDX, F
     GOTO    SORT_INNER

    NEXT_PASS:
     INCF    PASS, F
     GOTO    SORT_PASS

    ; OUTPUT?OUT[0..3] = LEFT[0..3]?OUT[7-k] = SWAP(LEFT[k])
    OUTPUT_ALL:
     CLRF    K_IDX
    OUT_LOOP:
     MOVF    K_IDX, W
     SUBLW   4
     BTFSC   STATUS, Z
     GOTO    SUCCESS_DONE

     ; LEFT[k] -> VAL_I
     MOVLB   0x02
     MOVF    K_IDX, W
     ADDLW   LOW LEFT_BASE
     MOVWF   FSR0L
     MOVLW   0x02
     MOVWF   FSR0H
     MOVF    INDF0, W
     MOVWF   VAL_I

     ; OUT[0x320 + k] = LEFT[k]
     MOVF    K_IDX, W
     ADDLW   OUT_BASEL
     MOVWF   FSR2L
     MOVLW   OUT_BASEH
     MOVWF   FSR2H
     MOVF    VAL_I, W
     MOVWF   INDF2

     ; OUT[0x320 + (7-k)] = SWAP(LEFT[k])
     MOVF    K_IDX, W       
     SUBLW   7               
     ADDLW   OUT_BASEL
     MOVWF   FSR2L
     MOVLW   OUT_BASEH
     MOVWF   FSR2H
     MOVF    VAL_I, W
     MOVWF   TMP
     SWAPF   TMP, W
     MOVWF   INDF2

     INCF    K_IDX, F
     GOTO    OUT_LOOP

    SUCCESS_DONE:
     GOTO    ENDING

    FAIL:
     ; ALL 0x320..0x327 = 0xFF
     GOTO    ENDING

    ENDING:
     END
